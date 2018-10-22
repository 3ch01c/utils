# Set up OpenVPN
On Debian, install the OpenVPN package through `apt`:
```
$ sudo apt-get install openvpn -y
```
Download an OpenVPN template from your VPN provider or create your own at `/etc/openvpn/ovpn.conf`:
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
auth-user-pass auth.txt
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
If you're using certificate-based authentication, add the certificate information.
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
Back up the startup script.
```
$ sudo cp /etc/systemd/system/multi-user.target.wants/openvpn.service /etc/systemd/system/multi-user.target.wants/openvpn.service.orig
```
Change the startup script.
```
# This service is actually a systemd target,
# but we are using a service since targets cannot be reloaded.

[Unit]
Description=OpenVPN service
After=syslog.target network.target

[Service]
PrivateTmp=true
Type=forking
PIDFile=/var/run/openvpn/%i.pid
ExecStart=/usr/sbin/openvpn --daemon --writepid /var/run/openvpn/%i.pid --cd /etc/openvpn --config %i.conf

[Install]
WantedBy=multi-user.target
```
This allows us to use different configurations by specifying the config file at the end. Since we're using `ovpn.conf`, append `@ovpn` to the service name.
```
$ sudo systemctl start openvpn@ovpn
```
Hopefully everything is up and you'll see a `tun0` interface.
```
$ ip -o addr | grep tun0
$ ip route | grep tun0
```
