#!/bin/bash

CONFIG="${1:-/etc/ssh/sshd_config}"

if [ -r "$CONFIG" ]; then
    echo "[OK] Fichier de configuration trouvé : $CONFIG"
else
    echo "[FAIL] Fichier de configuration introuvable ou illisible : $CONFIG"
fi

PERMIT_ROOT=$(grep -E "^\s*PermitRootLogin\s" "$CONFIG" 2>/dev/null | awk '{print $2}')

if [ -z "$PERMIT_ROOT" ]; then
    echo "[INFO] PermitRootLogin non défini dans le fichier (valeur par défaut OpenSSH : prohibit-password)"
elif [ "$PERMIT_ROOT" = "yes" ]; then
    echo "[FAIL] PermitRootLogin est activé (connexion root directe autorisée)"
else
    echo "[OK] PermitRootLogin est restreint : $PERMIT_ROOT"
fi

if [ -e "$CONFIG" ]; then
    PERMISSIONS=$(stat -c '%A %U:%G' "$CONFIG")
    GROUPE_ECRITURE=$(stat -c '%A' "$CONFIG" | cut -c6)
    AUTRES_ECRITURE=$(stat -c '%A' "$CONFIG" | cut -c9)

    echo "[INFO] Permissions de $CONFIG : $PERMISSIONS"

    if [ "$GROUPE_ECRITURE" = "w" ] || [ "$AUTRES_ECRITURE" = "w" ]; then
        echo "[FAIL] Le fichier est modifiable par le groupe ou par tout le monde"
    else
        echo "[OK] Seul le propriétaire peut modifier le fichier"
    fi
else
    echo "[ERROR] Impossible de vérifier les permissions : fichier introuvable"
fi

ALLOW_USERS=$(grep -E "^\s*AllowUsers\s" "$CONFIG" 2>/dev/null | cut -d' ' -f2-)
ALLOW_GROUPS=$(grep -E "^\s*AllowGroups\s" "$CONFIG" 2>/dev/null | cut -d' ' -f2-)

if [ -z "$ALLOW_USERS" ] && [ -z "$ALLOW_GROUPS" ]; then
    echo "[INFO] Aucune restriction AllowUsers/AllowGroups définie (tous les utilisateurs sont autorisés par défaut)"
else
    if [ -n "$ALLOW_USERS" ]; then
        echo "[OK] AllowUsers défini : $ALLOW_USERS"
    fi
    if [ -n "$ALLOW_GROUPS" ]; then
        echo "[OK] AllowGroups défini : $ALLOW_GROUPS"
    fi
fi
