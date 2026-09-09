#!/usr/bin/env bash
# update.sh — Version Bash de update.py
# Même logique, mêmes commandes shell que la version Python : seule la
# syntaxe change (variables bash au lieu de subprocess.getoutput).

# --- 1. Mises à jour de sécurité en attente (proxy pour CVE/KEV) -----------
# Un paquet listé dans un dépôt "*-security" est un correctif déjà publié
# pour une faille connue : c'est l'équivalent local le plus fiable d'un
# "KEV" sans avoir besoin d'interroger une base CVE externe.
maj_securite=$(apt list --upgradable 2>/dev/null | grep -i security | cut -d/ -f1)
nb_maj_securite=$(apt list --upgradable 2>/dev/null | grep -ci security)

# Nombre total de mises à jour en attente (sécurité + autres)
nb_maj_totales=$(apt list --upgradable 2>/dev/null | grep -c '^[a-z]')

# --- 2. Fin de vie du système (EOL) -----------------------------------------
# VERSION_CODENAME est présent dans /etc/os-release sur Debian ET Ubuntu
# (contrairement à UBUNTU_CODENAME, qui n'existe que sur Ubuntu).
codename=$(. /etc/os-release && echo $VERSION_CODENAME)

# En Bash, un "dictionnaire" s'appelle un tableau associatif : on le
# déclare avec "declare -A", puis on accède à une valeur avec ${tableau[clé]}.
declare -A dates_fin_de_vie=(
    [focal]="2025-05-29"       # Ubuntu 20.04
    [jammy]="2027-04-21"       # Ubuntu 22.04
    [noble]="2029-05-31"       # Ubuntu 24.04
    [oracular]="2025-07-10"    # Ubuntu 24.10
    [bullseye]="2024-08-14"    # Debian 11
    [bookworm]="2026-06-10"    # Debian 12
    [trixie]="2028-06-10"      # Debian 13
)

if [ -n "${dates_fin_de_vie[$codename]}" ]; then
    date_fin_de_vie="${dates_fin_de_vie[$codename]}"
    aujourdhui=$(date +%Y-%m-%d)
    # Les dates au format YYYY-MM-DD se comparent correctement comme du
    # texte simple : "2026-01-01" > "2025-12-31" est vrai lettre par
    # lettre, donc pas besoin de convertir en timestamp ici.
    if [[ "$aujourdhui" > "$date_fin_de_vie" ]]; then
        systeme_obsolete="True"
    else
        systeme_obsolete="False"
    fi
else
    date_fin_de_vie="Inconnue (version non référencée dans la table)"
    systeme_obsolete="Indéterminé"
fi

# --- 3. Mises à jour automatiques activées ou non --------------------------
auto_maj=$(cat /etc/apt/apt.conf.d/20auto-upgrades 2>/dev/null || \
    echo "Fichier absent : mises a jour automatiques non configurees")

# --- 4. Retard d'application (patch lag) ------------------------------------
if [ -f /var/lib/apt/periodic/update-success-stamp ]; then
    age_cache_jours=$(( ( $(date +%s) - $(stat -c %Y /var/lib/apt/periodic/update-success-stamp) ) / 86400 ))
else
    age_cache_jours="Inconnu"
fi

# --- 5. Échecs d'installation ------------------------------------------------
# dpkg --audit (alias -C) est l'outil officiel pour lister les paquets
# dans un état incohérent. Vide si tout va bien.
echecs_installation=$(dpkg --audit)
nb_echecs_installation=$(dpkg --audit | grep -c '.')

# --- 6. Affichage regroupé ----------------------------------------------------
# On affiche chaque information sur une ligne "clé: valeur", pour rester
# lisible et comparable avec le dictionnaire produit par update.py.
echo "maj_securite: $maj_securite"
echo "nb_maj_securite: $nb_maj_securite"
echo "nb_maj_totales: $nb_maj_totales"
echo "codename: $codename"
echo "date_fin_de_vie: $date_fin_de_vie"
echo "systeme_obsolete: $systeme_obsolete"
echo "auto_maj: $auto_maj"
echo "age_cache_jours: $age_cache_jours"
echo "echecs_installation: $echecs_installation"
echo "nb_echecs_installation: $nb_echecs_installation"
