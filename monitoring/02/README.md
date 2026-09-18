### Средство визуализации Grafana

---

1.

<img width="2560" height="1439" alt="1-1" src="https://github.com/user-attachments/assets/ec6021b4-e82d-4cbd-bd1f-ca2a88b5b443" />

<img width="2558" height="513" alt="1-2" src="https://github.com/user-attachments/assets/5956342b-66dc-4e73-a817-95811912c034" />


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

<img width="2557" height="874" alt="2" src="https://github.com/user-attachments/assets/ae215d62-0454-45b6-a236-a70cadaf35d6" />


---

3.

<img width="1148" height="801" alt="3" src="https://github.com/user-attachments/assets/e79d06b7-63a5-4d4c-aba5-7b26f08ba16b" />

<img width="2554" height="820" alt="3-1" src="https://github.com/user-attachments/assets/0c91423b-385d-4b71-96e6-f1f0faed7eff" />


---
---
