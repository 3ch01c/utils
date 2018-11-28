# How to set up Deluge with VPN
## On Debian
On Debian, install the Deluge packages through `apt`:
```
sudo apt update
sudo apt install deluged deluge-console deluge-web -y
```
Create a `deluge` user.
```
sudo adduser --system  --gecos "Deluge Service" --disabled-password --group --home /var/lib/deluge deluge
```
You can add your normal user to the `deluge` group to be able to access files.
```
sudo adduser me deluge
```
Configure Deluge service in `/etc/systemd/system/multi-user.target.wants/deluged.service`:
```
[Unit]
Description=Deluge Bittorrent Client Daemon
Documentation=man:deluged
After=network-online.target
[Service]
Type=simple
User=deluge
Group=deluge
UMask=000
ExecStart=/usr/bin/deluged -d
Restart=on-failure
# Configures the time to wait before service is stopped forcefully.
TimeoutStopSec=300
[Install]
WantedBy=multi-user.target
```
Now, start it up.
```
sudo systemctl enable deluged
sudo systemctl start deluged
```
## Configure Deluge Web UI
Create the web UI service configuration in `/etc/systemd/system/deluge-web.service`:
```
[Unit]
Description=Deluge Bittorrent Client Web Interface
Documentation=man:deluge-web
After=network-online.target deluged.service
Wants=deluged.service
[Service]
Type=simple
User=deluge
Group=deluge
UMask=027
# This 5 second delay is necessary on some systems
# to ensure deluged has been fully started
ExecStartPre=/bin/sleep 5
ExecStart=/usr/bin/deluge-web
Restart=on-failure
[Install]
WantedBy=multi-user.target
```
Now start it up.
```
sudo systemctl enable deluge-web
sudo systemctl start deluge-web
```
## Configure Deluge Logging
Make a log directory with appropriate permissions.
```
sudo mkdir -p /var/log/deluge
sudo chown -R deluge:deluge /var/log/deluge
sudo chmod -R 750 /var/log/deluge
```
Append `-d -l /var/log/deluge/daemon.log -L warning` to the `ExecStart` in each service:
```
ExecStart=/usr/bin/deluged -d -l /var/log/deluge/daemon.log -L warning
```
Enable logrotate in `/etc/logrotate.d/deluge`:
```
/var/log/deluge/*.log {
        rotate 4
        weekly
        missingok
        notifempty
        compress
        delaycompress
        sharedscripts
        postrotate
                systemctl restart deluged >/dev/null 2>&1 || true
                systemctl restart deluge-web >/dev/null 2>&1 || true
        endscript
}
```
## Wait to start Deluge until mount exists
Get a list of mounts:
```
sudo systemctl -t mount
```
Modify the `[Unit]` section of `/etc/systemd/system/deluged.service` where `xyz.mount` is the mount(s) you want to wait on from the previous command:
```
[Unit]
Description=Deluge Bittorrent Client Daemon
# Start after network and specified mounts are available.
After=network-online.target xyz.mount
Requires=xyz.mount
# Stops deluged if mount points disconnect
BindsTo=xyz.mount
```
## Configure Deluge to use VPN
Download the package and read the instructions at [https://github.com/bendikro/deluge-vpn](https://github.com/bendikro/deluge-vpn). It basically says to set up a link to the scripts in your VPN configuration.

Add the following to your OpenVPN script `/etc/openvpn/<MY_VPN>.conf` pointing to wherever you downloaded `deluge-vpn`:
```
up "/path/to/deluge-vpn/link_up_user_filter.sh"
```
Configure `/etc/systemd/system/multi-user.target.wants/openvpn@myserver.service` to run OpenVPN with `--script-security 2`.
```
# This service is actually a systemd target,
# but we are using a service since targets cannot be reloaded.

[Unit]
Description=OpenVPN service
After=syslog.target network.target

[Service]
PrivateTmp=true
Type=forking
#RemainAfterExit=yes
PIDFile=/var/run/openvpn/%i.pid
ExecStart=/usr/sbin/openvpn --daemon --writepid /var/run/openvpn/%i.pid --cd /etc/openvpn --config %i.conf --script-security 2
#ExecReload=/bin/true
#WorkingDirectory=/etc/openvpn

[Install]
WantedBy=multi-user.target
```
Configure /etc/systemd/system/multi-user.target.wants/openvpn@myserver.service to run OpenVPN with `--script-security 2`.
```
[Unit]
Description=OpenVPN connection to %i
PartOf=openvpn.service
ReloadPropagatedFrom=openvpn.service

[Service]
Type=forking
ExecStart=/usr/sbin/openvpn --daemon ovpn-%i --status /run/openvpn/%i.status 10 --cd /etc/openvpn --config /etc/openvpn/%i.conf --script-security 2
ExecReload=/bin/kill -HUP $MAINPID
WorkingDirectory=/etc/openvpn

[Install]
WantedBy=multi-user.target
```
## Enable remote thin client
Add user.
```
sudo -u deluge echo "user:pass:10" >> ~/.config/deluge/auth
```
Allow remote connections.
```
sudo -u deluge deluge-console "config -s allow_remote True"
sudo -u deluge deluge-console "config allow_remote"
```
## References
https://dev.deluge-torrent.org/wiki/UserGuide/Service/systemd
