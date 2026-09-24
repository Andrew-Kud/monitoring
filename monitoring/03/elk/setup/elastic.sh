#!/usr/bin/env bash
set -euo pipefail

ES="https://es-hot:9200"
CA="/certs/ca.crt"

es() {
  local args=(-sS --fail-with-body --cacert "$CA" -u "elastic:${ELASTIC_PASSWORD}"
              -H 'Content-Type: application/json' -X "$1" "${ES}$2")
  if [[ -n "${3:-}" ]]; then args+=(-d "$3"); fi
  curl "${args[@]}"; echo
}

echo "== Waiting for cluster (yellow+)"
until curl -sf --cacert "$CA" -u "elastic:${ELASTIC_PASSWORD}" \
      "${ES}/_cluster/health?wait_for_status=yellow&timeout=10s" >/dev/null; do
  sleep 5
done

echo "== kibana_system password"
es POST /_security/user/kibana_system/_password "{\"password\":\"${KIBANA_PASSWORD}\"}"

echo "== Role logstash_writer (least privilege: только создание документов/индексов logstash-*)"
es PUT /_security/role/logstash_writer '{
  "cluster": ["monitor"],
  "indices": [{
    "names": ["logstash-*"],
    "privileges": ["create_doc", "create_index", "auto_configure"]
  }]
}'

echo "== User logstash_internal"
es PUT /_security/user/logstash_internal "{
  \"password\": \"${LOGSTASH_INTERNAL_PASSWORD}\",
  \"roles\": [\"logstash_writer\"],
  \"full_name\": \"Logstash writer\"
}"

echo "== ILM policy: hot -> warm (через 1d) -> delete (через 14d)"
es PUT /_ilm/policy/logstash-policy '{
  "policy": {
    "phases": {
      "hot":    { "min_age": "0ms", "actions": { "set_priority": { "priority": 100 } } },
      "warm":   { "min_age": "1d",  "actions": { "set_priority": { "priority": 50 } } },
      "delete": { "min_age": "14d", "actions": { "delete": {} } }
    }
  }
}'

echo "== Index template logstash-*"
es PUT /_index_template/logstash '{
  "index_patterns": ["logstash-*"],
  "priority": 200,
  "template": {
    "settings": {
      "number_of_shards": 1,
      "number_of_replicas": 0,
      "index.lifecycle.name": "logstash-policy",
      "index.routing.allocation.include._tier_preference": "data_hot"
    }
  }
}'

echo "__Setup done__"
