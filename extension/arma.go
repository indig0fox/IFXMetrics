package main

/*
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "extensionCallback.h"
*/
import "C"

import (
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"
	"time"
	"unsafe"

	influxdb2 "github.com/influxdata/influxdb-client-go/v2"
)

var extensionCallbackFnc C.extensionCallback

func runExtensionCallback(name *C.char, function *C.char, data *C.char) C.int {
	return C.runExtensionCallback(extensionCallbackFnc, name, function, data)
}

//export goRVExtensionVersion
func goRVExtensionVersion(output *C.char, outputsize C.size_t) {
	result := C.CString("Version 1.0")
	defer C.free(unsafe.Pointer(result))
	var size = C.strlen(result) + 1
	if size > outputsize {
		size = outputsize
	}
	C.memmove(unsafe.Pointer(output), unsafe.Pointer(result), size)
}

//export goRVExtensionArgs
func goRVExtensionArgs(output *C.char, outputsize C.size_t, input *C.char, argv **C.char, argc C.int) int {
	var offset = unsafe.Sizeof(uintptr(0))
	var out []string
	for index := C.int(0); index < argc; index++ {
		out = append(out, C.GoString(*argv))
		argv = (**C.char)(unsafe.Pointer(uintptr(unsafe.Pointer(argv)) + offset))
	}
	temp := fmt.Sprintf("Function: %s nb params: %d params: %s!", C.GoString(input), argc, out)

	// Return a result to Arma
	result := C.CString(temp)
	defer C.free(unsafe.Pointer(result))
	var size = C.strlen(result) + 1
	if size > outputsize {
		size = outputsize
	}
	C.memmove(unsafe.Pointer(output), unsafe.Pointer(result), size)
	return 1
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

func sendToInflux(data string) {

	a3Data := strings.Split(data, ",")

	host := a3Data[0]
	token := a3Data[1]
	org := a3Data[2]
	bucket := a3Data[3]
	profile, locality := a3Data[4], a3Data[5]
	missionName, worldName, serverName := a3Data[6], a3Data[7], a3Data[8]
	metric := a3Data[9]
	valueType := a3Data[10]

	tags := map[string]string{
		"profile":    profile,
		"locality":   locality,
		"worldName":  worldName,
		"serverName": serverName,
	}
	fields := map[string]interface{}{
		"missionName": missionName,
		// "count": value,
	}

	var err error
	// allow for float or int values
	if valueType == "float" {
		fields["count"], err = strconv.ParseFloat(a3Data[11], 64)
	} else if valueType == "int" {
		fields["count"], err = strconv.Atoi(a3Data[11])
	}

	if (valueType != "float") && (valueType != "int") {
		log.Println("valueType must be either 'float' or 'int'", metric, valueType, a3Data[11])
	}

	if err != nil {
		log.Println(err)
	}

	// int_value, err := strconv.Atoi(value)
	client := influxdb2.NewClient(host, token)
	writeAPI := client.WriteAPI(org, bucket)

	p := influxdb2.NewPoint(
		metric,
		tags,
		fields,
		time.Now(),
	)

	// write point asynchronously
	writeAPI.WritePoint(p)

	// Flush writes
	writeAPI.Flush()

	defer client.Close()

	f, err := os.OpenFile("a3metrics.log",
		os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		log.Println(err)
	}
	defer f.Close()

	//logger := log.New(f, "", log.LstdFlags)
	//logger.Println(err)

}

//export goRVExtension
func goRVExtension(output *C.char, outputsize C.size_t, input *C.char) {
	// Return by default through ExtensionCallback arma handler the result
	if extensionCallbackFnc != nil {
		go callBackExample()
	} else {
		// Return a result through callextension Arma call
		temp := fmt.Sprintf("Cavmetrics: %s", C.GoString(input))
		result := C.CString(temp)
		defer C.free(unsafe.Pointer(result))
		var size = C.strlen(result) + 1
		if size > outputsize {
			size = outputsize
		}

		go sendToInflux(C.GoString(input))

		C.memmove(unsafe.Pointer(output), unsafe.Pointer(result), size)
	}
}

//export goRVExtensionRegisterCallback
func goRVExtensionRegisterCallback(fnc C.extensionCallback) {
	extensionCallbackFnc = fnc
}

func main() {}
