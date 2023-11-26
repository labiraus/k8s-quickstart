package main

import (
	"encoding/json"
	"fmt"
	"net/http"

	"go-common/api"
)

func main() {
	done := api.Init("webserverapi")
	http.HandleFunc("/hello", helloHandler)
	<-done
	api.Info.Println("finishing")
}

func helloHandler(w http.ResponseWriter, r *http.Request) {
	var err error
	defer func() {
		r := recover()
		if err != nil {
			api.Error.Println(err)
		}
		if r != nil {
			api.Error.Println(r)
			w.WriteHeader(http.StatusInternalServerError)
		}
	}()

	api.Info.Println("helloHandler called")

	user, err := GetUser(1)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	response := HelloResponse{Data: fmt.Sprintf("Hello %v!", user.Username)}

	data, err := json.Marshal(response)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	_, err = w.Write(data)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
}
