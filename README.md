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

