from modules.network import network
from modules.permissions import permissions


html = f"""
<html>
<head>
    <title>Rapport d'audit</title>
</head>

<body>

<h1>Rapport d'audit de sécurité</h1>

<h2>Réseau</h2>

<p><b>Interfaces :</b></p>
<pre>{network["interfaces"]}</pre>

<p><b>Ports :</b></p>
<pre>{network["ports"]}</pre>

<p><b>IP Forwarding :</b> {network["ip_forwarding"]}</p>

<p><b>Firewall :</b> {network["firewall"]}</p>


<h2>Permissions</h2>

<p><b>/etc/passwd :</b> {permissions["passwd"]}</p>

<p><b>/etc/shadow :</b> {permissions["shadow"]}</p>

<p><b>/etc/group :</b> {permissions["group"]}</p>

<p><b>Fichiers world-writable :</b></p>
<pre>{permissions["world_writable"]}</pre>

<p><b>Fichiers SUID :</b></p>
<pre>{permissions["suid"]}</pre>

<h2>SSH</h2>

<h2>Updates</h2>

</body>
</html>
"""

with open("report.html", "w") as f:
    f.write(html)

print("Rapport généré : report.html")