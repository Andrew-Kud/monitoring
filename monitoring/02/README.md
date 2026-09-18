### Средство визуализации Grafana

---

1.


---

2.

Утилизация CPU для nodeexporter (в процентах, 100-idle).
PromQL: `100 - (avg by (instance) (rate(node_cpu_seconds_total{job="nodeexporter", mode="idle"}[5m])) * 100)`
Unit: `Percent (0-100)`

CPULA 1/5/15.
PromQL: A `node_load1{job="nodeexporter"}`
PromQL: B `node_load5{job="nodeexporter"}`
PromQL: C `node_load15{job="nodeexporter"}`
Unit: `short / none`

Кол-во свободной ОЗУ.
PromQL: `node_memory_MemAvailable_bytes`
Unit: `bytes (IEC)`

Кол-во свободной ПЗУ.
PromQL: `node_filesystem_avail_bytes{mountpoint="/", fstype!~"tmpfs|overlay|squashfs"}`
Unit: `bytes (IEC)`



---

3.



---

4.



---
---