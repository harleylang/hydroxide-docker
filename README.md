# Hydroxide Dockerfile

This repository provides an example Dockerfile configuration for [hydroxide](https://github.com/emersion/hydroxide).

Before submitting issues, please see the [hydroxide](https://github.com/emersion/hydroxide) docs and [Protomail](https://protonmail.com/support/) support pages for hydroxide and Protonmail specific matters.

I offer no guarentees that this is a secure way to store and pass your hydroxide authentication information to other apps. It is one working example to get you started. If can improve the security of this example configuration, please send a pull request. 

## Data Flow

In general, these docker-related files automate the Protonmail login process via hydroxide. To do this, your email and password are passed from the docker-related files (via environmental variables) and your authentication data is stroed in `/data/info.json`. 

```
info.json {

	'user': 'you@yourwebsite.com',
	'hash': 'yourhyDrOxIdEhaShHerE'

}

```

With the Dockerfile, other files on the host system  can access `info.json` to send emails by querying `/opt/hydroxide-container/data-hydroxide/info.json`.

The `docker-compose` file is setup to share the info.json file via volume sharing.

## Setup

Below are some basic instructions to get you started.

### Dockerfile only

If you require a Dockerfile, see the [Dockerfile](/Dockerfile) folder. If you are unfamiliar with Docker, here is some code to get you started.

```

# create folders where your hydroxide log file and auth tokens will live
mkdir /opt/hydroxide-container
mkdir /opt/hydroxide-container/data-hydroxide

# navigate to this repo by changing the directory
cd /directory/path/to/this/repo

# go to the Dockerfile directory
cd ./hydroxide

# you will need to edit the Dockerfile, here I chose vim as my text editor, use what you prefer
vim Dockerfile 

# while in vim, uncommment and update HYDROXIDEUSER and HYDROXIDEPASS vars to suit your needs
# press the 'i' key to enter insert mode, make your changes, and press the 'esc' key when you are done
# type ':wq' (without brackets) to save your changes and exit 

# build the Dockerfile image
docker build -t hydroxide .

# run the Dockerfile image
docker run -it -p 1025:1025 -v /opt/hydroxide-container/data-hydroxide:/data hydroxide

```

### docker-compose

If you require a `docker-compose` file, see [docker-compose.yml](docker-compose.yml). If you are unfamiliar with docker-compose, here is some code to get you started.

```

# navigate to this repo by changing the directory
cd /directory/path/to/this/repo

# you will need to edit docker-compose.yml, here I chose vim as my text editor, use what you prefer
vim Dockerfile 

# while in vim, update:
# (1) HYDROXIDEUSER and HYDROXIDEPASS vars to suit your needs, and
# (2) add services that you wish to link to the hydroxide server
# press the 'i' key to enter insert mode, make your changes, and press the 'esc' key when you are done
# type ':wq' (without brackets) to save your changes and exit 

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

