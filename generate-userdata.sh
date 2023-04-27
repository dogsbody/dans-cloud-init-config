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
hash mktemp
hash base64
hash dirname
hash python3 # used by write-mime-multipart

# Set some variables
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
WRITEMIME="$SCRIPTDIR/cloud-utils/bin/write-mime-multipart"
CLDLOCALD="$SCRIPTDIR/cloud-utils/bin/cloud-localds"
DEPLOYKEY="$SCRIPTDIR/CloudInitDeployKey.pem"
SOURCEDIR="$SCRIPTDIR/src/root"
OURCLOUDCONFIG=$(mktemp)
OURUSERDATARAW=$(mktemp)
OURUSERDATAIMG=""  # Set later in the script

if [ -f "$SCRIPTDIR/settings.local" ]; then source "$SCRIPTDIR/settings.local"; fi

# Check we have our submodule installed
if [[ ! -x ${WRITEMIME} || ! -x ${CLDLOCALD} ]];then
  echo "Error: Can't find the scripts we need in the cloud-utils sub-repo"
  echo "  You probably just need to initialise and update the submodule..."
  echo "    git submodule init -C ${SCRIPTDIR}"
  echo "    git submodule update -C ${SCRIPTDIR}"
  exit
fi

# Check we have our Deploy Key
if [[ ! -r ${DEPLOYKEY} ]];then
  echo "Error: Can't find the Deploy Key we need..."
  echo "  Ensure you have created ${DEPLOYKEY}"
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
OURUSERDATAIMG=$(mktemp -p "$SCRIPTDIR" "userdata-$HOSTNAME-XXXXX.img")

# Create our cloudconfig from the template and set the password
cp $SCRIPTDIR/src/cloudconfig $OURCLOUDCONFIG
sed -i -r "s/^password: hunter2$/password: $PASSWORD/" $OURCLOUDCONFIG

# Encode and add the files into the cloudconfig
echo "write_files:" >> $OURCLOUDCONFIG
for FILE in $(find "$SOURCEDIR" -type f -print); do
  BASE64=$(base64 --wrap=0 "${FILE}")
  FUSER="root"
  IFS='/' read -r -a SPLITFILE <<< "${FILE#$SOURCEDIR}"
  if [[ ${SPLITFILE[1]} == "home" && ! -z ${SPLITFILE[2]} ]];then
    FUSER="${SPLITFILE[2]}"
  fi
  echo "- path: ${FILE#$SOURCEDIR}"                >> $OURCLOUDCONFIG
  [[ -n "$BASE64" ]] && echo "  content: $BASE64"  >> $OURCLOUDCONFIG
  echo "  encoding: base64"      >> $OURCLOUDCONFIG
  echo "  owner: $FUSER:$FUSER"  >> $OURCLOUDCONFIG
  echo "  permissions: 0644"     >> $OURCLOUDCONFIG
  echo "  append: false"         >> $OURCLOUDCONFIG
done

# Manually add our Deploy Key
echo "- path: /tmp/CloudInitDeployKey"               >> $OURCLOUDCONFIG
echo "  content: $(base64 --wrap=0 "${DEPLOYKEY}")"  >> $OURCLOUDCONFIG
echo "  encoding: base64"   >> $OURCLOUDCONFIG
echo "  owner: root:root"   >> $OURCLOUDCONFIG
echo "  permissions: 0600"  >> $OURCLOUDCONFIG
echo "  append: false"      >> $OURCLOUDCONFIG

# Create our multipart file
$WRITEMIME $SCRIPTDIR/src/userscript:text/x-shellscript $OURCLOUDCONFIG --output=$OURUSERDATARAW

# Create our userdata volume
$CLDLOCALD --hostname $HOSTNAME $OURUSERDATAIMG $OURUSERDATARAW
echo "Disk Image: $OURUSERDATAIMG"

rm "$OURCLOUDCONFIG" "$OURUSERDATARAW"

