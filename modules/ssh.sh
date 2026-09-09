#!/bin/bash

CONFIG="${1:-/etc/ssh/sshd_config}"
resultats_ssh=()

if [ -r "$CONFIG" ]; then
    resultats_ssh+=("[OK] Fichier de configuration trouvé : $CONFIG")
else
    resultats_ssh+=("[FAIL] Fichier de configuration introuvable ou illisible : $CONFIG")
fi

PERMIT_ROOT=$(grep -E "^\s*PermitRootLogin\s" "$CONFIG" 2>/dev/null | awk '{print $2}')

if [ -z "$PERMIT_ROOT" ]; then
    resultats_ssh+=("[INFO] PermitRootLogin non défini dans le fichier (valeur par défaut OpenSSH : prohibit-password)")
elif [ "$PERMIT_ROOT" = "yes" ]; then
    resultats_ssh+=("[FAIL] PermitRootLogin est activé (connexion root directe autorisée)")
else
    resultats_ssh+=("[OK] PermitRootLogin est restreint : $PERMIT_ROOT")
fi

if [ -e "$CONFIG" ]; then
    PERMISSIONS=$(stat -c '%A %U:%G' "$CONFIG")
    GROUPE_ECRITURE=$(stat -c '%A' "$CONFIG" | cut -c6)
    AUTRES_ECRITURE=$(stat -c '%A' "$CONFIG" | cut -c9)

    if [ "$GROUPE_ECRITURE" = "w" ] || [ "$AUTRES_ECRITURE" = "w" ]; then
        resultats_ssh+=("[FAIL] Permissions de $CONFIG : $PERMISSIONS (modifiable par le groupe ou par tout le monde)")
    else
        resultats_ssh+=("[OK] Permissions de $CONFIG : $PERMISSIONS (seul le propriétaire peut modifier)")
    fi
else
    resultats_ssh+=("[ERROR] Impossible de vérifier les permissions : fichier introuvable")
fi

ALLOW_USERS=$(grep -E "^\s*AllowUsers\s" "$CONFIG" 2>/dev/null | cut -d' ' -f2-)
ALLOW_GROUPS=$(grep -E "^\s*AllowGroups\s" "$CONFIG" 2>/dev/null | cut -d' ' -f2-)

if [ -z "$ALLOW_USERS" ] && [ -z "$ALLOW_GROUPS" ]; then
    resultats_ssh+=("[INFO] Aucune restriction AllowUsers/AllowGroups définie (tous les utilisateurs sont autorisés par défaut)")
else
    resultats_ssh+=("[OK] AllowUsers : ${ALLOW_USERS:-non défini} | AllowGroups : ${ALLOW_GROUPS:-non défini}")
fi

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    for ligne in "${resultats_ssh[@]}"; do
        echo "$ligne"
    done
fi
