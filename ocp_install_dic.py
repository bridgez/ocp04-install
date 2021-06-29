#/usr/bin/env python3
import shutil,os
if os.path.exists('/tmpa')==False:
    print("yes")

dic_dns={
    'cluster':'ocp04',
    'dns_server_fqdn':'node34.ocp04.nip.io',
    'dns_server_ip':'10.0.0.1',
    'haproxy_ip': '10.0.0.155',
    'haproxy': 'node155',
    'bootstrap': 'node159',
    'bootstrap_ip': '10.0.0.159',
    'master0_ip': '10.0.0.160',
    'master1_ip': '10.0.0.161',
    'master2_ip': '10.0.0.162',
    'master0': 'node160',
    'master1': 'node161',
    'master2': 'node162',
    'haproxy_lastip':'155',
    'bootstrap_lastip':'159',
    'master0_lastip':'160',
    'master1_lastip':'161',
    'master2_lastip':'162'
    }
