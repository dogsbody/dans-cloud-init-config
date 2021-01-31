#!/usr/bin/env bash
#
# Description:  A script to create valid user-data for cloud-init
#
# Usage:  $0
#
# Configuration:  Source files can be found in the `src` directory
#     src/cloudconfig  A file used as a template for the cloud-config
#     src/userscript   A script to be run at the end of the first bootup 
#     src/root/        Files that should be placed on the system in the appropriate directories
#
# Notes:  Currently all files are created on the system as root with permissions 644.
#

set -e
set -u

# Basic check that we have the tools that all systems should have (uses set -e)
# echo, cd, pwd are all bash built-in's
hash cp
hash sed
hash find
hash base64
hash dirname
hash python3 # used by write-mime-multipart

# Set some variables
printf -v DATE '%(%Y%m%d%H%M%S)T' -1
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
WRITEMIME="$SCRIPTDIR/cloud-utils/bin/write-mime-multipart"
CLDLOCALD="$SCRIPTDIR/cloud-utils/bin/cloud-localds"
OURCLOUDCONFIG="$SCRIPTDIR/$DATE-cloudconfig"
OURUSERDATARAW="$SCRIPTDIR/$DATE-userdata.raw"
OURUSERDATAIMG="$SCRIPTDIR/$DATE-userdata.img"

# Check we have our submodule installed
if [[ ! -x ${WRITEMIME} || ! -x ${CLDLOCALD} ]];then
  echo "Error: Can't find the scripts we need in the cloud-utils sub-repo"
  echo "  You probably just need to initialise and update the submodule..."
  echo "    git submodule init -C ${SCRIPTDIR}"
  echo "    git submodule update -C ${SCRIPTDIR}"
  exit
fi

if ! command -v "genisoimage" >/dev/null ;then
  echo "Error: Can't find 'genisoimage' on the sytem"
  echo "  This can be installed (on Ubuntu 20.04) with..."
  echo "    sudo apt install genisoimage"
  exit
fi

# Get a password
echo 
echo "Let's get some information from you regarding your new system..."
read -p 'Hostname: ' HOSTNAME
read -sp 'Password: ' PASSWORD
echo -e "\n"

# Create our cloudconfig from the template and set the password
cp $SCRIPTDIR/src/cloudconfig $OURCLOUDCONFIG
sed -i -r "s/^password: hunter2$/password: $PASSWORD/" $OURCLOUDCONFIG

# Encode and add the files into the cloudconfig
echo "write_files:" >> $OURCLOUDCONFIG
for FILE in $(find "$SCRIPTDIR/src/root" -type f -print); do
  echo "- path: ${FILE#$SCRIPTDIR/src/root}"      >> $OURCLOUDCONFIG
  echo "  content: $(base64 --wrap=0 "${FILE}")"  >> $OURCLOUDCONFIG
  echo "  encoding: base64"                       >> $OURCLOUDCONFIG
  # Leaving these options here not 'cos they are needed but as prompts for improvement in the future 
  echo "  owner: root:root"   >> $OURCLOUDCONFIG
  echo "  permissions: 0644"  >> $OURCLOUDCONFIG
  echo "  append: false"      >> $OURCLOUDCONFIG
done
echo "Cloudconfig: $OURCLOUDCONFIG"

# Create our multipart file
$WRITEMIME $SCRIPTDIR/src/userscript:text/x-shellscript $OURCLOUDCONFIG --output=$OURUSERDATARAW
echo "Raw Userdata: $OURUSERDATARAW"

# Create our userdata volume
$CLDLOCALD --hostname $HOSTNAME $OURUSERDATAIMG $OURUSERDATARAW
echo "Disk Image: $OURUSERDATAIMG"

