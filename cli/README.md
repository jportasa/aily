# Instructions to run the CLI

Fetch the modules:
````
go get -u
```
Run examples:
````
go run main.go -regions us-east-1,us-west-2
go run main.go -regions us-east-1 -architecture x86_64
```
You can as well generate the binary with:
````
go build -o ami_cli
```