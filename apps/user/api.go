package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
)

var (
	client = &http.Client{}
)

type validBody interface {
	Validate() error
}

//StartBasicApi starts a basic web server
func StartBasicApi(ctx context.Context, handler func(http.ResponseWriter, *http.Request)) <-chan struct{} {
	done := make(chan struct{})
	srv := &http.Server{Addr: "0.0.0.0:8080"}
	http.HandleFunc("/", handler)
	go func() {
		if err := srv.ListenAndServe(); err != http.ErrServerClosed {
			panic("ListenAndServe: " + err.Error())
		}
	}()
	go func() {
		defer close(done)

		<-ctx.Done()
		if err := srv.Shutdown(ctx); err != nil {
			log.Println("Shutdown: " + err.Error())
		}
	}()

	return done
}

func UnmarshalRequest(bodyType validBody, request *http.Request) error {
	body, err := ioutil.ReadAll(request.Body)
	if err != nil {
		return err
	}
	err = json.Unmarshal(body, &bodyType)
	if err != nil {
		return err
	}

	err = bodyType.Validate()
	if err != nil {
		return err
	}

	return nil
}

func MarshalResponse(body validBody, w http.ResponseWriter) error {
	data, err := json.Marshal(body)
	if err != nil {
		return err
	}

	_, err = w.Write(data)
	if err != nil {
		return err
	}

	return nil
}

func UnmarshalResponse(bodyType validBody, resp *http.Response) error {
	defer resp.Body.Close()

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return err
	}

	err = json.Unmarshal(body, &bodyType)
	if err != nil {
		return err
	}

	err = bodyType.Validate()
	if err != nil {
		return err
	}

	return nil
}

func Post(url string, request interface{}) (*http.Response, error) {
	data, err := json.Marshal(request)
	if err != nil {
		return nil, err
	}

	fmt.Printf("sending %#v to %v\n", string(data), url)
	resp, err := client.Post(url, "application/json", bytes.NewBuffer(data))
	if err != nil {
		return nil, err
	}

	return resp, nil
}
