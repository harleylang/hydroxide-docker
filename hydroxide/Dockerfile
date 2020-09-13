################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
######
######
######	Dockerfile for Hydroxide / Proton Mail Server
######
######
################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
###### Build Hydroxide	
################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# builder OS
FROM golang:1-alpine as builder

# update / dependencies  
RUN apk --update upgrade \
&& apk --no-cache --no-progress add git make gcc musl-dev \
&& rm -rf /var/cache/apk/*

# docker container settings
ENV GOPATH /go

# build hydroxide
RUN git -C ./src/ clone https://github.com/emersion/hydroxide/
RUN go get -d ./src/hydroxide/cmd/hydroxide/...
RUN cd /go/src/hydroxide/cmd/hydroxide && go build . && go install . && cd


################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
###### Copy to container
################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# container OS
FROM alpine:3.9

USER root

EXPOSE 1025

# update / dependencies
RUN apk --update upgrade \
    && apk --no-cache add ca-certificates bash openrc \
    && rm -rf /var/cache/apk/*

# email variables; either pass these from your docker-compose file OR uncomment and insert below
#ENV HYDROXIDEUSER you@youremail.here
#ENV HYDROXIDEPASS yourPasswordHere 

# copy hydroxide
COPY --from=builder /go/bin/hydroxide /usr/bin/hydroxide

COPY ./start.sh start.sh

WORKDIR /

ENTRYPOINT ["/start.sh"] 

