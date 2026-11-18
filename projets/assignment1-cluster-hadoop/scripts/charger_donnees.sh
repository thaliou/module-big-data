#!/usr/bin/env bash
# Importe data/transactions.csv dans HDFS (/assignment/transactions) puis affiche taille, blocs et répliques
# Usage, depuis la racine du projet : bash scripts/charger_donnees.sh
set -euo pipefail
export MSYS_NO_PATHCONV=1            # Git Bash sous Windows : ne pas convertir les chemins HDFS
cd "$(dirname "$0")/.."

docker compose exec -T namenode hdfs dfsadmin -safemode wait
docker compose cp data/transactions.csv namenode:/tmp/transactions.csv
docker compose exec -T namenode hdfs dfs -mkdir -p /assignment/transactions
docker compose exec -T namenode hdfs dfs -put -f /tmp/transactions.csv /assignment/transactions/
docker compose exec -T namenode hdfs dfs -stat "%n : %b octets, bloc %o, réplication %r" /assignment/transactions/transactions.csv
docker compose exec -T namenode hdfs fsck /assignment/transactions/transactions.csv -files -blocks -locations
