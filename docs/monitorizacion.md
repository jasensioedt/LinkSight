# Monitorización con Grafana y Prometheus

## Esquema

```
                 Host Proxmox (192.168.135.58)
                 API :8006
                        ^
                        | pve-exporter (token PVEAuditor)
                        |
WAN (vmbr0) ---- eth0 [ linksightCT - router iptables ] eth1 (10.10.10.1)
                        |  node_exporter :9100
                        |  script de métricas iptables
                        |
              LAN interna (vmbr1, 10.10.10.0/24)
                        |
              [ LXC Grafana - Alpine ] 10.10.10.5
                 Grafana :3000
                 Prometheus :9090
                 pve-exporter :9221
```

| Máquina | IP | Servicios |
|---|---|---|
| Host Proxmox | 192.168.135.58 | API de Proxmox (8006) |
| linksightCT (router) | eth0 WAN · 10.10.10.1 | iptables, node_exporter (9100) |
| LXC Grafana | 10.10.10.5 | Grafana (3000), Prometheus (9090), pve-exporter (9221) |

## Qué se ha hecho

1. Se creó en Proxmox un usuario `prometheus@pve` con un token de solo lectura (rol `PVEAuditor`).
2. Se creó el LXC de Grafana con el script de community-scripts sobre Alpine, conectado a `vmbr1` con IP `10.10.10.5`.
3. En el LXC de Grafana se instalaron Prometheus y pve-exporter, que lee de la API de Proxmox el uso de CPU, RAM, disco y red del nodo y de cada VM y contenedor.
4. En el router `linksightCT` se instaló node_exporter y un script que convierte los contadores de iptables en métricas.
5. Se añadieron reglas en el router para que Prometheus pueda leer el puerto 9100 y para publicar Grafana en el puerto 3000.
6. Se importaron dos dashboards en Grafana: Proxmox (ID 10347) y Firewall linksightCT (propio).

## 1. Token de la API (host Proxmox)

```
pveum user add prometheus@pve
pveum aclmod / -user prometheus@pve -role PVEAuditor
pveum user token add prometheus@pve monitoring --privsep 0
```

Se guarda el campo `value` que devuelve el último comando, porque solo se muestra una vez.

## 2. LXC de Grafana

Desde el host Proxmox:

```
var_os='alpine' bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/grafana.sh)"
```

En modo **Advanced** se configuró:

| Opción | Valor |
|---|---|
| Bridge | `vmbr1` |
| IP | `10.10.10.5/24` |
| Gateway | `10.10.10.1` |
| RAM | 1024 MB |

## 3. Prometheus y pve-exporter (LXC Grafana)

```
sed -i 's/^#\(.*\/community\)$/\1/' /etc/apk/repositories
apk update
apk add prometheus python3 py3-pip
python3 -m venv /opt/pve-exporter
/opt/pve-exporter/bin/pip install prometheus-pve-exporter
```

Credenciales de la API en `/etc/prometheus/pve.yml` (permisos `600`):

```
default:
  user: prometheus@pve
  token_name: "monitoring"
  token_value: "TOKEN"
  verify_ssl: false
```

Servicio OpenRC en `/etc/init.d/pve-exporter`:

```
#!/sbin/openrc-run
name="pve-exporter"
command="/opt/pve-exporter/bin/pve_exporter"
command_args="--config.file /etc/prometheus/pve.yml"
command_background=true
pidfile="/run/${RC_SVCNAME}.pid"
depend() {
  need net
}
```

Configuración de Prometheus en `/etc/prometheus/prometheus.yml`:

```
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: prometheus
    static_configs:
      - targets: ['localhost:9090']

  - job_name: pve
    metrics_path: /pve
    params:
      module: [default]
      cluster: ['1']
      node: ['1']
    static_configs:
      - targets: ['192.168.135.58']
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: 127.0.0.1:9221

  - job_name: firewall
    static_configs:
      - targets: ['10.10.10.1:9100']
        labels:
          host: linksightCT
```

Arranque de los servicios:

```
chmod +x /etc/init.d/pve-exporter
rc-update add pve-exporter default
rc-update add prometheus default
rc-service pve-exporter start
rc-service prometheus restart
```

## 4. Métricas de iptables (router linksightCT)

```
apt install -y prometheus-node-exporter
mkdir -p /var/lib/prometheus/node-exporter
echo 'ARGS="--collector.textfile.directory=/var/lib/prometheus/node-exporter"' > /etc/default/prometheus-node-exporter
```

node_exporter no trae métricas de iptables, así que se usa su *textfile collector*: un script lee `iptables -L -v -n -x` cada minuto y escribe los contadores en un fichero `.prom` que node_exporter publica.

Script `/usr/local/bin/iptables-metrics.sh`:

```
#!/bin/bash
OUT=/var/lib/prometheus/node-exporter/iptables.prom
TMP=$OUT.$$
{
echo "# TYPE iptables_policy_packets_total counter"
echo "# TYPE iptables_policy_bytes_total counter"
echo "# TYPE iptables_rule_packets_total counter"
echo "# TYPE iptables_rule_bytes_total counter"
for t in filter nat; do
  /usr/sbin/iptables -t $t -L -v -n -x --line-numbers | awk -v tb=$t '
  /^Chain/ { chain=$2
    if ($3=="(policy") {
      printf "iptables_policy_packets_total{table=\"%s\",chain=\"%s\",policy=\"%s\"} %s\n", tb, chain, $4, $5
      printf "iptables_policy_bytes_total{table=\"%s\",chain=\"%s\",policy=\"%s\"} %s\n", tb, chain, $4, $7
    }
    next }
  /^[0-9]/ {
    dpt=""; to=""; st=""
    for (i=11;i<=NF;i++) {
      if ($i ~ /^dpts?:/) { split($i,a,":"); dpt=a[2] }
      if ($i ~ /^to:/) to=substr($i,4)
      if (($i=="ctstate" || $i=="state") && i<NF) st=$(i+1)
    }
    ifin=($7=="*")?"any":$7; ifout=($8=="*")?"any":$8
    d=ifin" → "ifout
    if ($9!="0.0.0.0/0") d=d" desde "$9
    if ($10!="0.0.0.0/0") d=d" hacia "$10
    if (dpt!="") d=d" :"dpt
    if (st!="") d=d" ("st")"
    if (to!="") d=d" ⇒ "to
    l=sprintf("table=\"%s\",chain=\"%s\",rule=\"%s\",target=\"%s\",prot=\"%s\",in=\"%s\",out=\"%s\",src=\"%s\",dst=\"%s\",dport=\"%s\",state=\"%s\",to=\"%s\",desc=\"%s\"", tb, chain, $1, $4, $5, ifin, ifout, $9, $10, dpt, st, to, d)
    printf "iptables_rule_packets_total{%s} %s\n", l, $2
    printf "iptables_rule_bytes_total{%s} %s\n", l, $3
  }'
done
} > $TMP && mv $TMP $OUT
```

Ejecución cada minuto:

```
chmod +x /usr/local/bin/iptables-metrics.sh
echo '* * * * * root /usr/local/bin/iptables-metrics.sh' > /etc/cron.d/iptables-metrics
systemctl enable --now prometheus-node-exporter
```

### Métricas que genera

| Métrica | Qué cuenta |
|---|---|
| `iptables_policy_packets_total` / `_bytes_total` | Paquetes y bytes que acaban en la política por defecto de cada cadena. Con `policy="DROP"` son los **paquetes bloqueados**. |
| `iptables_rule_packets_total` / `_bytes_total` | Paquetes y bytes que coinciden con cada regla. |

Etiquetas de cada regla: `table`, `chain`, `rule` (número), `target` (acción), `prot`, `in`, `out`, `src`, `dst`, `dport`, `state`, `to` (destino del DNAT) y `desc` (descripción legible, por ejemplo `eth0 → eth1 hacia 10.10.10.2 :80`).

## 5. Reglas añadidas en el router

```
iptables -I INPUT -i eth1 -s 10.10.10.5 -p tcp --dport 9100 -j ACCEPT
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 3000 -j DNAT --to-destination 10.10.10.5:3000
iptables -A FORWARD -i eth0 -o eth1 -p tcp -d 10.10.10.5 --dport 3000 -j ACCEPT
netfilter-persistent save
```

| Regla | Función |
|---|---|
| `INPUT -i eth1 -s 10.10.10.5 --dport 9100 -j ACCEPT` | Solo Prometheus puede leer las métricas del router. Se inserta con `-I` para que quede antes de cualquier DROP. |
| `PREROUTING -i eth0 --dport 3000 -j DNAT --to-destination 10.10.10.5:3000` | Publica Grafana en el puerto 3000 de la IP WAN del router. |
| `FORWARD -i eth0 -o eth1 -d 10.10.10.5 --dport 3000 -j ACCEPT` | Permite el tráfico nuevo de la WAN hacia Grafana. |

## 6. Grafana

Acceso: `http://<IP eth0 del router>:3000`.

1. Datasource: *Connections → Data sources → Prometheus*, URL `http://localhost:9090`.
2. Dashboard de Proxmox: *Dashboards → Import*, ID `10347`. Muestra CPU, RAM, disco y red del nodo y de cada VM y contenedor.
3. Dashboard del firewall: *Dashboards → Import*, subir [`grafana/firewall-linksightCT.json`](grafana/firewall-linksightCT.json).

### Dashboard Firewall linksightCT

| Fila | Panel | Visualización |
|---|---|---|
| Resumen 24 h | Bloqueados en INPUT, bloqueados en FORWARD, conexiones a la web, conexiones a Grafana | Stat |
| Bloqueos y publicaciones | Paquetes bloqueados cada 5 min por cadena | Barras apiladas |
| | Reparto de conexiones publicadas (Web / Grafana) | Donut |
| Tráfico | Tráfico de `eth0` y `eth1` (entrada arriba, salida abajo) | Área |
| | Salida a internet de la red interna (MASQUERADE) | Área |
| Reglas | Reglas FORWARD con más tráfico | Bar gauge |
| | Top 10 reglas por paquetes | Tabla |

Consultas principales:

```
sum by (chain) (increase(iptables_policy_packets_total{job="firewall",policy="DROP"}[24h]))
sum by (dport, to) (increase(iptables_rule_packets_total{job="firewall",table="nat",target="DNAT"}[24h]))
topk(6, sum by (rule, desc) (increase(iptables_rule_bytes_total{job="firewall",desc!="",chain="FORWARD",target="ACCEPT"}[24h])))
```

## Comprobación

Desde el LXC de Grafana:

```
wget -qO- "localhost:9221/pve?target=192.168.135.58" | head
wget -qO- 10.10.10.1:9100/metrics | grep -c iptables_
wget -qO- localhost:9090/api/v1/targets | grep -oE '"scrapeUrl":"[^"]*"|"health":"[a-z]*"'
```

Resultado: los tres targets (`prometheus`, `pve` y `firewall`) aparecen con `"health":"up"`.

## Notas

- **INPUT y FORWARD:** los bloqueos de INPUT son paquetes dirigidos al propio router (broadcasts, escaneos, pings de la red de clase). FORWARD casi no bloquea, porque desde la WAN no hay ruta directa a `10.10.10.0/24`: lo que no pasa por DNAT va dirigido al router y cae en INPUT.
- **Contadores DNAT:** la tabla `nat` solo ve el primer paquete de cada conexión, así que su contador es de **conexiones**, no de paquetes.
- **Reinicios:** los contadores de iptables se ponen a cero al reiniciar el router o al recargar las reglas. `increase()` y `rate()` lo tienen en cuenta, así que las gráficas no se rompen.
- **Cambios en el script:** si se modifican las etiquetas, durante 24 h conviven series viejas y nuevas. Por eso las consultas de reglas filtran con `desc!=""`.
- **Firewall de Proxmox:** si está activo en la interfaz del router, hay que permitir el puerto 3000 de entrada.
