#!/bin/bash

# To auto manage my open vpn configs
# Incomplete script

# https://community.openvpn.net/openvpn/wiki/OpenVPN3Linux?__cf_chl_jschl_tk__=0dPQL88_M3MKfZbf74FJElHowRkFz0luVhAZDjZgSNQ-1636126777-gaNycGzNB1E-0

config_dir=~/.local/my_openvpn
[ -d $config_dir ] || mkdir $config_dir
MY_CONFIGURATION_FILE=$config_dir/profile-11.ovpn

# openvpn3 config-import --config ${MY_CONFIGURATION_FILE} --persistent

if [ $1 = "start" ]; then
    openvpn3 session-start --config $MY_CONFIGURATION_FILE
else
    openvpn3 session-manage --disconnect --config $MY_CONFIGURATION_FILE
fi

curl ifconfig.me








