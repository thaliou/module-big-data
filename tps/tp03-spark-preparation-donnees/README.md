# TP3 — Préparation de données avec Spark : consommation d'énergie des bâtiments

| | |
|---|---|
| **Objectif** | Préparer le jeu *Building Energy Benchmarking* pour prédire la consommation d'énergie des bâtiments non résidentiels |
| **Technos** | PySpark 4 (DataFrame, `functions`, MLlib `StringIndexer` / `OneHotEncoder`), Google Colab, Matplotlib |
| **Cible** | `SiteEnergyUse(kBtu)` |
| **Statut** | ✅ Préparation terminée — 17/11/2026 · modélisation à venir |
| **Fiche de synthèse** | [fiche_synthese.md](fiche_synthese.md) |

## Contenu du dossier

```
tp03-spark-preparation-donnees/
├── README.md                     ce fichier
├── fiche_synthese.md             ce que j'ai fait, appris et corrigé
├── notebooks/
│   └── tp03_preparation_donnees_spark.ipynb   pipeline complet, 100 % Spark
└── data/
    └── README.md                 source et emplacement du jeu de données
```

## Lancer le TP

1. Ouvrir `notebooks/tp03_preparation_donnees_spark.ipynb` dans Google Colab.
2. Déposer le fichier `Building_Energy_Benchmarking….csv` dans `/content` (panneau Fichiers) ou sur Google Drive.
3. *Exécution → Tout exécuter*. Le jeu préparé est sauvegardé dans `building_energy_prepare.parquet`.

## Pipeline

| # | Étape | Outil Spark |
|---|---|---|
| 1 | Session et lecture du CSV | `SparkSession`, `spark.read.csv(header, inferSchema)` |
| 2 | Suppression des colonnes à plus de 70 % de valeurs manquantes | une seule agrégation `F.sum(F.when(...))` |
| 3 | Suppression des identifiants, création de `Age = DataYear - YearBuilt` | `drop`, `withColumn` |
| 4 | Conversion des nombres au format américain (`1,234.56`) | `regexp_replace`, `try_cast("double")` |
| 5 | Filtrage des bâtiments non résidentiels et de la cible renseignée | `filter`, `isin`, `isnan` |
| 6 | Bilan des valeurs manquantes | agrégation par colonne |
| 7 | Exclusion des variables à fuite de données | liste explicite |
| 8 | Matrice de corrélation de Pearson et suppression des redondances (\|r\| > 0,7) | `F.corr`, NumPy, Matplotlib |
| 9 | Encodage : one-hot (< 40 modalités), indexation (≥ 40) | `StringIndexer`, `OneHotEncoder`, `Pipeline` |
| 10 | Sauvegarde | `write.parquet` |

## Points clés

- Préparation **entièrement en Spark** : aucun `toPandas()`, y compris pour la matrice de corrélation.
- Variables qui contiennent la réponse (électricité, gaz, vapeur, EUI, émissions) **exclues** pour éviter la fuite de données.
- Valeurs invalides gérées avec `try_cast` (mode ANSI de Spark 4).
