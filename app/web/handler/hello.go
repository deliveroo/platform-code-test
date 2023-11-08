package handler

import (
	"embed"
	_ "embed"
	"html/template"
	"io/fs"
	"net/http"

	"github.com/rs/zerolog/log"
)

type HelloHandler struct {
	htmlTmpls fs.FS
}

func NewHelloHandler(htmlTmpls embed.FS) *HelloHandler {
	return &HelloHandler{
		htmlTmpls: htmlTmpls,
	}
}

func (h *HelloHandler) Http(respWriter http.ResponseWriter, request *http.Request) {
	tmpl, err := template.ParseFS(h.htmlTmpls, "templates/html/base.html", "templates/html/hello.html")
	if err != nil {
		log.Error().Err(err).Msg("Could not get templates")
		return
	}

	err = tmpl.Execute(respWriter, nil)
	if err != nil {
		respWriter.WriteHeader(http.StatusInternalServerError)
		_, _ = respWriter.Write([]byte(err.Error()))
		return
	}
}
