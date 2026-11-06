# Contenedor LXC con iptables y MV con Nginx

## Esquema

```
WAN (vmbr0, 192.168.111.0/24)
        |
      eth0  (DHCP, 192.168.111.34)
   [ Contenedor LXC - iptables ]
      eth1  (10.10.10.1/24)
        |
   LAN interna (vmbr1, 10.10.10.0/24)
        |
   [ MV - Nginx ]
      10.10.10.2/24, gateway 10.10.10.1
```

## Qué se ha hecho

1. Se creó el bridge `vmbr1` sin IP ni puertos para la red interna.
2. Se añadió `eth1` al contenedor con `10.10.10.1/24`, sin gateway. `eth0` conserva la IP por DHCP hacia la WAN.
3. Se configuró la MV con `10.10.10.2/24` y gateway `10.10.10.1`, en `vmbr1`.
4. Se configuró iptables en el contenedor para dar salida a internet a la MV y publicar el puerto 80 hacia la WAN.
5. Se hicieron persistentes las reglas y el reenvío de IP.

## Reglas de iptables (contenedor)

Activar el reenvío de paquetes:

```
sysctl -w net.ipv4.ip_forward=1
```

Tabla `nat`:

```
iptables -t nat -A POSTROUTING -o eth0 -s 10.10.10.0/24 -j MASQUERADE
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination 10.10.10.2:80
```

Cadena `FORWARD`:

```
iptables -A FORWARD -i eth0 -o eth1 -p tcp -d 10.10.10.2 --dport 80 -j ACCEPT
iptables -A FORWARD -i eth0 -o eth1 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
```

### Qué hace cada regla

| Regla | Función |
|---|---|
| `ip_forward=1` | Permite al contenedor reenviar paquetes entre `eth0` y `eth1`. |
| `POSTROUTING -o eth0 -s 10.10.10.0/24 -j MASQUERADE` | Enmascara el tráfico de la red interna con la IP de `eth0` para que la MV tenga salida a internet. |
| `PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination 10.10.10.2:80` | Redirige el puerto 80 que llega por `eth0` hacia Nginx en la MV. |
| `FORWARD -i eth0 -o eth1 -p tcp -d 10.10.10.2 --dport 80 -j ACCEPT` | Permite el tráfico nuevo de la WAN hacia Nginx. |
| `FORWARD -i eth0 -o eth1 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT` | Permite las respuestas de conexiones ya establecidas. |
| `FORWARD -i eth1 -o eth0 -j ACCEPT` | Permite que la MV inicie conexiones hacia fuera. |

## Persistencia

```
echo "net.ipv4.ip_forward=1" | tee /etc/sysctl.d/99-forward.conf
apt install -y iptables-persistent
netfilter-persistent save
```

## Comprobación

Desde el nodo Proxmox, que está en la misma red que `eth0`:

```
curl http://192.168.111.34
```

Resultado: se devuelve la página "Welcome to nginx!" servida por la MV a través del contenedor.

Para ver las reglas activas en el contenedor:

```
ip a
iptables -t nat -L -n -v
iptables -L FORWARD -n -v
```

## Notas

- `10.10.10.2` no es accesible directamente desde la WAN, solo a través de la IP de `eth0` del contenedor.
- Si el firewall de Proxmox está activo en `net0` (`firewall=1`), hay que permitir el puerto 80 de entrada o desactivarlo para la prueba.
