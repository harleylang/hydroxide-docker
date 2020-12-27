# Hydroxide Dockerfile

This repository provides an example Dockerfile configuration for [hydroxide](https://github.com/emersion/hydroxide).

Before submitting issues, please see the [hydroxide](https://github.com/emersion/hydroxide) docs and [Protomail](https://protonmail.com/support/) support pages for hydroxide and Protonmail specific matters.

No guarantees explicit or implied are made regarding the warranty and security of this solution. It is one working example to get you started. If can improve any aspect of this example configuration, please submit an issue or send a pull request. 

## Data Flow

In general, these docker-related files automate the Protonmail login process via Hydroxide. To do this, your email and password (2FA optionally) are passed via environmental variables to the Docker runtime and your authentication data is stored in `~/.config/hydroxide/auth.json`. 

```
auth.json {
  "myProtonLogon" : "base64encodedEncryptedAccessToken"
}
```

With the Dockerfile, other users on the host system may be able access `auth.json`. It is recommended that the Docker volume containing the secret be mounted to a secured location on the host, and that root and sudo access be limited. Instructions

The `docker-compose` file is setup to share the info.json file via volume sharing.

## Setup

Below are some basic instructions to get you started.

### Building the image

Image can be built by simply running `docker build .` in the root directory. It's suggested you nominate a `--tag` for convenient use. It will look something like `docker build . --tag hydroxide:${HYDROXIDE_VERSION} --tag hydroxide:latest`

### Configuring permissions and storage

In order for permissions to work your host machine must have (at minimum) a directory that allows write and read access for whatever user id (or group id) you launch the container as. Directory setup can be achieved with something like `mkdir /SOME/HOST/PATH; sudo chmod 700 /SOME/HOST/PATH; sudo chown -R 1000:1000 /SOME/HOST/PATH`. There are two ways to achieve this. First, you can pass the user id and/or group id at build time using `--build-arg UID=1000 --build-arg GID=1000` (optionally you can specify the account name also). Secondly you can specify the user at run time with `--user=1000:1000`. To enable the persisted access token we map in the container to the secured directory on the host machine using `--volume /SOME/HOST/PATH:/home/hydroxide/.config/hydroxide` (note that this will be slightly different if you modified the account name during build stage). Setting volume mount and user permissions correctly ensures that the container will retain a copy of any access tokens it has created in the past, as well as prevent accidental or malicious access. Note that if a user with the same user id you are using in the container exists on the hosting system the container will have that account's access. If you really couldn't care less then simply override the user to root and launch the container.

### Running the image (stand-alone)

On first run the image requires your Protonmail logon, password, and, if enabled two factor authentication token. The parameters can be passed in by supplementing the `docker run` command with the environment options `--env USERNAME= --env PASSWORD= --env TOKEN=`. 

All up you'll have something like this. Note that we are using network host to expose the interfaces for ssh port forwarding and/or loopback use.

```
# Populate our environment variables
source .env
# Prompt for token since it's temporal
read -n 6 -p "2FA token:" PROTONMAIL_EXTRA_2FA

# Start up
docker run \
# Mount storage for persistence and set to the correct user
  --volume "/SOME/HOST/PATH:/home/hydroxide/.config/hydroxide" --user=1000:1000 \
# Pass in our arguments from the environment.
  --env USERNAME="${PROTONMAIL_LOGON}" --env PASSWORD="${PROTONMAIL_PASSWORD}" --env TOKEN="${PROTONMAIL_EXTRA_2FA}" --env DEBUG="${HYDROXIDE_DEBUG}" --env INTERPOD="${HYDROXIDE_DEBUG}" \
# Run attached directly to the host network so we can access it directly, as opposed to from other containers or a reverse proxy.
  --network host \
# Set the name for convenience as well as run detached
  --name hydroxide -d \
  "hydroxide:${HYDROXIDE_VERSION}"

# View logs so we can get the password
docker logs -f hydroxide

# Shut down
docker pause hydroxide
# or
docker stop hydroxide

# Clear the container from the runtime
docker rm hydroxide

# Clear stored credentials and emails
rm -f /data/hydroxide/*
```

### Running the image (docker-compose)

If you require a `docker-compose` file, see [docker-compose.yml](docker-compose.yml). Before running you must update the `.env` file with your personal values. This is time-critical when it comes to 2FA so you may wish to wrap your launch with a prompt to substitute. The token should only matter on first run as after that it will have stored some access token.

```
# Prompt for second factor
read -n 6 -p "2FA token:" TOKEN
# Start up overriding the .env value. You may remove the --build after you've built the first successful image but it should be idempotent.
PROTONMAIL_EXTRA_2FA=$TOKEN docker-compose up -d --build

# Spin down
docker-compose stop
```

### SSH port forwarding

You can use ssh to essentially tunnel between your local computer and the remote host running Hydroxide. Plenty of documentation on it but for convenience here's a start:
```
# Here we specify an ssh key associated with the account we wish to authenticate as
ssh -L 1025:localhost:1025 hostname -i ~/.ssh/ssh-key
# Here we use interactive login with a username and password combination
ssh -L 1143:localhost:1143 hostname -l username
# Here we restrict (or *bind*) access to only one IP and remap to 8081 on local as 8080 is often contested
ssh -L 127.0.0.1:8081:localhost:8080 hostname
```

### Python test script

Regardless of whether you use `docker` or `docker-compose`, you can quickly test your setup with python in terminal like so:

```

# navigate to this repo by changing the directory
cd /directory/path/to/this/repo

# you will need to edit the send_mail.py file, here I chose vim as my text editor, use what you prefer
vim send_mail.py

# while in vim, update:
# (1) the sender / receiver vars in the example() function to suit your needs, and
# (2) the addr variable if you are using docker-compose; in that case, set it to 'hydroxide'
# press the 'i' key to enter insert mode, make your changes, and press the 'esc' key when you are done
# type ':wq' (without brackets) to save your changes and exit 

# fire a test email
python3 send_mail.py

```
