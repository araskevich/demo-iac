
# sudo docker build . -t api-server:v0.1

############################
# STEP 1 build package 
############################

FROM golang:1.18 AS builder
WORKDIR /usr/src/app
COPY api-server.go .

# pre-copy/cache go.mod for pre-downloading dependencies and only redownloading them in subsequent builds if they change
COPY go.mod go.sum ./
RUN go mod download && go mod verify

RUN go build -v -o app . 

##################################
# STEP 2 install into small image
##################################

FROM alpine:latest

ENV APPCOLOR="green"

WORKDIR /usr/src/app

# apk add gcompat to run binary
RUN apk add libc6-compat

COPY --from=builder /usr/src/app/app .
EXPOSE 4000/tcp
CMD ["./app"]
