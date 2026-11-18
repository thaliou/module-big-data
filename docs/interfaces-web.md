# Interfaces web du cluster

## http://localhost:9870 — NameNode (HDFS)

Vue **stockage** du cluster.

| Onglet | Contenu |
|---|---|
| **Overview** | Version (3.4.1), date de démarrage, Cluster ID, état du *Safe mode* (lecture seule juste après le démarrage), capacité totale / utilisée / restante, nombre de fichiers et de blocs, DataNodes vivants / morts. Équivalent graphique de `hdfs dfsadmin -report`. |
| **Datanodes** | Liste des DataNodes : dernier heartbeat, espace utilisé, nombre de blocs. |
| **Startup Progress** | Étapes de démarrage : chargement du `fsimage`, relecture des `edits`, attente des rapports de blocs. |
| **Utilities → Browse the file system** | Explorateur HDFS : `/data/sales.csv`, taille, réplication, taille de bloc ; en cliquant sur un fichier, ses blocs et le DataNode qui les héberge. |
| **Utilities → Logs / Configuration / Metrics** | Journaux du NameNode, configuration effective (XML + valeurs par défaut), métriques JMX. |

## http://localhost:8088 — ResourceManager (YARN)

Vue **calcul** : suivi des jobs MapReduce.

| Section | Contenu |
|---|---|
| **Cluster Metrics** | Applications soumises / en attente / en cours / terminées, conteneurs actifs, mémoire et vCores utilisés vs total. |
| **Nodes** | NodeManagers, leur état (`RUNNING`), ressources, dernier heartbeat. Équivalent de `yarn node -list`. |
| **Applications** | Tous les jobs, filtrables par état (`ACCEPTED`, `RUNNING`, `FINISHED`, `FAILED`, `KILLED`). Le détail d'un job montre ses tentatives, son ApplicationMaster et le **diagnostic** en cas d'échec — premier endroit à consulter quand un job Streaming plante. |
| **Scheduler** | Files d'attente (souvent une seule queue `default`) et leur taux d'occupation. |
| **Tools** | Configuration, logs locaux, métriques. |

## Piège : les adresses internes Docker

Certains liens des interfaces pointent vers des **noms internes au réseau Docker** (`http://nodemanager:8042` pour les logs d'une tâche, `datanode:9864` pour télécharger un fichier). Le navigateur de l'hôte ne résout pas ces noms et ces ports ne sont pas publiés : **ces liens échouent, ce n'est pas une panne**.

Alternatives en ligne de commande :

```bash
# logs complets d'un job
docker compose exec resourcemanager yarn logs -applicationId application_XXXX_0001

# contenu d'un fichier HDFS
docker compose exec namenode hdfs dfs -cat /data/sales.csv
```

Le lien **History** d'un job terminé renvoie vers le JobHistory Server (port 19888), absent de ce cluster : il ne fonctionne pas non plus.
