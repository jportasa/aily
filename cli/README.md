# Instructions to run the CLI

Fetch the modules:
```
go get -u
```
Run examples:
```
go run main.go -regions us-east-1,us-west-2
go run main.go -regions us-east-1 -architecture x86_64
```
You can as well generate the binary with:
```
go build -o ami_cli
```
For the help, just type:
```
./ami_cli -h
Usage of ./ami_cli:
  -architecture string
        AMI architecture (e.g., x86_64, arm64)
  -creationDate string
        AMI creation date in RFC3339 format (e.g., 2023-07-10T05:00:00Z)
  -os string
        Operating System (e.g., Windows, Linux)
  -regions string
        Comma separated list of AWS regions
```