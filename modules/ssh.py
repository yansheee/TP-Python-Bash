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
    resultats = []
    lignes = []

    # Vérification 1 : le fichier de configuration existe-t-il et est-il lisible ?
    try:
        with open(config_path, "r") as fichier:
            lignes = fichier.readlines()
        resultats.append("[OK] Fichier de configuration trouvé : " + config_path)
    except FileNotFoundError:
        resultats.append("[FAIL] Fichier de configuration introuvable : " + config_path)
    except PermissionError:
        resultats.append("[ERROR] Droits insuffisants pour lire : " + config_path)

    # Vérification 2 : PermitRootLogin
    permit_root_login = chercher_valeur("PermitRootLogin", lignes)

    if permit_root_login is None:
        resultats.append("[INFO] PermitRootLogin non défini dans le fichier (valeur par défaut OpenSSH : prohibit-password)")
    elif permit_root_login == "yes":
        resultats.append("[FAIL] PermitRootLogin est activé (connexion root directe autorisée)")
    else:
        resultats.append("[OK] PermitRootLogin est restreint : " + permit_root_login)

    # Vérification 3 : permissions et propriétaire du fichier de configuration
    try:
        info_fichier = os.stat(config_path)
        mode = info_fichier.st_mode
        permissions_texte = stat.filemode(mode)

        resultats.append("[INFO] Permissions de " + config_path + " : " + permissions_texte)

        if mode & stat.S_IWGRP or mode & stat.S_IWOTH:
            resultats.append("[FAIL] Le fichier est modifiable par le groupe ou par tout le monde")
        else:
            resultats.append("[OK] Seul le propriétaire peut modifier le fichier")
    except FileNotFoundError:
        resultats.append("[ERROR] Impossible de vérifier les permissions : fichier introuvable")

    # Vérification 4 : quels utilisateurs/groupes sont explicitement autorisés ?
    allow_users = chercher_valeur("AllowUsers", lignes)
    allow_groups = chercher_valeur("AllowGroups", lignes)

    if allow_users is None and allow_groups is None:
        resultats.append("[INFO] Aucune restriction AllowUsers/AllowGroups définie (tous les utilisateurs sont autorisés par défaut)")
    else:
        if allow_users:
            resultats.append("[OK] AllowUsers défini : " + allow_users)
        if allow_groups:
            resultats.append("[OK] AllowGroups défini : " + allow_groups)

    return resultats

if __name__ == "__main__":
    if len(sys.argv) > 1:
        liste_resultats = run_ssh_audit(sys.argv[1])
    else:
        liste_resultats = run_ssh_audit()

    for ligne in liste_resultats:
        print(ligne)
