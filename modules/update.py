import subprocess
import datetime

# --- 1. Mises à jour de sécurité en attente (proxy pour CVE/KEV) -----------
# Un paquet listé dans un dépôt "*-security" (ex: noble-security) est un
# correctif déjà publié pour une faille connue : c'est l'équivalent local
# le plus fiable d'un "KEV" sans avoir besoin d'interroger une base CVE
# externe (NVD...), qui ne serait pas accessible depuis ce script.
maj_securite = subprocess.getoutput(
    "apt list --upgradable 2>/dev/null | grep -i security | cut -d/ -f1"
)
nb_maj_securite = subprocess.getoutput(
    "apt list --upgradable 2>/dev/null | grep -ci security"
)

# Nombre total de mises à jour en attente (sécurité + autres)
nb_maj_totales = subprocess.getoutput(
    "apt list --upgradable 2>/dev/null | grep -c '^[a-z]'"
)

# --- 2. Fin de vie du système (EOL = End Of Life, "fin de vie) -----------------------------------------
# Aucune commande locale ne donne directement la date de fin de support :
# on la compare donc à une petite table de dates connues pour les versions
# Ubuntu et Debian récentes (sources : ubuntu.com/about/release-cycle et
# wiki.debian.org/DebianReleases).
#
# On utilise VERSION_CODENAME (et non UBUNTU_CODENAME) car cette variable
# est présente dans /etc/os-release sur TOUTES les distributions basées sur
# Debian, alors que UBUNTU_CODENAME n'existe que sur Ubuntu et serait vide
# sur une Debian classique.
codename = subprocess.getoutput(". /etc/os-release && echo $VERSION_CODENAME")

dates_fin_de_vie = {
    # --- Ubuntu ---
    "focal": "2025-05-29",     # Ubuntu 20.04
    "jammy": "2027-04-21",     # Ubuntu 22.04
    "noble": "2029-05-31",     # Ubuntu 24.04
    "oracular": "2025-07-10",  # Ubuntu 24.10
    # --- Debian ---
    "bullseye": "2024-08-14",  # Debian 11
    "bookworm": "2026-06-10",  # Debian 12
    "trixie": "2028-06-10",    # Debian 13 (date estimée, ~2 ans après sortie)
}

if codename in dates_fin_de_vie:
    date_eol = dates_fin_de_vie[codename]
    obsolete = datetime.date.today() > datetime.date.fromisoformat(date_eol)
else:
    date_eol = "Inconnue (version non référencée dans la table)"
    obsolete = "Indéterminé"

# --- 3. Mises à jour automatiques activées ou non --------------------------
# Ce fichier de config contient "1" si les MAJ automatiques sont activées,
# "0" sinon. S'il est absent, elles ne sont probablement pas configurées.
auto_maj = subprocess.getoutput(
    "cat /etc/apt/apt.conf.d/20auto-upgrades 2>/dev/null || "
    "echo 'Fichier absent : mises a jour automatiques non configurees'"
)

# --- 4. Retard d'application (patch lag) ------------------------------------
# On mesure l'âge en jours du dernier rafraîchissement du cache apt : plus
# ce chiffre est élevé, plus le système risque d'ignorer des correctifs
# récents.
age_cache_jours = subprocess.getoutput(
    "test -f /var/lib/apt/periodic/update-success-stamp && "
    "echo $(( ($(date +%s) - $(stat -c %Y /var/lib/apt/periodic/update-success-stamp)) / 86400 )) || "
    "echo 'Inconnu'"
)

# --- 5. Échecs d'installation ------------------------------------------------
# "dpkg --audit" (alias -C) est l'outil officiel de dpkg pour lister les
# paquets dans un état incohérent (installation interrompue, dépendance
# cassée...). Il ne renvoie RIEN si tout va bien.
#
# Remarque : une première version de ce script filtrait "dpkg -l" en
# excluant seulement les lignes "ii" (installé correctement). Mais un
# paquet désinstallé dont les fichiers de config trainent encore (statut
# "rc") passait aussi ce filtre, alors que ce n'est PAS un échec
# d'installation — juste un reste de nettoyage incomplet. dpkg --audit
# ne fait pas cette confusion.
echecs_installation = subprocess.getoutput("dpkg --audit")
nb_echecs_installation = subprocess.getoutput(
    "dpkg --audit | grep -c '.'"  # compte les lignes non vides
)

# --- 6. Regroupement dans un dictionnaire (même logique que network.py) ----
update = {
    "maj_securite": maj_securite,
    "nb_maj_securite": nb_maj_securite,
    "nb_maj_totales": nb_maj_totales,
    "codename": codename,
    "date_fin_de_vie": date_eol,
    "systeme_obsolete": obsolete,
    "auto_maj": auto_maj,
    "age_cache_jours": age_cache_jours,
    "echecs_installation": echecs_installation,
    "nb_echecs_installation": nb_echecs_installation,
}

print(update)
