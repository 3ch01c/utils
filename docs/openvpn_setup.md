# How to set up OpenVPN
## On Debian (Ubuntu, Raspbian, etc.)
On Debian, install the OpenVPN package through `apt`:
```
sudo apt update
sudo apt install openvpn -y
```
This creates some files:

File/directory                                                | Purpose
------------------------------------------------------------- | -------
`/etc/openvpn`                                                | Configuration files
`/lib/systemd/system/openvpn/openvpn-client@.service`         | Client service template
`/lib/systemd/system/openvpn/openvpn-server@.service`         | Server service template
`/lib/systemd/system/openvpn/openvpn.service`                 | systemd target template
`/lib/systemd/system/openvpn/openvpn@.service`                | Connection service template
`/etc/systemd/system/multi-user.target.wants/openvpn.service` | systemd target
Take a look at `/lib/systemd/system/openvpn/openvpn@.service` because that's the one we're going to use:
```
[Unit]
Description=OpenVPN connection to %i
PartOf=openvpn.service
ReloadPropagatedFrom=openvpn.service
Before=systemd-user-sessions.service
Documentation=man:openvpn(8)
Documentation=https://community.openvpn.net/openvpn/wiki/Openvpn23ManPage
Documentation=https://community.openvpn.net/openvpn/wiki/HOWTO

[Service]
PrivateTmp=true
KillMode=mixed
Type=forking
ExecStart=/usr/sbin/openvpn --daemon ovpn-%i --status /run/openvpn/%i.status 10 --cd /etc/openvpn --config /etc/openvpn/%i.conf --writepid /run/openvpn/%i.pid
PIDFile=/run/openvpn/%i.pid
ExecReload=/bin/kill -HUP $MAINPID
WorkingDirectory=/etc/openvpn
ProtectSystem=yes
CapabilityBoundingSet=CAP_IPC_LOCK CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW CAP_SETGID CAP_SETUID CAP_SYS_CHROOT CAP_DAC_READ_SEARCH CAP_AUDIT_WRITE
LimitNPROC=10
DeviceAllow=/dev/null rw
DeviceAllow=/dev/net/tun rw

[Install]
WantedBy=multi-user.target
```
Notice how it says `--config /etc/openvpn/%i.conf`? That means if our service is called `openvpn@myserver`, then it will try to use the configuration `/etc/openvpn/myserver.conf`.

So, let's create `/etc/openvpn/myserver.conf`. You can give it a more descript name, like your VPN provider name, but it MUST end in `.conf` because that's what the template wants.

You'll need to download the configuration from your VPN provider and save it in that file. It should look something like this:
```
client
dev tun
proto udp
remote YOUR_VPN_SERVER_URL YOUR_VPN_SERVER_PORT
remote-cert-tls server
auth SHA256
setenv CLIENT_CERT 0
resolv-retry infinite
nobind
cipher AES-128-CBC
auth-user-pass
comp-lzo adaptive
tun-mtu-extra 32
<ca>
-----BEGIN CERTIFICATE-----
YOUR_VPN_SERVER_CA_CERTIFICATE
-----END CERTIFICATE-----
</ca>
<tls-auth>
-----BEGIN OpenVPN Static key V1-----
YOUR_VPN_SERVER_STATIC_KEY
-----END OpenVPN Static key V1-----
</tls-auth>
key-direction 1
```
If you're using password-based authentication, you'll probably want to create a credential file like `/etc/openvpn/credentials` and put your username and password on their own lines:
```
user01
P@ssw0rd!
```
Don't forget to secure the permissions on that file containing your plaintext password.
```
chmod 600 /etc/openvpn/credentials
```
You'll also need to add or edit the line in your VPN configuration to point to the credential file:
```
auth-user-pass credentials
```
If you're using certificate-based authentication, you'll probably need to add the certificate information to your configuration file.
```
<key>
-----BEGIN PRIVATE KEY-----
YOUR_VPN_SERVER_PRIVATE_KEY
-----END PRIVATE KEY-----
</key>
<cert>
-----BEGIN CERTIFICATE-----
YOUR_VPN_SERVER_CERTIFICATE
-----END CERTIFICATE-----
</cert>
```
Now, create and start your OpenVPN service:
```
sudo systemctl enable openvpn@myserver
sudo systemctl start openvpn@ovpn
```
Hopefully everything is up and you'll see a `tun0` interface.
```
ip -o addr | grep tun0
ip route | grep tun0
```
This should start up on every boot now.
## Troubleshooting
##### `Job for openvpn@myserver.service failed because the control process exited with error code`
Make sure you named your service the name of your `.conf` file and that the file does indeed end with `.conf`.
