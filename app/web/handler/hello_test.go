package handler_test

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/deliveroo/platform-code-test/web"
	"github.com/deliveroo/platform-code-test/web/handler"

	"github.com/stretchr/testify/assert"
)

func TestHello(t *testing.T) {
	req, err := http.NewRequest("GET", "/", nil)
	if err != nil {
		t.Fatal(err)
	}

	mockCtx := context.Background()
	req = req.WithContext(mockCtx)

	rr := httptest.NewRecorder()

	helloHandler := handler.NewHelloHandler(web.HtmlTmpls)
	handler := http.HandlerFunc(helloHandler.Http)

	handler.ServeHTTP(rr, req)
	resBody := rr.Body.String()

	assert.Equal(t, rr.Code, http.StatusOK)
	assert.Contains(t, resBody, `Hello`)
}
