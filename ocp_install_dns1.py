#!/usr/bin/env python3
import subprocess, ocp_install_dic, os
from jinja2 import Template
template=Template('''
$TTL 1W
@       IN      SOA     {{dns_server_fqdn}}. root (
                        2020070700      ; serial
                        3H              ; refresh (3 hours)
                        30M             ; retry (30 minutes)
                        2W              ; expiry (2 weeks)
                        1W )            ; minimum (1 week)
        IN      NS      {{dns_server_fqdn}}.

{{dns_server_fqdn}}. IN      A       {{dns_server_ip}}

;DNS,api,apps

; Proxy item.
; The api identifies the IP of your load balancer.
api.{{cluster}}             IN      A       {{haproxy_ip}}
api-int.{{cluster}}         IN      A       {{haproxy_ip}}
;
; The wildcard also identifies the load balancer.
{{cluster}}                 IN      A       {{haproxy_ip}}
*.apps.{{cluster}}          IN      A       {{haproxy_ip}}
{{haproxy}}.{{cluster}}         IN      A       {{haproxy_ip}}
;
; Create an entry for the bootstrap host.
{{bootstrap}}.{{cluster}} IN      A       {{bootstrap_ip}}
;
; Create entries for the master hosts.
{{master0}}.{{cluster}}         IN      A       {{master0_ip}}
{{master1}}.{{cluster}}         IN      A       {{master1_ip}}
{{master2}}.{{cluster}}         IN      A       {{master2_ip}}

etcd-0.{{cluster}}          IN      A       {{master0_ip}}
etcd-1.{{cluster}}          IN      A       {{master1_ip}}
etcd-2.{{cluster}}          IN      A       {{master2_ip}}
_etcd-server-ssl._tcp.{{cluster}} 86400 IN SRV 0 10  2380 etcd-0.{{cluster}}
_etcd-server-ssl._tcp.{{cluster}} 86400 IN SRV 0 10  2380 etcd-1.{{cluster}}
_etcd-server-ssl._tcp.{{cluster}} 86400 IN SRV 0 10  2380 etcd-2.{{cluster}}
; Create entries for the worker hosts.

    ''')

dic_dns=ocp_install_dic.dic_dns
print(template.render(dic_dns))
ocp_path='/tmp/'+dic_dns['cluster']
if os.path.exists(ocp_path)==False:
    os.mkdir(ocp_path)
dns_zone=open(ocp_path+"/nip.io.zone","w")
dns_zone.write(template.render(dic_dns))
dns_zone.close()
