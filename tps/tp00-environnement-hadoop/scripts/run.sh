#!/usr/bin/env bash
# TP0 — pipeline complet : build -> démarrage -> contrôles -> chargement HDFS -> job MapReduce -> résultat
# Usage (depuis n'importe où) : ./tps/tp00-environnement-hadoop/scripts/run.sh
set -euo pipefail

TP_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ROOT="$(cd "$TP_DIR/../.." && pwd)"
export COMPOSE_FILE="$ROOT/cluster/compose.yaml"   # cluster partagé par tous les TP

STREAMING_JAR=/opt/hadoop/share/hadoop/tools/lib/hadoop-streaming-3.4.1.jar
OUTPUT=/data/sales_output_python

step() { printf '\n\033[1;36m==> %s\033[0m\n' "$1"; }

step "Construction de l'image hadoop-python:3.4.1"
docker build -t hadoop-python:3.4.1 "$ROOT/cluster"

step "Validation et démarrage du cluster"
docker compose config -q
docker compose up -d
docker compose ps

step "Attente de la sortie du safe mode HDFS"
for i in $(seq 1 30); do
  if docker compose exec -T namenode hdfs dfsadmin -safemode wait >/dev/null 2>&1; then break; fi
  sleep 5
done

step "Contrôles"
docker compose exec -T namenode hdfs dfsadmin -report | grep -E "Live datanodes" || true
docker compose exec -T resourcemanager yarn node -list
docker compose exec -T nodemanager python3 --version
docker compose exec -T namenode hadoop getconf -confKey mapreduce.framework.name

step "Chargement de sales.csv dans HDFS"
docker compose cp "$TP_DIR/data/sales.csv" namenode:/tmp/sales.csv
docker compose exec -T namenode hdfs dfs -mkdir -p /data
docker compose exec -T namenode hdfs dfs -put -f /tmp/sales.csv /data/sales.csv

step "Lancement du job Hadoop Streaming"
docker compose cp "$TP_DIR/src/mapper.py"  namenode:/tmp/mapper.py
docker compose cp "$TP_DIR/src/reducer.py" namenode:/tmp/reducer.py
docker compose exec -T namenode hdfs dfs -rm -r -f "$OUTPUT"
docker compose exec -T namenode hadoop jar "$STREAMING_JAR" \
  -D mapreduce.framework.name=yarn \
  -files /tmp/mapper.py,/tmp/reducer.py \
  -input /data/sales.csv \
  -output "$OUTPUT" \
  -mapper "python3 mapper.py" \
  -reducer "python3 reducer.py"

step "Résultat"
docker compose exec -T namenode bash -c "hdfs dfs -cat '$OUTPUT/part-*'"

printf '\nInterfaces : HDFS http://localhost:9870  |  YARN http://localhost:8088\n'
