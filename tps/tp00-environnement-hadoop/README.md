# TP0 — Environnement Hadoop sous Docker

| | |
|---|---|
| **Objectif** | Monter un cluster Hadoop 3.4.1 (HDFS + YARN) avec Docker Compose et exécuter un premier job MapReduce en Python |
| **Technos** | Hadoop 3.4.1, HDFS, YARN, Hadoop Streaming, Docker Compose, Python 3.6.8 (dans le cluster) |
| **Statut** | ✅ Terminé — 27/10/2026 |
| **Énoncé** | [enonce.pdf](enonce.pdf) |

## Contenu du dossier

```
tp00-environnement-hadoop/
├── README.md        ce bilan
├── enonce.pdf       sujet du TP
├── data/sales.csv   données de ventes
├── src/             mapper.py, reducer.py
├── scripts/         run.sh / run.ps1 : tout le TP en une commande
└── captures/        preuves d'exécution
```

## Lancer le TP

```bash
./tps/tp00-environnement-hadoop/scripts/run.sh        # Linux / WSL / Git Bash
.\tps\tp00-environnement-hadoop\scripts\run.ps1       # PowerShell
```

## Étapes réalisées

### 1. Construction et démarrage du cluster

```bash
export COMPOSE_FILE=cluster/compose.yaml
docker build -t hadoop-python:3.4.1 cluster
docker compose config -q
docker compose up -d
docker compose ps                     # 4 services Up
```

### 2. Vérifications

| Commande | Résultat attendu | Ce que ça prouve |
|---|---|---|
| `docker compose exec namenode hdfs dfsadmin -report` | `Live datanodes (1)` | Le NameNode reçoit les heartbeats du DataNode |
| `docker compose exec namenode hdfs dfs -ls /` | Pas d'erreur | HDFS est accessible |
| `docker compose exec resourcemanager yarn node -list` | `Total Nodes: 1`, `RUNNING` | Le ResourceManager voit le NodeManager |
| `docker compose exec nodemanager python3 --version` | `Python 3.6.8` | Python est présent là où s'exécutent les tâches |
| `docker compose exec namenode hadoop getconf -confKey mapreduce.framework.name` | `yarn` | MapReduce passe par YARN |

### 3. Chargement des données dans HDFS

```bash
docker compose cp tps/tp00-environnement-hadoop/data/sales.csv namenode:/tmp/sales.csv
docker compose exec namenode hdfs dfs -mkdir -p /data
docker compose exec namenode hdfs dfs -put -f /tmp/sales.csv /data/sales.csv
```

### 4. Job MapReduce Python (Hadoop Streaming) — CA par pays

```bash
docker compose exec namenode hadoop jar \
  /opt/hadoop/share/hadoop/tools/lib/hadoop-streaming-3.4.1.jar \
  -D mapreduce.framework.name=yarn \
  -files /tmp/mapper.py,/tmp/reducer.py \
  -input /data/sales.csv -output /data/sales_output_python \
  -mapper "python3 mapper.py" -reducer "python3 reducer.py"
```

- **map** : chaque ligne de `sales.csv` → `pays<TAB>montant`
- **shuffle & sort** : Hadoop regroupe et trie par pays
- **reduce** : somme des montants par pays

## Résultat

```
France	2200.0
Germany	2100.0
Senegal	1600.0
```

| HDFS — NameNode (9870) | YARN — Applications (8088) |
|---|---|
| ![NameNode](captures/namenode-overview.png) | ![YARN](captures/yarn-applications.png) |

## Ce que j'ai appris

- La séparation **stockage (HDFS) / calcul (YARN)** et le modèle **maître / esclave** de chaque couche.
- Le rôle de chaque service : NameNode = annuaire, DataNode = disques, ResourceManager = ordonnanceur, NodeManager = ouvrier.
- **Hadoop Streaming** : écrire un job MapReduce en Python, qui reproduit le pipeline `cat | mapper | sort | reducer`.
- La communication entre conteneurs par **nom de service** sur le réseau Docker, et pourquoi les liens internes des interfaces web ne s'ouvrent pas depuis l'hôte.

## Difficultés et solutions

| Problème | Solution |
|---|---|
| _à compléter si tu en as rencontré_ | |

## Limites

Cluster mono-nœud (réplication 1), image CentOS 7 / Python 3.6.8 en fin de vie : usage local et pédagogique uniquement.
