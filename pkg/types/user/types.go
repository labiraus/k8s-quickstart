package user

type UserRequest struct {
	UserName string
}

func (r UserRequest) Validate() error {
	return nil
}

type UserResponse struct {
	Greeting string
}

func (r UserResponse) Validate() error {
	return nil
}
