package web

import (
	"context"
	_ "embed"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/deliveroo/hopper-tutorial-dreed/config"
	"github.com/deliveroo/hopper-tutorial-dreed/logging"
	"github.com/deliveroo/hopper-tutorial-dreed/web/handler"

	"github.com/rs/zerolog/log"

	accesslog "github.com/mash/go-accesslog"
)

type WebProvider interface {
	Run(ctx context.Context)
	SetupRouter(ctx context.Context) *http.ServeMux
}

type web struct {
	Config             config.Config
	HealthcheckHandler *handler.HealthcheckHandler
	HelloHandler       *handler.HelloHandler
}

func NewWeb(cfg config.Config) WebProvider {
	healthcheckHandler := handler.NewHealthcheckHandler()
	helloHandler := handler.NewHelloHandler(HtmlTmpls)

	web := web{
		Config:             cfg,
		HealthcheckHandler: healthcheckHandler,
		HelloHandler:       helloHandler,
	}
	return web
}

func (w web) Run(ctx context.Context) {
	var runChan = make(chan os.Signal, 1)

	router := w.SetupRouter(ctx)
	httpLogger := logging.HttpLogger{}

	server := &http.Server{
		Addr:         w.Config.Server.Host + ":" + w.Config.Server.Port,
		Handler:      accesslog.NewLoggingHandler(router, httpLogger),
		IdleTimeout:  time.Duration(w.Config.Server.Timeout.Idle) * time.Second,
		ReadTimeout:  time.Duration(w.Config.Server.Timeout.Read) * time.Second,
		WriteTimeout: time.Duration(w.Config.Server.Timeout.Write) * time.Second,
	}

	_ = notifySignals(runChan)

	log.Log().Msgf("Server is starting on %s", server.Addr)

	go func() {
		if err := server.ListenAndServe(); err != nil {
			if err == http.ErrServerClosed {
			} else {
				log.Fatal().Err(err).Msg("Server failed to start")
			}
		}
	}()

	interrupt := <-runChan
	log.Log().Msgf("Server is shutting down due to %+v", interrupt)
	if err := server.Shutdown(ctx); err != nil {
		log.Fatal().Err(err).Msg("Server was unable to gracefully shutdown")
	}
}

func (w web) SetupRouter(ctx context.Context) *http.ServeMux {
	router := http.NewServeMux()
	router.HandleFunc("/", w.HelloHandler.Http)
	router.HandleFunc("/healthcheck", w.HealthcheckHandler.Http)

	return router
}

func notifySignals(runChan chan os.Signal) chan os.Signal {
	signal.Notify(runChan, os.Interrupt, syscall.SIGTSTP)
	return runChan
}
