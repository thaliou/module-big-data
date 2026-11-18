# Fiche de synthèse — TP3 : préparation de données avec Spark

**Date :** 17/11/2026 · **Auteur :** Aliou THIAM · **Module :** Big Data (S2 · UE2 · EC1)

## 1. Contexte et objectif

Préparer le jeu *Building Energy Benchmarking* pour prédire la consommation d'énergie des bâtiments non résidentiels de Seattle (`SiteEnergyUse(kBtu)`). Le professeur montrait la démarche avec pandas et laissait le choix des outils : j'ai réalisé toute la préparation avec **PySpark**, sur Google Colab.

## 2. Ce que j'ai fait

| Étape | Réalisation | Pourquoi |
|---|---|---|
| Session Spark | `SparkSession.builder…getOrCreate()`, PySpark installé par `pip` (Java est déjà présent sur Colab) | Point d'entrée de toute application Spark |
| Lecture | `spark.read.csv(chemin, header=True, inferSchema=True)` | `header` : noms de colonnes ; `inferSchema` : types détectés au lieu de tout lire en texte |
| Valeurs manquantes | Fonction qui affiche le % de manquants par colonne puis supprime celles au-delà de 70 % | Une colonne presque vide n'apporte rien et complique l'imputation |
| Nouvelle variable | `Age = DataYear - YearBuilt`, puis suppression des deux années | Une seule variable, plus parlante, mesurée au moment du relevé |
| Identifiants | Suppression de `ZipCode` et `TaxParcelIdentificationNumber` | Des codes, pas des quantités : aucun sens pour un modèle |
| Format des nombres | Suppression des virgules de milliers (`1,234.56`) puis conversion en `double` | Ces colonnes étaient lues comme du texte |
| Filtrage | Bâtiments `NonResidential`, `School`, `University`, `Hospital` → **17 392 lignes, 39 colonnes** ; cible non nulle | Population étudiée et cible obligatoire pour l'apprentissage |
| Types | Listes numériques / catégorielles lues dans `data.schema` | Instantané, sans parcourir les données |
| Corrélations | Matrice de Pearson calculée avec `F.corr`, heatmap Matplotlib | Repérer les variables liées à la cible et les redondances |
| Redondances | Suppression d'une variable par paire avec \|r\| > 0,7 | Éviter d'apporter deux fois la même information |
| Encodage | One-hot pour `BuildingType` (4), `City` (2), `Neighborhood` (14) ; `StringIndexer` pour les types d'usage (54 à 73 modalités) | Le one-hot sur 70 modalités créerait trop de colonnes |

## 3. Notions Spark retenues

- **Évaluation paresseuse** : les transformations (`withColumn`, `filter`, `cast`…) ne s'exécutent qu'au moment d'une action (`show`, `count`, `first`). Une erreur peut donc apparaître bien après la cellule qui l'a causée.
- **Une seule passe sur les données** : regrouper plusieurs calculs dans un même `select` (comptage des manquants, corrélations) plutôt que lancer une action par colonne.
- **`toPandas()` rapatrie tout le DataFrame** dans la mémoire de Python : à réserver à de petits résultats. Les équivalents Spark sont `distinct()`, `groupBy().count()`, `count()`, `len(df.columns)` et `df.schema`.
- **`StringIndexer` est l'équivalent Spark du `LabelEncoder`** ; `OneHotEncoder` ne s'applique qu'à une colonne déjà indexée et produit des **vecteurs creux** (`(4,[1],[1.0])`).
- **`isNotNull()` ne filtre pas les `NaN`** : il faut ajouter `~F.isnan(...)` sur les colonnes décimales.
- **Mode ANSI (Spark 4)** : un `cast` impossible fait échouer tout le calcul ; `try_cast` renvoie `null` à la place.

## 4. Problèmes rencontrés et solutions

| Problème | Cause | Solution |
|---|---|---|
| Fichier introuvable / mauvais chemin | Le fichier était déjà dans `/content`, la cellule d'upload était inutile | Chemin récupéré avec `glob` ou par « Copier le chemin » dans le panneau Fichiers |
| `NameError: name 'col' is not defined` | `col` utilisé alors que seul `functions as F` était importé | `F.col(...)` |
| `NameError: name 'vartocorect' is not defined` | Variable définie dans une cellule non exécutée (ou session redémarrée) | Liste reconstruite automatiquement par détection du format numérique |
| `CAST_INVALID_INPUT : '880490-0390'` | Le numéro de parcelle (identifiant avec tiret) avait été inclus dans les colonnes à convertir | Suppression de la colonne ; `try_cast` pour la robustesse |
| `City` à 2 valeurs pour une seule ville | Variantes de casse (`Seattle` / `SEATTLE`) | Normalisation `upper(trim(...))` avant l'encodage |

## 5. Points de vigilance pour la modélisation

- **Fuite de données** : électricité, gaz, vapeur, intensités EUI et émissions de GES sont des composantes ou des dérivés de la consommation. Elles « donnent la réponse » au modèle et doivent être exclues des variables explicatives.
- **Suppression par corrélation** : la boucle garde la première variable de chaque paire dans l'ordre de la liste ; il faut protéger la cible et ne comparer qu'aux variables conservées.
- **Variables indexées** : les entiers attribués par `StringIndexer` n'ont pas d'ordre réel ; privilégier des modèles à base d'arbres (Random Forest, Gradient Boosting).
- **Encodage et découpage** : ajuster l'encodage sur le jeu d'entraînement seulement, après le `randomSplit`.

## 6. Prochaine étape

Assembler les variables avec `VectorAssembler`, découper en entraînement et test, entraîner un modèle de régression Spark MLlib et l'évaluer (RMSE, R²).
