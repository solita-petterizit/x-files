package main

import (
	"testing"
)

func TestHelloWorld(t *testing.T) {
	want := "Hello, World!"

	templateData := NewTemplateData()

	actual := templateData.Text

	if actual != want {
		t.Fatalf("got %s want %s", actual, want)
	}
}
