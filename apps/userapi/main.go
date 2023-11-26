package main

import (
	"encoding/json"
	"io"
	"net/http"

	"go-common/api"
)

func main() {
	done := api.Init("userapi")
	http.HandleFunc("/user", userHandler)
	<-done
}

func userHandler(w http.ResponseWriter, r *http.Request) {
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

	api.Info.Println("userHandler called")

	var request = UserRequest{}
	body, err := io.ReadAll(r.Body)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	err = json.Unmarshal(body, &request)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	if request.UserID == 0 {
		request.UserID = 1
	}

	response := UserResponse{
		UserID:   request.UserID,
		Username: "a nonny mouse",
		Email:    "something@somewhere.com",
	}

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
