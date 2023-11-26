package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

const userPath = "http://userapi.default.svc.cluster.local/user"

var (
	client = http.Client{}
)

func GetUser(userID int) (UserResponse, error) {
	request, err := json.Marshal(UserRequest{UserID: userID})
	if err != nil {
		return UserResponse{}, fmt.Errorf("error marshalling request to (%v):%v", userPath, err)
	}

	resp, err := client.Post(userPath, "application/json", bytes.NewReader(request))
	if err != nil {
		return UserResponse{}, fmt.Errorf("error calling (%v): %v", userPath, err)
	}

	defer resp.Body.Close()
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return UserResponse{}, fmt.Errorf("error reading response from (%v):%v", userPath, err)
	}

	if resp.StatusCode != http.StatusOK {
		return UserResponse{}, fmt.Errorf("%v returned calling (%v): %v", resp.Status, userPath, string(body))
	}

	var user UserResponse
	err = json.Unmarshal(body, &user)
	if err != nil {
		return UserResponse{}, fmt.Errorf("error unmarshalling response from (%v) {%v}:%v", userPath, string(body), err)
	}

	return user, nil
}
