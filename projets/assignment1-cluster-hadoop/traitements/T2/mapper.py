#!/usr/bin/env python3
# T2 - Ventes par catégorie : mapper
# Sortie : category<TAB>quantite<TAB>montant_en_centimes
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
        quantite = int(champs[6])
        montant = quantite * centimes(champs[7])
    except (ValueError, InvalidOperation):
        compteur("Ligne_invalide")
        continue
    print("{}\t{}\t{}".format(champs[5].strip(), quantite, montant))
    compteur("Ligne_valide")
