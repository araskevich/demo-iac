package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"
)

type DropHealthcheck struct {
	dropHealthcheckProbe string
}

type WhatColorResponse struct {
	AppVersion     string `json:"app_version"`
	MyHostname     string `json:"server_hostname"`
	ClientAddr     string `json:"client_addr"`
	MyColor        string `json:"server_color"`
	ResponceStatus string `json:"status"`
	StatusMessage  string `json:"message"`
	TimestampUtc   string `json:"timestamp"`
}

func main() {

	name, err := os.Hostname()
	if err != nil {
		log.Fatal(err)
	}

	appColor := os.Getenv("APPCOLOR") // green or blue


	dropHealthcheck := &DropHealthcheck{dropHealthcheckProbe: "no"}

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		log.Printf("Connected from RemoteAddr: %s", r.RemoteAddr)
		fmt.Fprintf(w, "v0.1 - Hello from %s", name)
	})

	http.HandleFunc("/startupProbe", func(w http.ResponseWriter, r *http.Request) {
		log.Printf("startupProbe from RemoteAddr: %s", r.RemoteAddr)
		fmt.Fprintf(w, "v0.1 - startupProbe from %s", name)
	})

	http.HandleFunc("/livenessProbe", func(w http.ResponseWriter, r *http.Request) {
		if dropHealthcheck.dropHealthcheckProbe == "no" {
			log.Printf("dropHealthcheck: %s, livenessProbe from RemoteAddr: %s", dropHealthcheck.dropHealthcheckProbe, r.RemoteAddr)
			fmt.Fprintf(w, "v0.1 - livenessProbe from %s", name)
		} else {
			w.WriteHeader(http.StatusServiceUnavailable)
			log.Printf("dropHealthcheck: %s, livenessProbe failed from RemoteAddr: %s", dropHealthcheck.dropHealthcheckProbe, r.RemoteAddr)
			fmt.Fprintf(w, "v0.1 - livenessProbe failed from %s", name)
		}
	})

	http.HandleFunc("/readinessProbe", func(w http.ResponseWriter, r *http.Request) {
		log.Printf("readinessProbe from RemoteAddr: %s", r.RemoteAddr)
		fmt.Fprintf(w, "v0.1 - readinessProbe from %s", name)
	})

	http.HandleFunc("/dropHealthcheck", func(w http.ResponseWriter, r *http.Request) {
		dropHealthcheck.dropHealthcheckProbe = "yes"
		log.Printf("dropHealthcheck: %s, Connected from RemoteAddr: %s", dropHealthcheck.dropHealthcheckProbe, r.RemoteAddr)
		fmt.Fprintf(w, "v0.1 - Hello from %s", name)
	})

	http.HandleFunc("/whatColor", func(w http.ResponseWriter, r *http.Request) {

		responseBody := &WhatColorResponse{
			AppVersion:     "v0.1",
			MyHostname:     name,
			ClientAddr:     r.RemoteAddr,
			MyColor:        appColor,
			ResponceStatus: "ok",
			StatusMessage:  "Request successfully complete",
			TimestampUtc:   time.Now().UTC().String(),
		}

		payloadBuf := new(bytes.Buffer)
		json.NewEncoder(payloadBuf).Encode(responseBody)
		w.Header().Set("Access-Control-Allow-Origin", "*")

		log.Printf("whatColor response: %s", payloadBuf)
		fmt.Fprintf(w, "%s", payloadBuf)
	})

	log.Println("Server started, tcp port: 4000")

	http.ListenAndServe(":4000", nil)
}
