# Hydroxide Dockerfile

This repository provides an example Dockerfile configuration for [hydroxide](https://github.com/emersion/hydroxide).

Before submitting issues, please see the [hydroxide](https://github.com/emersion/hydroxide) docs and [Protomail](https://protonmail.com/support/) support pages for hydroxide and Protonmail specific matters.

I offer no guarentees that this is a secure way to store and pass your hydroxide authentication information to other apps. It is one working example to get you started. If can improve the security of this example configuration, please send a pull request. 

## Data Flow

In general, these docker-related files automate the Protonmail login process via Hydroxide. To do this, your email and password (2FA optionally) are passed via environmental variables to the Docker runtime and your authentication data is stored in `~/.config/hydroxide/auth.json`. 

```
auth.json {

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

On first run the image requires your Protonmail logon, password, and, if enabled two factor authentication token. The parameters can be passed in by supplementing the `docker run` command with the environment options `--env USERNAME= --env PASSWORD= --env TOKEN=`. In order for permissions to work your host machine must have (at minimum) a directory that allows write and read access for whatever user id (or group id) you launch the container as. Directory setup can be achieved with something like `mkdir /data/hydroxide; sudo chmod 700 /data/hydroxide/; sudo chown -R 1000:1000 /data/hydroxide/`. There are two ways to achieve this. First, you can pass the user id or group id at build time using `--build-arg UID=1000` (optionally you can specify the account name also. Secondly you can specify the user at run time with `--user=hydroxide:1000`. To enable the persisted access token we map in the container to the secured directory on the host machine using `--volume /data/hydroxide:/home/hydroxide/.config/hydroxide` (note that this will be slightly different if you modified the account name). This ensures that the container will retain a copy of any access tokens it has created in the past, as well as prevent accidental or malicious access. Note that if a user with the same user id you are using in the container exists on the hosting system the container will have that account's access.

All up you'll have something like this:

```
docker run --volume /data/hydroxide:/home/hydroxide/.config/hydroxide \
  --env USERNAME=myProtonUsername --env PASSWORD=myProtonPassword --env TOKEN=myProtonToken --env DEBUG='' --env INTERPOD='' \
  --network host --name hydroxide -d --user=$(id -u):$(id -g) \
  myImageName:myImageTag
```

### Running the image (docker-compose)

If you require a `docker-compose` file, see [docker-compose.yml](docker-compose.yml). You must update the `.env` file with your personal values before your first run. This is time-critical when it comes to 2FA so you may wish to set the token inline with the command using `PROTONMAIL_EXTRA_2FA=12345`. The token should only matter on first run as after that it will have stored some access token.

```
# Start up
docker-compose up -d --build
# You may remove the --build after you've built the first successful image
# Spin down
docker-compose stop
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
