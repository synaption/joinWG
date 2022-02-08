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
echo "echo \"cp /etc/config/network ${host_id}_network
    config wireguard_wg0
    option description '${hostname}'
    option public_key '${PublicKey}'
    list allowed_ips '10.80.0.${host_id}/32'
    \" >> /etc/config/network"
