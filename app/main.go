package main

import (
	"context"
	"os"
	"time"

	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"

	"github.com/deliveroo/hopper-tutorial-dreed/config"
	"github.com/deliveroo/hopper-tutorial-dreed/web"
)

func main() {
	log.Log().Msg("Reading config")
	cfg, err := config.NewConfig()
	if err != nil {
		log.Fatal().Err(err).Msg("Unable to retrieve configuration")
		os.Exit(3)
	}

	zLevel, err := zerolog.ParseLevel(cfg.Logging.Level)
	if err == nil {
		zerolog.SetGlobalLevel(zLevel)
	} else {
		log.Error().Err(err).Msgf("Could not get and set log level %s, using default", cfg.Logging.Level)
	}

	log.Log().Msg("Starting server")
	ctx, cancel := context.WithTimeout(
		context.Background(),
		time.Duration(cfg.Server.Timeout.Server)*time.Second,
	)
	defer cancel()

	web.NewWeb(cfg).Run(ctx)
}
