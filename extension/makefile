build:
	export GOARCH="amd64"
	export CGO_ENABLED=1
	go build -o RangerMetrics_x64.so -buildmode=c-shared .

	export GOARCH = "386"
	export CGO_ENABLED = 1
	go build -o RangerMetrics.dll -buildmode=c-shared .

	export GOARCH = "amd64"
	export CGO_ENABLED = 1
	go build -o RangerMetrics_x64.dll -buildmode=c-shared .
