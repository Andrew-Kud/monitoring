#!/usr/bin/env bash

set -euo pipefail
cd "$(dirname "$0")/.."

STACK_VERSION="9.5.4"
CERTS="certs"
CA_DAYS=1825
CERT_DAYS=825

# .env
if [[ ! -f .env ]]; then
  umask 077
  cat > .env <<EOF
STACK_VERSION=${STACK_VERSION}
ES_HEAP=1g
ES_MEM_LIMIT=2g
KIBANA_MEM_LIMIT=1536m
LS_MEM_LIMIT=1g
ELASTIC_PASSWORD=$(openssl rand -hex 16)
KIBANA_PASSWORD=$(openssl rand -hex 16)
LOGSTASH_INTERNAL_PASSWORD=$(openssl rand -hex 16)
KIBANA_ENC_KEY_SO=$(openssl rand -hex 32)
KIBANA_ENC_KEY_SEC=$(openssl rand -hex 32)
KIBANA_ENC_KEY_REP=$(openssl rand -hex 32)
EOF
  echo "[+] .env создан (chmod 600)"
fi

# CA + .crt
mkdir -p "$CERTS/ca"
if [[ ! -f "$CERTS/ca/ca.crt" ]]; then
  (umask 077; openssl req -x509 -newkey rsa:4096 -sha256 -nodes -days "$CA_DAYS" \
    -keyout "$CERTS/ca/ca.key" -out "$CERTS/ca/ca.crt" -subj "/CN=ELK Lab CA" \
    -addext "basicConstraints=critical,CA:TRUE" \
    -addext "keyUsage=critical,keyCertSign,cRLSign")
  echo "[+] CA создан"
fi

# SAN DNS
issue() {
  local name=$1 san=$2 d="$CERTS/$1"
  if [[ -f "$d/$name.crt" ]]; then echo "[=] $name: уже есть"; return; fi
  mkdir -p "$d"
  (umask 077; openssl req -newkey rsa:2048 -nodes -sha256 \
    -keyout "$d/$name.key" -out "$d/$name.csr" -subj "/CN=$name")
  openssl x509 -req -sha256 -days "$CERT_DAYS" -in "$d/$name.csr" \
    -CA "$CERTS/ca/ca.crt" -CAkey "$CERTS/ca/ca.key" \
    -CAserial "$CERTS/ca/ca.srl" -CAcreateserial -out "$d/$name.crt" \
    -extfile <(printf '%s\n' \
      "subjectAltName=$san" \
      "basicConstraints=CA:FALSE" \
      "keyUsage=critical,digitalSignature,keyEncipherment" \
      "extendedKeyUsage=serverAuth,clientAuth")
  rm -f "$d/$name.csr"
  echo "[+] $name: выпущен"
}

issue es-hot     "DNS:es-hot,DNS:localhost,IP:127.0.0.1"
issue es-warm    "DNS:es-warm,DNS:localhost,IP:127.0.0.1"
issue kibana     "DNS:kibana,DNS:localhost,IP:127.0.0.1"
issue logstash   "DNS:logstash,DNS:localhost,IP:127.0.0.1"
issue filebeat   "DNS:filebeat"
issue tcp-client "DNS:tcp-client"

# Data dir.
mkdir -p data/es-hot data/es-warm data/kibana data/logstash data/filebeat

# Permissions.
echo "[*] Выставляю владельцев (sudo)"
sudo chown -R 1000:0 "$CERTS" data/es-hot data/es-warm data/kibana data/logstash
sudo find "$CERTS" -type d -exec chmod 750 {} +
sudo find "$CERTS" -name '*.crt' -exec chmod 644 {} +
sudo find "$CERTS" -name '*.key' -exec chmod 640 {} +
sudo chown root:root "$CERTS/ca/ca.key" && sudo chmod 600 "$CERTS/ca/ca.key"
sudo chmod -R g+rwX data/es-hot data/es-warm data/kibana data/logstash
sudo chown -R root:root data/filebeat config/filebeat/filebeat.yml
sudo chmod 700 data/filebeat
sudo chmod 644 config/filebeat/filebeat.yml
chmod 600 .env

# memory-map
cur=$(sysctl -n vm.max_map_count)
if (( cur < 262144 )); then
  echo 'vm.max_map_count=262144' | sudo tee /etc/sysctl.d/99-elasticsearch.conf >/dev/null
  sudo sysctl -p /etc/sysctl.d/99-elasticsearch.conf
else
  echo "[=] vm.max_map_count=$cur (__enough__)"
fi

echo "[OK] Next: docker compose config -q && docker compose up -d"
