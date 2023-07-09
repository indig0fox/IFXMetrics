package main

/*
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "extensionCallback.h"
*/
import "C" // This is required to import the C code

import (
	"bytes"
	"compress/gzip"
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"reflect"
	"strconv"
	"strings"
	"time"
	"unsafe"

	influxdb2 "github.com/influxdata/influxdb-client-go/v2"
)

// declare list of functions available for call
var AVAILABLE_FUNCTIONS = map[string]interface{}{
	"initExtension":        initExtension,
	"deinitExtension":      deinitExtension,
	"loadSettings":         loadSettings,
	"connectToInflux":      connectToInflux,
	"writeToInflux":        writeToInflux,
	"getDir":               getDir,
	"sanitizeLineProtocol": sanitizeLineProtocol,
	"version":              version,
	"getUnixTimeNano":      getUnixTimeNano,
}

var EXTENSION_VERSION string = "0.0.3"
var extensionCallbackFnc C.extensionCallback

type ServerPollSetting struct {
	Name        string `json:"name"`
	Enabled     bool   `json:"enabled"`
	ServerOnly  bool   `json:"serverOnly"`
	IntervalMs  int    `json:"intervalMs"`
	Bucket      string `json:"bucket"`
	Measurement string `json:"measurement"`
	Description string `json:"description"`
}

var ServerPollSettingProperties []string = []string{
	"Name",
	"Enabled",
	"ServerOnly",
	"IntervalMs",
	"Bucket",
	"Measurement",
	"Description",
}

type CBAEventHandler struct {
	Name        string `json:"name"`
	Enabled     bool   `json:"enabled"`
	Description string `json:"description"`
}

var CBAEventHandlerProperties []string = []string{
	"Name",
	"Enabled",
	"Description",
}

type settingsJson struct {
	Influx struct {
		Enabled bool   `json:"enabled"`
		Host    string `json:"host"`
		Token   string `json:"token"`
		Org     string `json:"org"`
	} `json:"influxdb"`
	Arma3 struct {
		RefreshRateMs int  `json:"refreshRateMs"`
		Debug         bool `json:"debug"`
	} `json:"arma3"`
	RecordingSettings map[string]interface{} `json:"recordingSettings"`
}

var activeSettings settingsJson

// InfluxDB variables
var InfluxClient influxdb2.Client

// file paths
var ADDON_FOLDER string = getDir() + "\\@RangerMetrics"
var LOG_FILE string = ADDON_FOLDER + "\\rangermetrics.log"
var SETTINGS_FILE string = ADDON_FOLDER + "\\settings.json"
var SETTINGS_FILE_EXAMPLE string = ADDON_FOLDER + "\\settings.example.json"

var BACKUP_FILE_PATH string = ADDON_FOLDER + "\\local_backup.log.gzip"
var BACKUP_WRITER *gzip.Writer

// configure log output
func init() {
	log.SetFlags(log.LstdFlags | log.Lshortfile)
	// log to file
	f, err := os.OpenFile(LOG_FILE, os.O_RDWR|os.O_CREATE|os.O_APPEND, 0666)
	if err != nil {
		log.Fatalf("error opening file: %v", err)
	}
	// log to console as well
	// log.SetOutput(io.MultiWriter(f, os.Stdout))
	// log only to file
	log.SetOutput(f)
}

func deinitExtension() {
	functionName := "deinitExtension"
	writeLog(functionName, `Deinitializing RangerMetrics extension"`, "INFO")

	if InfluxClient != nil {
		InfluxClient.Close()
	}

	writeLog(functionName, `Influx connection closed.`, "INFO")
}

// func RVExtensionContext(output *C.char, argc *C.int) {

// }

func initExtension() {
	deinitExtension()

	// load settings
	loadSettings()

	var err error

	// connect to Influx
	InfluxClient, err = connectToInflux()
	if err != nil {
		writeLog("initExtension", fmt.Sprintf(`Error connecting to Influx: %s`, err), "ERROR")
	} else {
		writeLog("initExtension", `Influx connection established.`, "INFO")
	}

	writeLog("extensionReady", `RangerMetrics extension ready.`, "INFO")

	// show version
	version()
}

func version() {
	functionName := "version"
	writeLog(functionName, fmt.Sprintf(`RangerMetrics Extension Version:%s`, EXTENSION_VERSION), "INFO")
}

// return db client and error
func connectToInflux() (influxdb2.Client, error) {

	// create backup writer
	if BACKUP_WRITER == nil {
		writeLog("connectToInflux", `Creating backup file`, "INFO")
		file, err := os.Open(BACKUP_FILE_PATH)
		if err != nil {
			writeLog("connectToInflux", `Error opening backup file`, "ERROR")
		}
		BACKUP_WRITER = gzip.NewWriter(file)
		if err != nil {
			writeLog("connectToInflux", `Error creating gzip writer`, "ERROR")
		}
	}

	if activeSettings.Influx.Host == "" ||
		activeSettings.Influx.Host == "http://host:8086" {

		return nil, errors.New("influxConnectionSettings.Host is empty")
		// writeLog("connectToInflux", `["Creating backup file", "INFO"]`)
		// file, err := os.Open(BACKUP_FILE_PATH)
		// if err != nil {
		// 	log.Fatal(err)
		// 	writeLog("connectToInflux", `["Error opening backup file", "ERROR"]`)
		// }
		// BACKUP_WRITER = gzip.NewWriter(file)
		// if err != nil {
		// 	log.Fatal(err)
		// 	writeLog("connectToInflux", `["Error creating gzip writer", "ERROR"]`)
		// }
		// return "Error connecting to Influx. Using local backup"
	}

	if activeSettings.Influx.Enabled == false {
		return nil, errors.New("influxConnectionSettings.Enabled is false")
	}

	InfluxClient := influxdb2.NewClientWithOptions(activeSettings.Influx.Host, activeSettings.Influx.Token, influxdb2.DefaultOptions().SetBatchSize(2500).SetFlushInterval(1000))

	if InfluxClient == nil {
		return nil, errors.New("InfluxClient is nil")
	}

	return InfluxClient, nil
}

func writeToInflux(a3DataRaw *[]string) string {

	var err error

	// convert to string array
	a3Data := *a3DataRaw

	if !activeSettings.Influx.Enabled {
		return "InfluxDB is disabled"
	}

	if InfluxClient == nil {
		InfluxClient, err = connectToInflux()
		if err != nil {
			InfluxClient = nil
			return fmt.Sprintf(`Error connecting to InfluxDB: %v`, err)
		}
	}

	MIN_PARAMS_COUNT := 1

	var logData string
	functionName := "writeToInflux"

	if len(a3Data) < MIN_PARAMS_COUNT {
		logData = fmt.Sprintf(`Not all parameters present (got %d, expected at least %d)`, len(a3Data), MIN_PARAMS_COUNT)
		writeLog(functionName, logData, "ERROR")
		return logData
	}

	// use custom bucket or default
	var bucket string = fixEscapeQuotes(trimQuotes(string(a3Data[0])))

	// Get non-blocking write client
	WRITE_API := InfluxClient.WriteAPI(activeSettings.Influx.Org, bucket)

	if WRITE_API == nil {
		// writeLog(functionName, "Error creating write API", "ERROR")
		// return logData
	} else {
		// Get errors channel
		errorsCh := WRITE_API.Errors()
		go func() {
			for writeErr := range errorsCh {
				writeLog(functionName, fmt.Sprintf(`Error parsing line protocol: %s`, writeErr.Error()), "ERROR")
			}
		}()
	}

	// now we have our write client, we'll go through the rest of the receive array items in line protocol format and write them to influx (should only be one line per call)

	var p string = fixEscapeQuotes(trimQuotes(string(a3Data[1])))

	// write the line to influx or backup
	if WRITE_API != nil {
		WRITE_API.WriteRecord(p)
		writeLog(functionName, fmt.Sprintf(`Wrote %d lines to influx`, len(a3Data)-1), "DEBUG")
	} else {
		// append backup line to file if BACKUP_WRITER is set
		if BACKUP_WRITER != nil {
			_, err = BACKUP_WRITER.Write([]byte(p + "\n"))
			if err != nil {
				writeLog(functionName, fmt.Sprintf(`Error writing to backup file: %s`, err), "ERROR")
			} else {
				writeLog(functionName, fmt.Sprintf(`Wrote %d lines to backup file`, len(a3Data)-1), "DEBUG")
			}
		} else {
			writeLog(functionName, `BACKUP_WRITER is nil`, "ERROR")
		}
	}

	return "Success"
}

// sanitize line protocol for influx
func sanitizeLineProtocol(line string) string {
	// replace all spaces with underscores
	// line = strings.ReplaceAll(line, ` `, `\ `)
	// replace all commas with underscores
	// line = strings.ReplaceAll(line, `,`, `\,`)
	// replace all equals with underscores
	// line = strings.ReplaceAll(line, "=", "_")
	// replace all quotes with underscores
	// line = strings.ReplaceAll(line, "\"", "_")

	return line
}

func getDir() string {
	dir, err := os.Getwd()
	if err != nil {
		log.Fatal(err)
	}
	return dir
}

// return true if the program should continue
func loadSettings() (settingsJson, error) {
	functionName := "loadSettings"
	writeLog(functionName, fmt.Sprintf(`ADDON_FOLDER: %s`, ADDON_FOLDER), "DEBUG")
	writeLog(functionName, fmt.Sprintf(`LOG_FILE: %s`, LOG_FILE), "DEBUG")
	writeLog(functionName, fmt.Sprintf(`SETTINGS_FILE: %s`, SETTINGS_FILE), "DEBUG")

	settings := settingsJson{}

	// print the current working directory
	var file *os.File
	var err error
	// read settings from file
	// settings.json should be in the same directory as the .dll
	// see if the file exists
	if _, err = os.Stat(SETTINGS_FILE); os.IsNotExist(err) {
		// file does not exist
		writeLog(
			functionName,
			fmt.Sprintf(`%s does not exist`, SETTINGS_FILE),
			"WARN",
		)
		// copy settings.json.example to settings.json
		// load contents
		fileContents, err := ioutil.ReadFile(SETTINGS_FILE_EXAMPLE)
		if err != nil {
			return settings, err
		}
		// write contents to settings.json
		err = ioutil.WriteFile(SETTINGS_FILE, fileContents, 0644)
		if err != nil {
			return settings, err
		}

		// Exit false to discontinue initialization since settings are defaults
		writeLog(functionName, `CREATED SETTINGS`, "INFO")
		// return a new error
		return settings, errors.New("settings.json does not exist")
	} else {
		// file exists
		writeLog(functionName, `settings.json found`, "DEBUG")
		// read the file
		file, err = os.Open(SETTINGS_FILE)
		if err != nil {
			return settings, err
		}
		defer file.Close()
		decoder := json.NewDecoder(file)
		err = decoder.Decode(&settings)
		if err != nil {
			return settings, err
		}

		// send contents of settings file
		// get the file contents
		fileContents, err := ioutil.ReadFile(SETTINGS_FILE)
		if err != nil {
			return settings, err
		}

		// compact the json
		var jsonStr bytes.Buffer
		err = json.Compact(&jsonStr, fileContents)
		if err != nil {
			return settings, err
		}

		writeLog(
			"loadSettingsJSON",
			jsonStr.String(),
			"DEBUG",
		)

	}

	return settings, nil
}

func runExtensionCallback(name *C.char, function *C.char, data *C.char) C.int {
	return C.runExtensionCallback(extensionCallbackFnc, name, function, data)
}

//export goRVExtensionVersion
func goRVExtensionVersion(output *C.char, outputsize C.size_t) {
	result := C.CString(EXTENSION_VERSION)
	defer C.free(unsafe.Pointer(result))
	var size = C.strlen(result) + 1
	if size > outputsize {
		size = outputsize
	}
	C.memmove(unsafe.Pointer(output), unsafe.Pointer(result), size)
}

//export goRVExtensionArgs
func goRVExtensionArgs(output *C.char, outputsize C.size_t, input *C.char, argv **C.char, argc C.int) {
	var offset = unsafe.Sizeof(uintptr(0))
	var out []string
	for index := C.int(0); index < argc; index++ {
		out = append(out, C.GoString(*argv))
		argv = (**C.char)(unsafe.Pointer(uintptr(unsafe.Pointer(argv)) + offset))
	}

	var temp string
	temp = fmt.Sprintf("Function: %s nb params: %d params: %s!", C.GoString(input), argc, out)

	if C.GoString(input) == "sendToInflux" {
		// start a goroutine to send the data to influx
		// param string is argv[0] which is the data to send to influx
		go writeToInflux(&out)
		// temp = fmt.Sprintf("Function: %s nb params: %d", C.GoString(input), argc)
		temp = "WRITE"
	}

	// Return a result to Arma
	result := C.CString(temp)
	defer C.free(unsafe.Pointer(result))
	var size = C.strlen(result) + 1
	if size > outputsize {
		size = outputsize
	}

	C.memmove(unsafe.Pointer(output), unsafe.Pointer(result), size)
}

func callBackExample() {
	name := C.CString("arma")
	defer C.free(unsafe.Pointer(name))
	function := C.CString("funcToExecute")
	defer C.free(unsafe.Pointer(function))
	// Make a callback to Arma
	for i := 0; i < 3; i++ {
		time.Sleep(2 * time.Second)
		param := C.CString(fmt.Sprintf("Loop: %d", i))
		defer C.free(unsafe.Pointer(param))
		runExtensionCallback(name, function, param)
	}
}

func getUnixTimeNano() int64 {
	// get the current unix timestamp in nanoseconds
	return time.Now().UnixNano()
}

func trimQuotes(s string) string {
	// trim the start and end quotes from a string
	return strings.Trim(s, `"`)
}

func fixEscapeQuotes(s string) string {
	// fix the escape quotes in a string
	return strings.Replace(s, `""`, `"`, -1)
}

func writeLog(functionName string, data string, level string) {
	if activeSettings.Arma3.Debug && level == "DEBUG" {

	} else if level != "DEBUG" {
		log.Println(data)
	}

	if extensionCallbackFnc != nil {
		// replace double quotes with 2 double quotes
		escapedData := strings.Replace(data, `"`, `""`, -1)
		// do the same for single quotes
		escapedData = strings.Replace(escapedData, `'`, `''`, -1)
		a3Message := fmt.Sprintf(`["%s", "%s"]`, escapedData, level)

		statusName := C.CString("RangerMetrics")
		defer C.free(unsafe.Pointer(statusName))
		statusFunction := C.CString(functionName)
		defer C.free(unsafe.Pointer(statusFunction))
		statusParam := C.CString(a3Message)
		defer C.free(unsafe.Pointer(statusParam))
		runExtensionCallback(statusName, statusFunction, statusParam)
	}
}

//export goRVExtension
func goRVExtension(output *C.char, outputsize C.size_t, input *C.char) {

	var temp string

	// writeLog("goRVExtension", fmt.Sprintf(`["Input: %s",  "DEBUG"]`, C.GoString(input)), true)

	switch C.GoString(input) {
	case "version":
		temp = EXTENSION_VERSION
	case "getDir":
		temp = getDir()
	case "getUnixTimeNano":
		time := getUnixTimeNano()
		temp = fmt.Sprintf(`["%s"]`, strconv.FormatInt(time, 10))

	default:
		// check if input is in AVAILABLE_FUNCTIONS
		// if not, return error
		// if yes, continue
		if _, ok := AVAILABLE_FUNCTIONS[C.GoString(input)]; !ok {
			temp = fmt.Sprintf(`["Function: %s not found!", "ERROR"]`, C.GoString(input))
		} else {
			// call the function by name
			go reflect.ValueOf(AVAILABLE_FUNCTIONS[C.GoString(input)]).Call([]reflect.Value{})
			temp = fmt.Sprintf(`["Function: %s called successfully", "DEBUG"]`, C.GoString(input))
		}
	}

	// switch C.GoString(input) {
	// case "version":
	// 	writeLog("goRVExtension", fmt.Sprintf(`["Input: %s",  "INFO"]`, C.GoString(input)))
	// 	temp = EXTENSION_VERSION
	// case "getDir":
	// 	writeLog("goRVExtension", fmt.Sprintf(`["Input: %s",  "INFO"]`, C.GoString(input)))
	// 	temp = getDir()
	// case "loadSettings":
	// 	writeLog("goRVExtension", fmt.Sprintf(`["Input: %s",  "INFO"]`, C.GoString(input)))
	// 	cwd, result, influxHost, timescaleUrl := loadSettings()
	// 	log.Println("CWD:", cwd)
	// 	log.Println("RESULT:", result)
	// 	log.Println("INFLUX HOST:", influxHost)
	// 	log.Println("TIMESCALE URL:", timescaleUrl)
	// 	if result != "" {
	// 		writeLog("goRVExtension", result)
	// 		temp = fmt.Sprintf(
	// 			`["%s", "%s", "%s", "%d"]`,
	// 			EXTENSION_VERSION,
	// 			influxConnectionSettings.Host,
	// 			influxConnectionSettings.Org,
	// 			a3Settings.RefreshRateMs,
	// 		)
	// 	}
	// case "connectToInflux":
	// 	// writeLog("goRVExtension", fmt.Sprintf(`["Input: %s",  "INFO"]`, C.GoString(input)))
	// 	go connectToInflux()
	// 	temp = `["Connecting to InfluxDB", "INFO"]`
	// case "connectToTimescale":
	// 	// writeLog("goRVExtension", fmt.Sprintf(`["Input: %s",  "INFO"]`, C.GoString(input)))
	// 	go connectToTimescale()
	// 	temp = `["Connecting to TimescaleDB", "INFO"]`
	// case "getUnixTimeNano":
	// 	temp = fmt.Sprintf(`["%d", "INFO"]`, getUnixTimeNano())
	// case "deinitialize":
	// 	writeLog("goRVExtension", fmt.Sprintf(`["Input: %s",  "INFO"]`, C.GoString(input)))
	// 	deinitialize()
	// 	temp = `["Deinitializing", "INFO"]`
	// default:
	// 	temp = fmt.Sprintf(`["Unknown command: %s", "ERROR"]`, C.GoString(input))
	// }

	result := C.CString(temp)
	defer C.free(unsafe.Pointer(result))
	var size = C.strlen(result) + 1
	if size > outputsize {
		size = outputsize
	}

	C.memmove(unsafe.Pointer(output), unsafe.Pointer(result), size)
	// return
}

//export goRVExtensionRegisterCallback
func goRVExtensionRegisterCallback(fnc C.extensionCallback) {
	extensionCallbackFnc = fnc
}

func main() {}
