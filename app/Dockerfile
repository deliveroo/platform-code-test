FROM golang:1.23-alpine as builder

ARG DIR=${GOPATH}/src/deliveroo/platform-code-test-app
RUN mkdir -p ${DIR}
ADD . ${DIR}
WORKDIR ${DIR}
RUN go build -o /app


FROM alpine:3.21 as production

RUN apk add --no-cache ca-certificates
COPY --from=builder /app /app

CMD ["/app"]


FROM builder as test

RUN apk add --no-cache bash make gcc musl-dev gcompat

WORKDIR ${DIR}

CMD ["/usr/bin/make", "test_all"]
