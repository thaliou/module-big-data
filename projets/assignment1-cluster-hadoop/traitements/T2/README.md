# T2 — Ventes par catégorie

**Objectif :** Comparer les catégories en volume (transactions, quantités) et en valeur.

| | |
|---|---|
| Entrée | `/assignment/transactions/transactions.csv` |
| Sortie HDFS | `/assignment/resultats/T2` |
| Clé émise par le mapper | `category` |
| Valeur | `quantite`, `montant_centimes` |
| Reducers | 1 |
| Colonnes du résultat | categorie, nb_transactions, quantite_totale, ca_centimes, ca |

**En-tête :** le mapper ignore la ligne dont le premier champ vaut `transaction_id`. Elle n'apparaît que dans le premier bloc HDFS, donc dans une seule tâche map (compteur `Qualite/Entete_ignoree` = 1).

**Montants :** `quantity × unit_price` calculé en centimes entiers via `Decimal`, sans flottant.

**Tri avant réduction :** Le reducer additionne trois indicateurs à la fois pour chaque clé.

**Lancement :** `bash traitements/T2/commande.sh` enchaîne le test local, le job YARN, l'écriture de `resultat.txt` et la validation indépendante.
