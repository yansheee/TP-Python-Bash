import os
import stat
import sys

def chercher_valeur(nom_parametre, lignes):
    for ligne in lignes:
        ligne = ligne.strip()
        if ligne.startswith(nom_parametre + " "):
            mots = ligne.split()
            return " ".join(mots[1:])
    return None

def run_ssh_audit(config_path="/etc/ssh/sshd_config"):
    # Vérification 1 : le fichier de configuration existe-t-il et est-il lisible ?
    lignes = []

    try:
        with open(config_path, "r") as fichier:
            lignes = fichier.readlines()
        print("[OK] Fichier de configuration trouvé :", config_path)
    except FileNotFoundError:
        print("[FAIL] Fichier de configuration introuvable :", config_path)
    except PermissionError:
        print("[ERROR] Droits insuffisants pour lire :", config_path)

    # Vérification 2 : PermitRootLogin
    permit_root_login = chercher_valeur("PermitRootLogin", lignes)

    if permit_root_login is None:
        print("[INFO] PermitRootLogin non défini dans le fichier (valeur par défaut OpenSSH : prohibit-password)")
    elif permit_root_login == "yes":
        print("[FAIL] PermitRootLogin est activé (connexion root directe autorisée)")
    else:
        print("[OK] PermitRootLogin est restreint :", permit_root_login)

    # Vérification 3 : permissions et propriétaire du fichier de configuration
    try:
        info_fichier = os.stat(config_path)
        mode = info_fichier.st_mode
        permissions_texte = stat.filemode(mode)

        print("[INFO] Permissions de", config_path, ":", permissions_texte)

        if mode & stat.S_IWGRP or mode & stat.S_IWOTH:
            print("[FAIL] Le fichier est modifiable par le groupe ou par tout le monde")
        else:
            print("[OK] Seul le propriétaire peut modifier le fichier")
    except FileNotFoundError:
        print("[ERROR] Impossible de vérifier les permissions : fichier introuvable")

    # Vérification 4 : quels utilisateurs/groupes sont explicitement autorisés ?
    allow_users = chercher_valeur("AllowUsers", lignes)
    allow_groups = chercher_valeur("AllowGroups", lignes)

    if allow_users is None and allow_groups is None:
        print("[INFO] Aucune restriction AllowUsers/AllowGroups définie (tous les utilisateurs sont autorisés par défaut)")
    else:
        if allow_users:
            print("[OK] AllowUsers défini :", allow_users)
        if allow_groups:
            print("[OK] AllowGroups défini :", allow_groups)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        run_ssh_audit(sys.argv[1])
    else:
        run_ssh_audit()
