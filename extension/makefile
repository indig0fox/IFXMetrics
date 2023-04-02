build:
	$env:GOARCH="amd64"
	$env:CGO_ENABLED=1
	go build -o RangerMetrics_x64.so -buildmode=c-shared .

	$env:GOARCH = "386"
	$env:CGO_ENABLED = 1
	go build -o RangerMetrics.dll -buildmode=c-shared .

	$env:GOARCH = "amd64"
	$env:CGO_ENABLED = 1
	go build -o RangerMetrics_x64.dll -buildmode=c-shared .
