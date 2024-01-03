package main

type HelloResponse struct {
	Data string `json:"data"`
}

type UserRequest struct {
	UserID int `json:"userid"`
}

type UserResponse struct {
	UserID   int    `json:"userid"`
	Username string `json:"username"`
	Email    string `json:"email"`
}
