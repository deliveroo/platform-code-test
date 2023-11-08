package handler_test

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/deliveroo/platform-code-test-app/web/handler"

	"github.com/stretchr/testify/assert"
)

func TestHealthcheckOk(t *testing.T) {
	req, err := http.NewRequest("GET", "/healthcheck", nil)
	if err != nil {
		t.Fatal(err)
	}

	mockCtx := context.Background()
	req = req.WithContext(mockCtx)

	rr := httptest.NewRecorder()

	healthcheckHandler := handler.HealthcheckHandler{}
	handler := http.HandlerFunc(healthcheckHandler.Http)

	handler.ServeHTTP(rr, req)
	resBody := rr.Body.String()

	assert.Equal(t, rr.Code, http.StatusOK)
	assert.Contains(t, resBody, `{"status":"OK","errors":[]}`)
}
