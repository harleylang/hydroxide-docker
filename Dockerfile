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

# Builder OS
FROM golang:1-alpine as builder

ARG HYDROXIDE_VERSION=0.2.17
WORKDIR /src

# Build Hydroxide binary, releases preferred for stability, source compile chosen for compatibility and security
RUN wget -c https://github.com/emersion/hydroxide/releases/download/v${HYDROXIDE_VERSION}/hydroxide-${HYDROXIDE_VERSION}.tar.gz -qO - | tar -xz --strip 1 \
    && go get -d ./cmd/hydroxide \
    && go build -o hydroxide ./cmd/hydroxide

################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
###### Copy to container
################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


# Container OS
FROM alpine:3.9 as runner

LABEL org.opencontainers.image.title="Docker Hydroxide"
LABEL org.opencontainers.image.description="Containerised version of Hydroxide, the FOSS alternative to ProtonMail's Bridge application. Authenticates and exposes SMTP, IMAP, and CalDAV interfaces."
LABEL org.opencontainers.image.version="0.2.17"
LABEL org.opencontainers.image.authors="10679234+arichtman@users.noreply.github.com;Harley Lang"
LABEL org.opencontainers.image.source="https://github.com/harleylang/hydroxide-docker"

ARG USER=hydroxide
ARG UID=1000
ARG GID=1000

# SMTP IMAP CalDAV
EXPOSE 1025 1143 8080

WORKDIR /hydroxide

USER root

# Create service principal objects and adjust the umask to protect any credentials stored to disk.
RUN addgroup -g $UID -S "${USER}" && adduser -D -u $UID -S "${USER}" -G "${USER}" && sed -i 's/umask 022/umask 077/g' /etc/profile

# Copy Hydroxide and wrapper script
COPY --from=builder /src/hydroxide .
COPY ./start.sh .

RUN chown -R hydroxide:hydroxide /hydroxide

USER hydroxide

# Pass the arguments explicitly for more robust chaining
ENTRYPOINT [ "/bin/sh", "-c", "./start.sh ${USERNAME} ${PASSWORD} ${TOKEN}" ]
