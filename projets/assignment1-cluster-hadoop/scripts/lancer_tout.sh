#!/usr/bin/env bash
# Enchaîne les quatre traitements (test local, job YARN, résultat, validation) et affiche un bilan
# Usage, depuis la racine du projet : bash scripts/lancer_tout.sh [T1 T2 ...]
set -uo pipefail
cd "$(dirname "$0")/.."
LISTE=("$@"); [ ${#LISTE[@]} -eq 0 ] && LISTE=(T1 T2 T3 T4)

declare -A BILAN
for T in "${LISTE[@]}"; do
  echo
  echo "==================== $T ===================="
  if bash "traitements/$T/commande.sh"; then BILAN[$T]="OK"; else BILAN[$T]="ÉCHEC"; fi
done

echo
echo "==================== Bilan ===================="
for T in "${LISTE[@]}"; do printf '%-3s : %s\n' "$T" "${BILAN[$T]}"; done
