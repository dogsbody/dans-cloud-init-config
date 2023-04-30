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
* How do we know when the final reboot has happened? We have the system rebooting after patching itself but no way to know if the system is up finally or not.
* Currently all files are created on the system with the same permissions of 644
* Check that hostname is a full fqdn
* add checkrepo script to `/opt/dan_tools` and check `/opt/dan_tools` up to not hanging
* Add an e-mail on boot script to `/opt/dan_tools` and e-mail on reboots which also fixes the "How do we know when the final reboot has happened?"

