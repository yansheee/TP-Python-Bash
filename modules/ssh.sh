#!/bin/bash

CONFIG="${1:-/etc/ssh/sshd_config}"

if [ -r "$CONFIG" ]; then
    echo "[OK] Fichier de configuration trouvé : $CONFIG"
else
    echo "[FAIL] Fichier de configuration introuvable ou illisible : $CONFIG"
fi
