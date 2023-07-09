# Arma-Influx

A3 extension for sending metrics to InfluxDB using Golang

## Build

### Windows

_Requires Go 1.20.1+ & MinGW_

  ```powershell
  $ENV:GOARCH = "amd64"
  $ENV:CGO_ENABLED = 1
  go build -o RangerMetrics_x64.dll -buildmode=c-shared .
  ```

To validate exported functions:
  
  ```powershell
  . "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.29.30133\bin\Hostx64\x64\dumpbin.exe" /exports .\RangerMetrics_x64.dll
  ```

## Notes
>
> See more: <https://github.com/code34/armago_x64>
