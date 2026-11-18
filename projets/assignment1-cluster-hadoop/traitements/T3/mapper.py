#!/usr/bin/env python3
# T3 - Chiffre d'affaires mensuel : mapper
# Sortie : AAAA-MM<TAB>montant_en_centimes
# La clé AAAA-MM se trie dans l'ordre chronologique : le shuffle & sort livre les mois dans l'ordre.
import csv
import sys
from decimal import Decimal, InvalidOperation


def compteur(nom):
    sys.stderr.write("reporter:counter:Qualite,{},1\n".format(nom))


def centimes(prix):
    return int((Decimal(prix) * 100).to_integral_value())


def mois(date):
    # Accepte AAAA-MM-JJ[...], AAAA/MM/JJ et JJ/MM/AAAA ; renvoie AAAA-MM
    d = date.strip()
    if len(d) >= 7 and d[4] in "-/" and d[:4].isdigit():
        return d[:4] + "-" + d[5:7]
    if len(d) >= 10 and d[2] == "/" and d[5] == "/":
        return d[6:10] + "-" + d[3:5]
    raise ValueError(date)


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
        cle = mois(champs[1])
        montant = int(champs[6]) * centimes(champs[7])
    except (ValueError, InvalidOperation):
        compteur("Ligne_invalide")
        continue
    print("{}\t{}".format(cle, montant))
    compteur("Ligne_valide")
