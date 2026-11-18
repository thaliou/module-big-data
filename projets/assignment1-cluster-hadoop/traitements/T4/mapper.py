#!/usr/bin/env python3
# T4 - Top 3 des produits par chiffre d'affaires dans chaque catégorie : mapper
# Sortie à clé composée : category<TAB>product<TAB>montant_en_centimes
# Les deux premiers champs forment la clé (stream.num.map.output.key.fields=2) ;
# le partitionnement se fait sur la catégorie seule pour qu'une catégorie entière arrive au même reducer.
import csv
import sys
from decimal import Decimal, InvalidOperation


def compteur(nom):
    sys.stderr.write("reporter:counter:Qualite,{},1\n".format(nom))


def centimes(prix):
    return int((Decimal(prix) * 100).to_integral_value())


for champs in csv.reader(sys.stdin):
    if not champs:
        continue
    if champs[0].strip() == "transaction_id":
        compteur("Entete_ignoree")
        continue
    if len(champs) != 9:
        compteur("Ligne_invalide")
        continue
    try:
        montant = int(champs[6]) * centimes(champs[7])
    except (ValueError, InvalidOperation):
        compteur("Ligne_invalide")
        continue
    print("{}\t{}\t{}".format(champs[5].strip(), champs[4].strip(), montant))
    compteur("Ligne_valide")
