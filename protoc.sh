#!/bin/bash

SERVICE_NAME=$1
RELEASE_VERSION=$2
USER_NAME=$3
EMAIL=$4

git config user.name "$USER_NAME"
git config user.email "$EMAIL"
git fetch --all && git checkout main

sudo apt-get install -y protobuf-compiler golang-goprotobuf-dev
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
protoc --go_out=./golang --go_opt=paths=source_relative \
  --go-grpc_out=./golang --go-grpc_opt=paths=source_relative \
 ./${SERVICE_NAME}/*.proto
cd golang/${SERVICE_NAME}
go mod init \
  github.com/huseyinbabal/microservices-proto/golang/${SERVICE_NAME} || true
go mod tidy
cd ../../
git add . && git commit -am "proto update" || true
git push origin HEAD:main
git tag -fa golang/${SERVICE_NAME}/${RELEASE_VERSION} \
  -m "golang/${SERVICE_NAME}/${RELEASE_VERSION}" 
git push origin refs/tags/golang/${SERVICE_NAME}/${RELEASE_VERSION}
