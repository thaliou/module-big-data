# Assignment 1 — Cluster Hadoop distribué et traitements MapReduce

**Auteur :** Aliou THIAM — Cycle ingénieur SID, Polytech Diamniadio (UAM) — S2 · UE2 · EC1 Big Data

Cluster **Apache Hadoop 3.4.1** déployé avec **Docker Compose** (1 NameNode, 3 DataNodes, 1 ResourceManager, 3 NodeManagers, réplication HDFS = 2), puis quatre traitements **MapReduce en Python 3** exécutés via **Hadoop Streaming** sur `transactions.csv` (100 000 transactions synthétiques).

---

## 1. Contenu de l'archive

```
Assignment1_Aliou_THIAM/
├── README.md              ce fichier
├── compose.yaml           9 services : init-permissions + 8 nœuds Hadoop
├── Dockerfile             image hadoop-python:3.4.1 (Hadoop 3.4.1 + Python 3) des NodeManagers
├── core-site.xml          fs.defaultFS
├── hdfs-site.xml          réplication 2, bloc de 1 Mio, répertoires HDFS
├── yarn-site.xml          ResourceManager, ressources des NodeManagers (2 Go, 2 vCores)
├── mapred-site.xml        MapReduce sur YARN, mémoire des conteneurs
├── data/                  transactions.csv et son générateur reproductible
├── scripts/
│   ├── charger_donnees.sh import dans HDFS + vérification des blocs (fsck)
│   └── lancer_tout.sh     exécute les 4 traitements et affiche un bilan
├── traitements/T1 … T4/
│   ├── mapper.py, reducer.py
│   ├── commande.sh        test local, job YARN, résultat, validation indépendante
│   ├── resultat.txt       sortie HDFS du traitement
│   └── README.md          logique du traitement
├── architecture/          schémas du cluster
├── captures/              captures d'écran du rapport
└── rapport/               Rapport_Assignment_1_Aliou_THIAM.pdf
```

## 2. Prérequis

| Élément | Détail |
|---|---|
| Docker | Docker Desktop (moteur Linux / WSL2) ou Docker Engine, avec Docker Compose v2 |
| Mémoire | au moins 8 Go alloués à Docker (16 Go de RAM recommandés sur la machine) |
| Disque | environ 10 Go libres |
| Ports | 9870 et 8088 libres sur la machine hôte |
| Shell | `bash` pour les scripts `.sh` : Linux, macOS, WSL ou **Git Bash** sous Windows |
| Réseau | accès Internet au premier build (image `apache/hadoop:3.4.1` et paquet Python depuis `vault.centos.org`) |

Aucun autre cluster utilisant les noms de conteneurs `hadoop-*` ne doit être en cours d'exécution.

## 3. Reconstruire le cluster

Toutes les commandes se lancent depuis la racine du projet.

```bash
docker compose up -d --build
docker compose ps -a
```

Attendu : 8 services `Up`, et `hadoop-init-permissions` en `Exited (0)` (il attribue les volumes à l'utilisateur `hadoop`, puis s'arrête). Au premier démarrage, le NameNode formate HDFS automatiquement.

Vérifications, après 30 secondes environ :

```bash
docker compose exec namenode hdfs dfsadmin -report               # Live datanodes (3)
docker compose exec resourcemanager yarn node -list -all          # Total Nodes:3, RUNNING
docker compose exec namenode hdfs getconf -confKey dfs.replication   # 2
docker compose exec namenode hdfs getconf -confKey dfs.blocksize     # 1048576
docker compose exec nodemanager-01 python3 --version               # Python 3.6.8
```

Interfaces web : HDFS http://localhost:9870 · YARN http://localhost:8088

## 4. Importer les données dans HDFS

```bash
bash scripts/charger_donnees.sh
```

Le script crée `/assignment/transactions`, y dépose `transactions.csv`, puis affiche sa taille et le résultat de `hdfs fsck` : **7 blocs**, 2 répliques par bloc, statut `HEALTHY`.

## 5. Lancer les quatre traitements

```bash
bash scripts/lancer_tout.sh          # les quatre, avec un bilan final
bash traitements/T2/commande.sh      # ou un seul traitement
```

| # | Traitement | Clé | Sortie HDFS |
|---|---|---|---|
| T1 | Chiffre d'affaires par pays | `country` | `/assignment/resultats/T1` |
| T2 | Ventes par catégorie | `category` | `/assignment/resultats/T2` |
| T3 | Chiffre d'affaires mensuel | `AAAA-MM` | `/assignment/resultats/T3` |
| T4 | Top 3 des produits par catégorie | `category` + `product` | `/assignment/resultats/T4` |

Chaque `commande.sh` enchaîne :

1. la vérification que le fichier d'entrée est présent dans HDFS ;
2. un **test local sans Hadoop** (`cat | mapper | sort | reducer`) dans `nodemanager-01` ;
3. le **job YARN** via Hadoop Streaming ;
4. la récupération de la sortie HDFS dans `traitements/Tn/resultat.txt` ;
5. une **validation indépendante** : calcul direct depuis le CSV en Python (`csv.DictReader` + `Decimal`), sans mapper ni reducer, comparé à la sortie YARN et au test local.

Résultat attendu : `IDENTIQUE` pour chaque comparaison, puis `T1 … T4 : OK` dans le bilan.

Les montants (`quantity × unit_price`) sont calculés en **centimes entiers** ; l'en-tête du CSV est ignoré par les mappers (compteur Hadoop `Qualite/Entete_ignoree = 1`).

## 6. Tests de panne (Partie D)

```bash
# Panne d'un DataNode : détection après ~10 min 30 s, re-réplication, puis restauration
docker compose stop datanode-02
docker compose exec namenode hdfs dfsadmin -report
docker compose exec namenode hdfs fsck /assignment/transactions/transactions.csv -files -blocks -locations
docker compose start datanode-02

# Panne d'un NodeManager : état LOST après ~10 min, les jobs continuent sur les 2 autres
docker compose stop nodemanager-02
docker compose exec resourcemanager yarn node -list -all
bash traitements/T1/commande.sh
docker compose start nodemanager-02
```

## 7. Arrêter le cluster

```bash
docker compose stop      # arrêt, conteneurs et données conservés
docker compose down      # suppression des conteneurs, données HDFS conservées dans les volumes
```

> ⚠️ `docker compose down -v` supprime aussi les **volumes**, donc toutes les données HDFS. À n'utiliser que pour repartir de zéro.

## 8. Problèmes connus

| Symptôme | Cause / solution |
|---|---|
| `Input path does not exist` ou message « absent de HDFS » | Les données n'ont pas été importées sur ce cluster : `bash scripts/charger_donnees.sh` |
| Chemins `/tmp/…` ou `/assignment/…` transformés en `C:/Program Files/Git/…` | Git Bash convertit les chemins : les scripts définissent `MSYS_NO_PATHCONV=1` ; à ajouter devant toute commande saisie à la main |
| `$'\r': command not found` | Un `.sh` a été enregistré avec des fins de ligne Windows (CRLF) : le reconvertir en LF |
| `Name node is in safe mode` | Démarrage en cours : `docker compose exec namenode hdfs dfsadmin -safemode wait` |
| Un service redémarre en boucle | Mémoire insuffisante pour Docker, ou ports 9870 / 8088 déjà utilisés |
| Données d'un autre essai mélangées | Deux dossiers portant le même nom partagent le même projet Compose et les mêmes volumes : utiliser `COMPOSE_PROJECT_NAME=<nom>` pour une copie de test |

## 9. Limites

- Cluster simulé sur **un seul ordinateur** : une panne de la machine hôte arrête tous les nœuds à la fois ; la réplication protège contre la perte d'un conteneur, pas d'un disque.
- DataNodes et NodeManagers dans des conteneurs séparés : aucune tâche n'est « data-local », chaque map lit son bloc par le réseau Docker.
- Image basée sur **CentOS 7 / Python 3.6.8**, en fin de vie : usage local et pédagogique uniquement.
- Bloc de 1 Mio choisi pour ce petit jeu de données ; un cluster réel conserverait 128 Mio.

## 10. Attribution et assistance

- Jeu de données `transactions.csv` et générateur : fournis avec le sujet.
- Image de base : `apache/hadoop:3.4.1` (Apache Software Foundation).

