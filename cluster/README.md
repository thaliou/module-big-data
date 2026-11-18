# Cluster Hadoop partagé

Environnement mis en place au [TP0](../tps/tp00-environnement-hadoop/) et réutilisé par tous les TP.

| Service | Rôle | Port |
|---|---|---|
| `namenode` | Maître HDFS (métadonnées) | 9870 |
| `datanode` | Esclave HDFS (blocs) | — |
| `resourcemanager` | Maître YARN (ressources, jobs) | 8088 |
| `nodemanager` | Esclave YARN (exécution, Python 3.6.8) | — |

## Fichiers attendus ici

`compose.yaml`, `Dockerfile`, `core-site.xml`, `hdfs-site.xml`, `yarn-site.xml`, `mapred-site.xml` — copiés **tels quels** depuis le kit fourni. Les XML référencent les services par leur nom Compose : ne pas les modifier sans raison.

> Si un TP ultérieur fournit une nouvelle version du kit, remplacer les fichiers ici et décrire le changement dans le message de commit : l'historique Git garde la trace de chaque évolution.

## Commandes

Depuis la racine du dépôt :

```bash
docker build -t hadoop-python:3.4.1 cluster
docker compose -f cluster/compose.yaml up -d      # démarrer
docker compose -f cluster/compose.yaml ps         # état
docker compose -f cluster/compose.yaml stop       # arrêter en gardant les données
```

Astuce : `export COMPOSE_FILE=cluster/compose.yaml` (ou `$env:COMPOSE_FILE="cluster\compose.yaml"` sous PowerShell) évite de répéter `-f`.

> ⚠️ Jamais `docker compose down -v` : `-v` supprime les volumes, donc toutes les données HDFS.
