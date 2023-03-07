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

Just run `generate-userdata.sh` and answer the prompts


## ToDo
* How do we know when the final reboot has happened? We have the system rebooting after patching itself but no way to know if the system is up finally or not.
* Currently all files are created on the system as root with permissions 644 (this is wrong for /home/ubuntu/.gitconfig which should be created as ubuntu:ubuntu)
* Check that hostname is a full fqdn
* Install the dan_tools github repo (how do we do that with this public repo?) GIT_SSH_COMMAND="ssh -i ~/.ssh/id_rsa_example" git clone example
* Install postfix (how do we pass it the mailuser and password?)
* Install Telegraf (currently uses the dan_tools github repo)
