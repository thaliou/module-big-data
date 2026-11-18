# T4 — Top 3 des produits par catégorie

**Objectif :** Identifier les produits qui génèrent le plus de chiffre d'affaires dans chaque catégorie.

| | |
|---|---|
| Entrée | `/assignment/transactions/transactions.csv` |
| Sortie HDFS | `/assignment/resultats/T4` |
| Clé émise par le mapper | `category` + `product` (clé composée) |
| Valeur | `montant_centimes` |
| Reducers | 3 |
| Colonnes du résultat | categorie, rang, produit, nb_transactions, ca_centimes, ca |

**En-tête :** le mapper ignore la ligne dont le premier champ vaut `transaction_id`. Elle n'apparaît que dans le premier bloc HDFS, donc dans une seule tâche map (compteur `Qualite/Entete_ignoree` = 1).

**Montants :** `quantity × unit_price` calculé en centimes entiers via `Decimal`, sans flottant.

**Tri avant réduction :** Clé de tri sur 2 champs (`stream.num.map.output.key.fields=2`), partitionnement sur la catégorie seule (`KeyFieldBasedPartitioner -k1,1`) : une catégorie entière arrive au même reducer, triée par produit. Le reducer cumule chaque produit puis, au changement de catégorie, classe les produits et émet les 3 premiers (ou moins si la catégorie compte moins de 3 produits). Les 3 sorties sont fusionnées et triées à la fin.

**Lancement :** `bash traitements/T4/commande.sh` enchaîne le test local, le job YARN, l'écriture de `resultat.txt` et la validation indépendante.
