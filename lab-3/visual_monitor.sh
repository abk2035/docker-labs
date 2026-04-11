#!/bin/bash

# Configuration de dialog
DIALOG_WIDTH=60
DIALOG_HEIGHT=20

# Fichier temporaire pour stocker les infos
INFOS_FILE="/tmp/sysinfos.txt"

# Fonction pour collecter les données
collect_data() {
    # 1. RÉCUPÉRATION DE LA RAM
    local mem_raw=$(free -m | grep "Mem:")
    local total_mem=$(echo $mem_raw | awk '{print $2}')
    local used_mem=$(echo $mem_raw | awk '{print $3}')
    local free_mem=$(echo $mem_raw | awk '{print $4}')
    local percent_mem=$(( used_mem * 100 / total_mem ))

    # 2. RÉCUPÉRATION DU CPU
    local cpu_idle=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}')
    # Calcul en flottant avec awk pour plus de précision
    local cpu_usage=$(awk "BEGIN {print 100 - $cpu_idle}")

    # 3. RÉCUPÉRATION DU DISQUE (Racine /)
    local disk_raw=$(df -h / | tail -1)
    local total_disk=$(echo $disk_raw | awk '{print $2}')
    local used_disk=$(echo $disk_raw | awk '{print $3}')
    local percent_disk=$(echo $disk_raw | awk '{print $5}' | tr -d '%')

    # Écriture dans le fichier temporaire
    cat <<EOF > $INFOS_FILE
========================================
     DASHBOARD SYSTÈME (Bash + Dialog)
========================================

--- [ MÉMOIRE RAM ] ---
Total       : ${total_mem} Mo
Utilisée    : ${used_mem} Mo
Disponible  : ${free_mem} Mo
Pourcentage : ${percent_mem}%

--- [ PROCESSEUR ] ---
Utilisation CPU : ${cpu_usage}%

--- [ ESPACE DISQUE (/) ] ---
Total       : ${total_disk}
Utilisé      : ${used_disk}
Pourcentage : ${percent_disk}%

========================================
Appuyez sur Entrée pour rafraîchir.
Appuyez sur Échap pour quitter.
EOF
}

# Boucle principale
while true; do
    collect_data
    # Affiche la boîte de texte 'textbox'
    dialog --title "Monitoring Système - Bash Labs" \
           --textbox "$INFOS_FILE" \
           $DIALOG_HEIGHT $DIALOG_WIDTH
           
    # Si l'utilisateur appuie sur Échap (code de sortie != 0), on quitte
    if [ $? -ne 0 ]; then
        rm -f $INFOS_FILE
        clear
        echo "Dashboard fermé."
        exit 0
    fi
done