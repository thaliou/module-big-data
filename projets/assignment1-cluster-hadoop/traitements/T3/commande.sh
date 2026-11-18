#!/usr/bin/env bash
# T3 — Chiffre d'affaires mensuel
# Étapes : 1) test local sans Hadoop  2) job YARN (Hadoop Streaming)  3) récupération de la sortie HDFS
#          4) validation indépendante (calcul direct en Python, sans MapReduce)
# Usage, depuis n'importe quel dossier : bash traitements/T3/commande.sh
set -euo pipefail
export MSYS_NO_PATHCONV=1            # Git Bash sous Windows : ne pas convertir les chemins /tmp, /assignment…
cd "$(dirname "$0")/../.."           # racine du projet (là où se trouve compose.yaml)

T=T3
D=traitements/$T
IN=/assignment/transactions/transactions.csv
OUT=/assignment/resultats/$T
JAR=/opt/hadoop/share/hadoop/tools/lib/hadoop-streaming-3.4.1.jar
TAB=$(printf '\t')
QUIET="HADOOP_ROOT_LOGGER=ERROR,console"   # journaux du client Hadoop masqués : résultats seuls

echo "==> $T : vérification de la présence des données dans HDFS"
if ! docker compose exec -T namenode hdfs dfs -test -e "$IN"; then
  echo "ERREUR : $IN est absent de HDFS. Lancez d'abord : bash scripts/charger_donnees.sh" >&2
  exit 1
fi

echo "==> $T : copie des scripts et des données dans les conteneurs"
for c in namenode nodemanager-01; do
  docker compose cp "$D/mapper.py"  "$c:/tmp/${T}_mapper.py"
  docker compose cp "$D/reducer.py" "$c:/tmp/${T}_reducer.py"
done
docker compose cp data/transactions.csv nodemanager-01:/tmp/transactions.csv

echo "==> $T : test local (cat | mapper | sort | reducer), sans Hadoop, dans nodemanager-01"
# LC_ALL=C : tri octet par octet, comme le tri des clés de Hadoop
docker compose exec -T -e PYTHONIOENCODING=utf-8 nodemanager-01 bash -c \
  "cat /tmp/transactions.csv | python3 /tmp/${T}_mapper.py 2>/dev/null | LC_ALL=C sort | python3 /tmp/${T}_reducer.py > /tmp/${T}_local.txt && wc -l < /tmp/${T}_local.txt"

echo "==> $T : job YARN"
docker compose exec -T namenode bash -c "$QUIET hdfs dfs -rm -r -f -skipTrash $OUT"   # Hadoop refuse une sortie existante
docker compose exec -T namenode hadoop jar "$JAR" \
  -D mapreduce.job.name="T3 - Chiffre d'affaires mensuel" \
  -D mapreduce.job.reduces=1 \
  -files "/tmp/${T}_mapper.py,/tmp/${T}_reducer.py" \
  -input "$IN" \
  -output "$OUT" \
  -mapper "python3 ${T}_mapper.py" \
  -reducer "python3 ${T}_reducer.py"

echo "==> $T : récupération de la sortie HDFS dans $D/resultat.txt"
# Un seul reducer : la sortie est déjà triée par clé
docker compose exec -T namenode bash -c "$QUIET hdfs dfs -cat '$OUT/part-*'" | cat > "$D/resultat.txt"
cat "$D/resultat.txt"

echo "==> $T : validation indépendante"
docker compose cp "$D/resultat.txt" nodemanager-01:/tmp/${T}_yarn.txt
docker compose exec -T -e PYTHONIOENCODING=utf-8 nodemanager-01 python3 - /tmp/transactions.csv /tmp/${T}_yarn.txt /tmp/${T}_local.txt <<'PY'
# Validation indépendante de T3 : calcul direct depuis le CSV (csv.DictReader + Decimal), sans mapper ni reducer
import csv, sys
from collections import defaultdict
from decimal import Decimal

csv_path, yarn_path, local_path = sys.argv[1:4]


def cent(d):
    return int((d * 100).to_integral_value())


def euros(c):
    return "{}.{:02d}".format(c // 100, c % 100)


rows = []
with open(csv_path, newline="", encoding="utf-8") as f:
    for r in csv.DictReader(f):            # lecture par nom de colonne, en-tête géré par DictReader
        try:
            q = int(r["quantity"])
            rows.append((r, q, q * Decimal(r["unit_price"])))
        except Exception:
            pass

agg = defaultdict(lambda: [0, Decimal(0)])
for r, q, m in rows:
    a = agg[r["date"].strip()[:7]]; a[0] += 1; a[1] += m
ref = ["{}\t{}\t{}\t{}".format(k, n, cent(s), euros(cent(s))) for k, (n, s) in agg.items()]


def lire(p):
    with open(p, encoding="utf-8") as f:
        return [l.rstrip("\r\n") for l in f if l.strip()]


yarn, local = lire(yarn_path), lire(local_path)
print("Lignes de données valides : {}".format(len(rows)))
print("Résultat attendu (validation) : {} lignes".format(len(ref)))
ok = True
for nom, obtenu in (("YARN", yarn), ("Test local", local)):
    egal = sorted(obtenu) == sorted(ref)
    ok = ok and egal
    print("{:<11}: {} lignes -> {}".format(nom, len(obtenu), "IDENTIQUE" if egal else "DIFFÉRENT"))
    if not egal:
        print("   attendu mais absent : {}".format(sorted(set(ref) - set(obtenu))[:3]))
        print("   obtenu en trop      : {}".format(sorted(set(obtenu) - set(ref))[:3]))
sys.exit(0 if ok else 1)
PY
