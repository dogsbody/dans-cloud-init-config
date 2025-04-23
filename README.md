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

In the /src dir...
- Add the Cloud Init Deploy Key to a file called `CloudInitDeployKey.pem`
- Add the mail server auth details in a file called `sasl_passwd`

Just run `generate-userdata.sh` and answer the prompts


## Debug
One of the best ways to see if there were any errors when deployed is to gret the cloud-init logs for "warning" and "failed"
    grep -i "warn\|fail" /var/log/cloud-init-output.log /var/log/cloud-init.log


## ToDo
* Currently all files are created on the system with the same permissions of 644
* Check that hostname is a full fqdn
* Find a way to automatically add a line to /etc/hosts for the public IP address and fqdn
*   e.g. 192.168.32.118  nzb01.dogsbody.org      nzb01
