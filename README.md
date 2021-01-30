# Dan's cloud-init config generator

My entirely personal cloud-init config generator for test, dev and play.

## Installation

    git clone --recurse-submodules https://github.com/dogsbody/dans-cloud-init-config.git

or 

    git clone https://github.com/dogsbody/dans-cloud-init-config.git
    git submodule init
    git submodule update


## Usage

Just run `generate-userdata.sh` an answer the prompts


## ToDo
* Set a hostname (and instance id?)
* How do we know when the final reboot has happened?
* Setup e-mail?
* Turn off secure boot in Ubuntu?


