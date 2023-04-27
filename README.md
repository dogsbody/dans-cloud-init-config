# Dan's cloud-init config generator

My entirely personal cloud-init config generator for test, dev and play.

## Installation

    git clone --recurse-submodules https://github.com/dogsbody/dans-cloud-init-config.git

or 

    git clone https://github.com/dogsbody/dans-cloud-init-config.git
    cd dans-cloud-init-config
    git submodule init
    git submodule update


## Usage

Add the Cloud Init Deploy Key to a file called `CloudInitDeployKey.pem` in the root of this repo

Just run `generate-userdata.sh` and answer the prompts


## ToDo
* How do we know when the final reboot has happened? We have the system rebooting after patching itself but no way to know if the system is up finally or not.
* Currently all files are created on the system as root with the same permissions of 644
* Check that hostname is a full fqdn
* Install postfix (how do we pass it the mailuser and password?)
* Add the Nginx repo so it's there if we ever want to install nginx
* Can we pre-install acme.sh ?
