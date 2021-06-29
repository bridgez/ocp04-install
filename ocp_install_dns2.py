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

; The syntax is "last octet" and the host must have an FQDN
; with a trailing dot.
{{haproxy_lastip}}     IN      PTR     {haproxy}.{{cluster}}.nip.io.
{{bootstrap_lastip}}     IN      PTR     {bootstrap}.{{cluster}}.nip.io.
{{master0_lastip}}     IN      PTR     {master0}.{{cluster}}.nip.io.
{{master1_lastip}}      IN      PTR     {master1}.{{cluster}}.nip.io.
{{master2_lastip}}      IN      PTR     {master2}.{{cluster}}.nip.io.
{{master0_lastip}}      IN      PTR     etcd-0.{{cluster}}.nip.io.
{{master1_lastip}}      IN      PTR     etcd-1.{{cluster}}.nip.io.
{{master2_lastip}}      IN      PTR     etcd-2.{{cluster}}.nip.io.
;
;
{{haproxy_lastip}}    IN      PTR     api.{{cluster}}.nip.io.
{{haproxy_lastip}}    IN      PTR     api-int.{{cluster}}.nip.io.
{{haproxy_lastip}}    IN      PTR     {{cluster}}.nip.io.



    ''')

dic_dns=ocp_install_dic.dic_dns
print(template.render(dic_dns))
ocp_path='/tmp/'+dic_dns['cluster']
dns_rev=open(ocp_path+"/nip.io.rev","w")
dns_rev.write(template.render(dic_dns))
dns_rev.close()
