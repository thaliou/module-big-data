# T3 — Chiffre d'affaires mensuel

**Objectif :** Suivre l'évolution des ventes dans le temps.

| | |
|---|---|
| Entrée | `/assignment/transactions/transactions.csv` |
| Sortie HDFS | `/assignment/resultats/T3` |
| Clé émise par le mapper | `AAAA-MM` (extrait de `date`) |
| Valeur | `montant_centimes` |
| Reducers | 1 |
| Colonnes du résultat | mois, nb_transactions, ca_centimes, ca |

**En-tête :** le mapper ignore la ligne dont le premier champ vaut `transaction_id`. Elle n'apparaît que dans le premier bloc HDFS, donc dans une seule tâche map (compteur `Qualite/Entete_ignoree` = 1).

**Montants :** `quantity × unit_price` calculé en centimes entiers via `Decimal`, sans flottant.

**Tri avant réduction :** La clé AAAA-MM se trie naturellement dans l'ordre chronologique : le shuffle & sort livre les mois dans l'ordre, sans tri supplémentaire.

**Lancement :** `bash traitements/T3/commande.sh` enchaîne le test local, le job YARN, l'écriture de `resultat.txt` et la validation indépendante.
