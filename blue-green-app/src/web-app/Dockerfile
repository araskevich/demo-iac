
# sudo docker build . -t web-server:v0.1

############################
# STEP 1 build package 
############################

FROM golang:1.18 AS builder
WORKDIR /usr/src/app
COPY web-server.go .

# pre-copy/cache go.mod for pre-downloading dependencies and only redownloading them in subsequent builds if they change
COPY go.mod go.sum ./
RUN go mod download && go mod verify

RUN go build -v -o app . 

##################################
# STEP 2 install into small image
##################################

FROM alpine:latest

WORKDIR /usr/src/app

# apk add gcompat to run binary
RUN apk add libc6-compat

COPY ./public ./public
COPY --from=builder /usr/src/app/app .
EXPOSE 5000/tcp
CMD ["./app"]
