package config

import (
	"github.com/caarlos0/env/v6"
)

type Config struct {
	Logging logging
	Server  server
}

type logging struct {
	Level string `env:"LOGGING_LEVEL" envDefault:"error"`
}

type server struct {
	Host    string `env:"SERVER_HOST" envDefault:"0.0.0.0"`
	Port    string `env:"SERVER_PORT" envDefault:"8080"`
	Timeout serverTimeout
}

type serverTimeout struct {
	Idle   int `env:"SERVER_TIMEOUT_IDLE" envDefault:"65"`
	Read   int `env:"SERVER_TIMEOUT_WRITE" envDefault:"10"`
	Server int `env:"SERVER_TIMEOUT_SERVER" envDefault:"10"`
	Write  int `env:"SERVER_TIMEOUT_READ" envDefault:"10"`
}

func NewConfig() (Config, error) {

	cfg := &Config{}
	err := env.Parse(cfg)

	if err != nil {
		return Config{}, err
	}

	return *cfg, nil
}
