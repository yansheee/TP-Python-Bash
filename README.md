# TP Python / Bash - Audit de sécurité Linux

## Présentation

Ce projet a pour objectif de réaliser un script d'audit simple d'une machine Linux.

L'audit a été réalisé dans deux langages :

- Python
- Bash

Les deux versions effectuent plusieurs vérifications sur le système puis génèrent un rapport au format HTML.

## Fonctionnalités

Le script réalise plusieurs vérifications regroupées en différents modules.

### Réseau

- Récupération des interfaces réseau et des adresses IP
- Liste des ports TCP/UDP en écoute
- Vérification de l'IP Forwarding
- Détection de UFW ou nftables

### Permissions

- Vérification des permissions de `/etc/passwd`
- Vérification des permissions de `/etc/shadow`
- Vérification des permissions de `/etc/group`
- Recherche des fichiers world-writable dans `/etc`

### SSH

- Vérification de la présence et de la lecture de `/etc/ssh/sshd_config`
- Vérification de `PermitRootLogin`
- Vérification des permissions du fichier de configuration SSH
- Vérification des restrictions `AllowUsers` et `AllowGroups`

### Mises à jour

- Nombre de mises à jour disponibles
- Nombre de mises à jour de sécurité
- Version du système
- Date de fin de vie du système
- Vérification des mises à jour automatiques
- Âge du cache APT
- Recherche des paquets en échec d'installation

## Structure du projet

```text
TP-Python-Bash/
│
├── modules/
│   ├── network.py
│   ├── network.sh
│   ├── permissions.py
│   ├── permissions.sh
│   ├── ssh.py
│   ├── ssh.sh
│   ├── update.py
│   └── update.sh
│
├── script.py
├── script.sh
├── styles.css
├── report.html
└── README.md