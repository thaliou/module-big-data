# T1 — Chiffre d'affaires par pays

**Objectif :** Mesurer le poids commercial de chaque pays.

| | |
|---|---|
| Entrée | `/assignment/transactions/transactions.csv` |
| Sortie HDFS | `/assignment/resultats/T1` |
| Clé émise par le mapper | `country` |
| Valeur | `montant_centimes` |
| Reducers | 1 |
| Colonnes du résultat | pays, nb_transactions, ca_centimes, ca |

**En-tête :** le mapper ignore la ligne dont le premier champ vaut `transaction_id`. Elle n'apparaît que dans le premier bloc HDFS, donc dans une seule tâche map (compteur `Qualite/Entete_ignoree` = 1).

**Montants :** `quantity × unit_price` calculé en centimes entiers via `Decimal`, sans flottant.

**Tri avant réduction :** Un seul reducer : la sortie est directement triée par pays.

**Lancement :** `bash traitements/T1/commande.sh` enchaîne le test local, le job YARN, l'écriture de `resultat.txt` et la validation indépendante.
