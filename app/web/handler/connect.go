package handler

import (
	"database/sql"
	"embed"
	_ "embed"
	"fmt"
	"html/template"
	"io/fs"
	"net/http"

	_ "github.com/lib/pq"
	"github.com/rs/zerolog/log"

	"github.com/deliveroo/platform-code-test-app/config"
)

type ConnectHandler struct {
	dbSettings dbSettings
	htmlTmpls  fs.FS
}

type connectTmplData struct {
	Message string
}

type dbSettings struct {
	Host     string
	Name     string
	Password string
	Port     int
	User     string
}

func NewConnectHandler(htmlTmpls embed.FS, cfg config.Config) *ConnectHandler {
	db := dbSettings{
		Host:     cfg.DB.Host,
		Name:     cfg.DB.Name,
		Password: cfg.DB.Password,
		Port:     cfg.DB.Port,
		User:     cfg.DB.User,
	}
	return &ConnectHandler{
		dbSettings: db,
		htmlTmpls:  htmlTmpls,
	}
}

func (h *ConnectHandler) checkDBConnection() error {
	psqlconn := fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s sslmode=disable connect_timeout=2", h.dbSettings.Host, h.dbSettings.Port, h.dbSettings.User, h.dbSettings.Password, h.dbSettings.Name)
	db, err := sql.Open("postgres", psqlconn)
	if err != nil {
		return err
	}

	defer db.Close()

	err = db.Ping()
	if err != nil {
		return err
	}

	return nil
}

func (h *ConnectHandler) Http(respWriter http.ResponseWriter, request *http.Request) {
	tmpl, err := template.ParseFS(h.htmlTmpls, "templates/html/base.html", "templates/html/connect.html")
	if err != nil {
		log.Error().Err(err).Msg("Could not get templates")
		return
	}

	tmplData := connectTmplData{}

	err = h.checkDBConnection()
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
