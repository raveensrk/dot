# IP addresses for currently running Linux and Windows systems
LINUX_IP=$(ip addr | awk '/inet / && !/127.0.0.1/ {split($2,a,"/"); print a[1]}')
WINDOWS_IP=$(ip route | awk '/^default/ {print $3}')

# IP addresses in current windows defender firewall rule
# netsh outputs line of "^(Local|Remote)IP:\s+IPADDR/32$" so get second field of
# 'IPADDR/32' and split it on '/' then just print IPADDR
FIREWALL_WINDOWS_IP=$(netsh.exe advfirewall firewall show rule name=X11-Forwarding | awk '/^LocalIP/ {split($2,a,"/");print a[1]}')
FIREWALL_LINUX_IP=$(netsh.exe advfirewall firewall show rule name=X11-Forwarding | awk '/^RemoteIP/ {split($2,a,"/");print a[1]}')

# Update firewall rule if firewall rules IPs don't match actual ones
if [ "$FIREWALL_LINUX_IP" != "$LINUX_IP" ] || [ "$WINDOWS_IP" != "$FIREWALL_WINDOWS_IP" ]; then
	powershell.exe -Command "Start-Process netsh.exe -ArgumentList \"advfirewall firewall set rule name=X11-Forwarding new localip=$WINDOWS_IP remoteip=$LINUX_IP \" -Verb RunAs"
fi

# Appropriately set DISPLAY to Windows X11 server
DISPLAY="$WINDOWS_IP:0"

# Tell X11 programs to render on Windows, not linux, side
# docs: https://docs.mesa3d.org/envvars.html
LIBGL_ALWAYS_INDIRECT=1

export DISPLAY LIBGL_ALWAYS_INDIRECT
