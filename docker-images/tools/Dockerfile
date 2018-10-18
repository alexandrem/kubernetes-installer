FROM golang:1.11.1-alpine3.8 AS build

RUN apk add --no-cache git
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go get -u github.com/platform9/etcdadm

FROM alpine:latest

ARG K8S_VERSION=v1.12.1
ADD https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION}/bin/linux/amd64/kubeadm /usr/bin/
RUN chmod +x /usr/bin/kubeadm

COPY --from=build /go/bin/etcdadm /usr/bin/
# ADD entrypoint.sh /

# ENTRYPOINT ["/entrypoint.sh"]