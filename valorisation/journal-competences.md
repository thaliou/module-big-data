# Journal des compétences — module Big Data

> À compléter **après chaque TP ou projet** (5 minutes). En fin de module, ce fichier sert de base pour le CV, LinkedIn, le portfolio et les entretiens.

## Synthèse (à rédiger en fin de module)

- **Ligne de CV :**
- **Description GitHub (About) :**
- **Topics GitHub :** `big-data` `hadoop` `hdfs` `yarn` `mapreduce` `spark` `pyspark` `docker-compose` `python`
- **Carte portfolio :**
- **Pitch entretien (30 s) :**

---

## TP0 — Environnement Hadoop sous Docker (27/10/2026)

**Compétences**
- Déployer un cluster Hadoop 3.4.1 maître/esclave (NameNode, DataNode, ResourceManager, NodeManager) avec Docker Compose
- Vérifier la santé d'un cluster : `hdfs dfsadmin -report`, `yarn node -list`, interfaces 9870 / 8088
- Charger et lire des données dans HDFS (`-mkdir`, `-put`, `-cat`)
- Écrire et exécuter un job MapReduce en Python via Hadoop Streaming

**Technos :** Hadoop 3.4.1 · HDFS · YARN · Hadoop Streaming · Docker Compose · Python

**Formulation CV possible :** Déploiement d'un cluster Hadoop (HDFS/YARN) conteneurisé et exécution d'un job MapReduce Python distribué.

---

## TP3 — Préparation de données avec Spark (17/11/2026)

**Compétences**
- Charger et explorer un jeu de données réel avec PySpark (session, lecture CSV, schéma)
- Nettoyer des données à grande échelle sans pandas : valeurs manquantes, conversions de types, normalisation du texte
- Calculer une matrice de corrélation de Pearson en une seule passe Spark
- Identifier et exclure les variables à fuite de données avant un modèle
- Encoder des variables catégorielles avec Spark MLlib (`StringIndexer`, `OneHotEncoder`, `Pipeline`)

**Technos :** PySpark 4 · Spark SQL functions · Spark MLlib · Google Colab · Parquet

**Formulation CV possible :** Préparation d'un jeu de données de consommation énergétique (17 000 bâtiments) avec PySpark : nettoyage, conversion, analyse des corrélations, détection des fuites de données et encodage MLlib.

**Preuves :** [README du TP](../tps/tp03-spark-preparation-donnees/README.md), [fiche de synthèse](../tps/tp03-spark-preparation-donnees/fiche_synthese.md)
