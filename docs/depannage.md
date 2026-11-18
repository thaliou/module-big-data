# Dépannage

| Symptôme | Cause probable | Solution |
|---|---|---|
| Un service n'est pas `Up` dans `docker compose ps` | Démarrage lent ou erreur de config | `docker compose logs --tail=80 <service>` |
| `Live datanodes (0)` | DataNode pas encore enregistré, ou arrêté | Attendre 30 s, vérifier `docker compose logs datanode` |
| `Name node is in safe mode` | HDFS en lecture seule au démarrage | `docker compose exec namenode hdfs dfsadmin -safemode wait` |
| `Output directory ... already exists` | Hadoop refuse d'écraser une sortie | `hdfs dfs -rm -r -f /data/sales_output_python` avant le job |
| Job `FAILED`, erreur `PipeMapRed.waitOutputThreads(): subprocess failed with code 127` | Python introuvable dans le conteneur | Vérifier `docker compose exec nodemanager python3 --version` |
| Même erreur, code `1` ou `2` | Erreur dans `mapper.py` / `reducer.py` | Tester en local (voir ci-dessous) |
| `/usr/bin/env: 'python3\r': No such file or directory` | Fins de ligne Windows (CRLF) dans les scripts | Le `.gitattributes` force LF ; sinon `dos2unix *.py` ou changer CRLF → LF dans l'éditeur |
| Syntaxe Python refusée dans le cluster | Python 3.6.8 : pas de f-string `=`, pas de walrus `:=`, etc. | Écrire du Python compatible 3.6 |
| Lien `nodemanager:8042` ou `datanode:9864` inaccessible | Adresse interne au réseau Docker | Voir [interfaces-web.md](interfaces-web.md) |
| Plus de données HDFS après redémarrage | `docker compose down -v` a supprimé les volumes | Utiliser `docker compose down` ou `stop` sans `-v` |
| Docker Desktop ne démarre pas (Windows) | WSL2 / virtualisation désactivés | `wsl --list --verbose`, activer la virtualisation dans le BIOS |

## Tester le job sans Hadoop

Hadoop Streaming reproduit simplement un pipeline Unix. Avant de lancer le job sur le cluster, on peut valider la logique en local :

```bash
cd tps/tp00-environnement-hadoop
cat data/sales.csv | python3 src/mapper.py | sort | python3 src/reducer.py
```

Le `sort` joue le rôle du *shuffle & sort* de Hadoop : le reducer reçoit les lignes regroupées par clé.
