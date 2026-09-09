#!/bin/bash

source modules/network.sh
source modules/permissions.sh
source modules/update.sh
source modules/ssh.sh



cat > report.html <<EOF
<html>
<head>
    <title>Rapport d'audit</title>
    <link rel="stylesheet" href="styles.css">
</head>

<body>

<h1>Rapport d'audit de sécurité</h1>

<h2>Réseau</h2>

<p><b>Interfaces :</b></p>
<pre>${network["interfaces"]}</pre>

<p><b>Ports :</b></p>
<pre>${network["ports"]}</pre>

<p><b>IP Forwarding :</b> ${network["ip_forwarding"]}</p>

<p><b>Firewall :</b> ${network["firewall"]}</p>


<h2>Permissions</h2>

<p><b>/etc/passwd :</b> ${permissions["passwd"]}</p>
<p><b>/etc/shadow :</b> ${permissions["shadow"]}</p>
<p><b>/etc/group :</b> ${permissions["group"]}</p>

<p><b>Fichiers world-writable :</b></p>
<pre>${permissions["world_writable"]}</pre>

<h2>Updates</h2>

<p><b>Mises à jour de sécurité en attente :</b> ${update["nb_maj_securite"]}</p>
<pre>${update["maj_securite"]}</pre>

<p><b>Mises à jour totales en attente :</b> ${update["nb_maj_totales"]}</p>

<p><b>Version du système :</b> ${update["codename"]}</p>

<p><b>Date de fin de vie :</b> ${update["date_fin_de_vie"]}</p>

<p><b>Système obsolète :</b> ${update["systeme_obsolete"]}</p>

<p><b>Mises à jour automatiques :</b> ${update["auto_maj"]}</p>

<p><b>Âge du cache apt (jours) :</b> ${update["age_cache_jours"]}</p>

<p><b>Nombre de paquets en échec d'installation :</b> ${update["nb_echecs_installation"]}</p>
<pre>${update["echecs_installation"]}</pre>

<h2>SSH</h2>

<p><b>Vérification 1 : fichier de configuration trouvé et lisible :</b> ${resultats_ssh[0]}</p>
<p><b>Vérification 2 : PermitRootLogin :</b> ${resultats_ssh[1]}</p>
<p><b>Vérification 3 : permissions du fichier de configuration :</b> ${resultats_ssh[2]}</p>
<p><b>Vérification 4 : utilisateurs/groupes autorisés (AllowUsers/AllowGroups) :</b> ${resultats_ssh[3]}</p>


</body>
</html>
EOF

echo "Rapport généré : report.html"
