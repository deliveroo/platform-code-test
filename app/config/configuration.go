package config

import (
	"github.com/caarlos0/env/v6"
)

type Config struct {
	DB      db
	Logging logging
	Server  server
}

type db struct {
	Host     string `env:"DB_HOST"`
	Name     string `env:"DB_NAME" envDefault:"postgres"`
	Password string `env:"DB_PASSWORD"`
	Port     int    `env:"DB_PORT" envDefault:"5432"`
	User     string `env:"DB_USER" envDefault:"postgres"`
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
