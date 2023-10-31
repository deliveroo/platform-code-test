FROM deliveroo/hopper-runner:1.9.8 as hopper-runner


FROM golang:1.19-alpine as builder

ARG DIR=${GOPATH}/src/deliveroo/hopper-tutorial-dreed
RUN mkdir -p ${DIR}
ADD . ${DIR}
WORKDIR ${DIR}
RUN go build -o /app


FROM alpine:3.16 as production

RUN apk add --no-cache ca-certificates
COPY --from=builder /app /app
COPY --from=hopper-runner /hopper-runner /usr/bin/hopper-runner

ENTRYPOINT ["hopper-runner", "--server", "9999", "--"]
CMD ["/app"]


FROM builder as test

RUN apk add --no-cache bash make gcc musl-dev gcompat

WORKDIR ${DIR}

CMD ["/usr/bin/make", "test_all"]
