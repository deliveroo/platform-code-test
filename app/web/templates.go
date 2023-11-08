package web

import (
	"embed"
)

var (
	//go:embed templates/html
	HtmlTmpls embed.FS
)
