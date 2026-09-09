#!/bin/bash
# update.sh — Partie MAJ, au format tableau associatif (comme network.sh
# et permissions.sh), pour être utilisable avec "source" depuis script.sh.

# --- 1. Mises à jour de sécurité en attente (proxy pour CVE/KEV) -----------
maj_securite=$(apt list --upgradable 2>/dev/null | grep -i security | cut -d/ -f1)
nb_maj_securite=$(apt list --upgradable 2>/dev/null | grep -ci security)
nb_maj_totales=$(apt list --upgradable 2>/dev/null | grep -c '^[a-z]')

# --- 2. Fin de vie du système (EOL) -----------------------------------------
codename=$(. /etc/os-release && echo $VERSION_CODENAME)

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
echecs_installation=$(dpkg --audit)
nb_echecs_installation=$(dpkg --audit | grep -c '.')

# --- 6. Regroupement dans un tableau associatif "update" --------------------
# Même principe que network.sh/permissions.sh : script.sh fera
# "source modules/update.sh" puis lira ${update["cle"]} dans son heredoc.
declare -A update=(
    [maj_securite]="$maj_securite"
    [nb_maj_securite]="$nb_maj_securite"
    [nb_maj_totales]="$nb_maj_totales"
    [codename]="$codename"
    [date_fin_de_vie]="$date_fin_de_vie"
    [systeme_obsolete]="$systeme_obsolete"
    [auto_maj]="$auto_maj"
    [age_cache_jours]="$age_cache_jours"
    [echecs_installation]="$echecs_installation"
    [nb_echecs_installation]="$nb_echecs_installation"
)

# --- 7. Affichage (comme network.sh/permissions.sh, pour le débogage) ------
echo "maj_securite: ${update[maj_securite]}"
echo "nb_maj_securite: ${update[nb_maj_securite]}"
echo "nb_maj_totales: ${update[nb_maj_totales]}"
echo "codename: ${update[codename]}"
echo "date_fin_de_vie: ${update[date_fin_de_vie]}"
echo "systeme_obsolete: ${update[systeme_obsolete]}"
echo "auto_maj: ${update[auto_maj]}"
echo "age_cache_jours: ${update[age_cache_jours]}"
echo "echecs_installation: ${update[echecs_installation]}"
echo "nb_echecs_installation: ${update[nb_echecs_installation]}"
