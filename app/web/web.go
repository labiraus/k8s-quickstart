package main

import (
	"context"
	"fmt"
	"k8s-quickstart/pkg/api"
	"k8s-quickstart/pkg/types/user"
	"log"
	"net/http"
	"os"
	"os/signal"
)

func main() {
	fmt.Println("web starting")
	ctx, ctxDone := context.WithCancel(context.Background())
	done := api.StartBasicApi(ctx, webHandler)
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt)
	s := <-c
	ctxDone()
	fmt.Println("hello got signal: " + s.String() + " now closing")
	<-done
}

func webHandler(w http.ResponseWriter, r *http.Request) {
	defer func() {
		r := recover()
		if r != nil {
			log.Println(r)
		}
	}()

	request := user.UserRequest{UserName: "someone"}

	resp, err := api.Post("http://user-service.k8s-quickstart:8080", request)
	if err != nil {
		err = fmt.Errorf("user request:%v", err)
		log.Println(err)
		fmt.Fprint(w, err)
		return
	}

	var response = user.UserResponse{}
	api.UnmarshalResponse(&response, resp)
	fmt.Printf("web handler got %#v\n", response)

	fmt.Fprintf(w, "Greetings %s", response.Greeting)
}
