mkdir ~/.ssh
echo 	ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCzfkU8sfou5J8utetd7gqprQcu6Mry56Y/GrIwlJcgmTJcP39PwYnRnMhJNyPZleR9prw04dABgn5c/MA8l1Yny8XBZTvcMXYPASwdFdLRNiEJ9dCRuaT9ScTVZlbOI4JF7duYvN7U2z/SZTP67A6MeQBIkzGe9mSgtkJ5+b5a9n95OrT32sNHNPH8EtSkdmctfebBBalov03GcLSNFw2LTRyrktdsmiErUBNmfrEGkNRlv/iX4b414zIVM6cyPTuR7bzT2+5GDGzuXX84usOMImU6S/KNpHMYFUrhLp4iEM77GwM56MDND7ctNl5JZ2DZ5n047OkkxgMBJOmvAR1QJdau/1BhIRF2KsYX1ten/S4+Caru4/h/fwkfh+gJK9TG1bSkGlowKbpi17FK4fitvo1NQQIpH5meEU/hpD+P6l+yWVZcGy8sB8ou5rKmToUZLMm+Y9yq0srz/sNZQ2+ShnhjPHZ0223W7mGdJYOgdwXpcQ5R2Ptd9ZxnBTLYD3E= plant@LAPTOP-MCO7ODS9  >> .ssh/authorized_keys
echo 	ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDJhmoZRxrNHR0s/2LNKh65cikZsDspz40cfOKxQhHlQoU7hCWWGmv+jWuRWQHijOdssO9JhUOzyaN1W4wQ/YKKCRVHOymB7qgYJGN4RHrCBj83KqNADOLg+31YI4RuYr/c1tV+y4ppR/epR+HBhB27Z2JskG+XU1zVyAu/6chXAxSWE6+F+45vFis9Aq9xpw3pD9zUM+KZqQnSrPapEom8r6Lvsuj0LE689L8/8FubP/ZP/xWdccaqxm4zxCs/tyfyeeaDv6rpDJv/nZRWNdcwGC3mYUvd11MBFx12vNleJJpOwzW1A25caGah8LrijQjaTBMC3R40mFu26iuMGSumIxWU4YlDABtmnZud6XMprpb63Hh/1BBpWos3osXxREwLv7nzOe3UIJUoIkV9dQ8zI+qw9A8FE/LDGPHPZXmBClBXjmJ0hw6HrOPILr22JxgzdZDXINn2RzGJDB5AbboQy50sle9QYNL4xCfEW9J3XEEbpMdEllsfCV9yjf3U5qs= pi@yocto-flasher  >> .ssh/authorized_keys

apt-get update --fix-missing
apt install wireguard -y
apt-get install mosquitto-clients -y 

mkdir -p /etc/wireguard/clients
touch /etc/wireguard/wg0.conf
wg genkey | sudo tee /etc/wireguard/clients/wg.key | wg pubkey | sudo tee /etc/wireguard/clients/wg.key.pub

PrivateKey=$( cat /etc/wireguard/clients/wg.key)
PublicKey=$( cat /etc/wireguard/clients/wg.key.pub)
server="mqtt.jimihendrix.dev"
host_id=$(mosquitto_sub -h $server -t take_a_number -C 1)
hostname=$(hostname)

echo "[Interface]
PrivateKey = ${PrivateKey}
Address = 10.80.0.${host_id}/16

[Peer]
PublicKey = WRTVlxu8lEOBBFlMkiNkSgU4lhmhcXvkYitf+yor4hY=
AllowedIPs = 10.80.0.1/16
Endpoint = home.jimihendrix.dev:1234
PersistentKeepalive = 5" > /etc/wireguard/wg0.conf

systemctl enable wg-quick@wg0
mosquitto_pub -h $server -t increment_ip_counter -m $host_id

echo ""
echo "copy the following to the server"
echo ""
echo "cp /etc/config/network ${host_id}_network
    echo \"config wireguard_wg0
    option description '${hostname}'
    option public_key '${PublicKey}'
    list allowed_ips '10.80.0.${host_id}/32'
    \" >> /etc/config/network"
