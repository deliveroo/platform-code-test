package handler

import (
	"embed"
	_ "embed"
	"html/template"
	"io/fs"
	"net/http"
	"time"

	_ "github.com/lib/pq"
	"github.com/rs/zerolog/log"
)

type ThirdpartyHandler struct {
	dbSettings dbSettings
	htmlTmpls  fs.FS
}

type thirdpartyTmplData struct {
	Message string
}

func NewThirdpartyHandler(htmlTmpls embed.FS) *ThirdpartyHandler {
	return &ThirdpartyHandler{
		htmlTmpls: htmlTmpls,
	}
}

func (h *ThirdpartyHandler) checkThirdparty() error {
	httpClient := http.Client{Timeout: 1 * time.Second}
	if _, err := httpClient.Get("http://httpforever.com:80/"); err != nil {
		return err
	}

	return nil
}

func (h *ThirdpartyHandler) Http(respWriter http.ResponseWriter, request *http.Request) {
	tmpl, err := template.ParseFS(h.htmlTmpls, "templates/html/base.html", "templates/html/thirdparty.html")
	if err != nil {
		log.Error().Err(err).Msg("Could not get templates")
		return
	}

	tmplData := thirdpartyTmplData{}

	err = h.checkThirdparty()
	if err != nil {
		tmplData.Message = err.Error()
	} else {
		tmplData.Message = "Connected"
	}

	err = tmpl.Execute(respWriter, tmplData)
	if err != nil {
		respWriter.WriteHeader(http.StatusInternalServerError)
		_, _ = respWriter.Write([]byte(err.Error()))
		return
	}
}
