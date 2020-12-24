# Hydroxide Dockerfile

This repository provides an example Dockerfile configuration for [hydroxide](https://github.com/emersion/hydroxide).

Before submitting issues, please see the [hydroxide](https://github.com/emersion/hydroxide) docs and [Protomail](https://protonmail.com/support/) support pages for hydroxide and Protonmail specific matters.

I offer no guarentees that this is a secure way to store and pass your hydroxide authentication information to other apps. It is one working example to get you started. If can improve the security of this example configuration, please send a pull request. 

## Data Flow

In general, these docker-related files automate the Protonmail login process via Hydroxide. To do this, your email and password (2FA optionally) are passed via environmental variables to the Docker runtime and your authentication data is stored in `~/.config/hydroxide/auth.json`. 

```
info.json {

	'user': 'you@yourwebsite.com',
	'hash': 'yourhyDrOxIdEhaShHerE'

}

```

With the Dockerfile, other users on the host system may be able access `auth.json`. It is recommended that the Docker volume containing the secret be mounted to a secured location on the host, and that root and sudo access be limited.

The `docker-compose` file is setup to share the info.json file via volume sharing.

## Setup

Below are some basic instructions to get you started.

### Building the image

Image can be built by simply running `docker build .` in the root directory. It's suggested you nominate a `--tag` for convenient use.

### Running the image (stand-alone)

On first run the image requires your Protonmail logon, secret, and two factor authentication token. The parameters can be passed in by supplementing the `docker run` command with the environment options `-e USERNAME= -e PASSWORD= -e TOKEN=`. For convenience it's recommended that `/root/.config/hydroxide` in the container is mapped to a secured directory on the host machine, this ensures that the container will retain a copy of any access tokens it has created in the past, as well as prevent accidental or malicious access.

### Running the image (docker-compose)

If you require a `docker-compose` file, see [docker-compose.yml](docker-compose.yml). If you are unfamiliar with docker-compose, here is some code to get you started. Make sure to update the `.env` file with your personal values before your first run.

```
# spin container 
docker-compose stop && docker-compose up -d --build 

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
