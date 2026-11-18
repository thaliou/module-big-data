#!/usr/bin/env python3
# T1 - Chiffre d'affaires par pays : mapper
# Entrée : lignes CSV (transaction_id,date,country,city,product,category,quantity,unit_price,payment_method)
# Sortie : country<TAB>montant_en_centimes
import csv
import sys
from decimal import Decimal, InvalidOperation


def compteur(nom):
    # Compteur Hadoop Streaming, visible dans l'interface YARN et la sortie du job
    sys.stderr.write("reporter:counter:Qualite,{},1\n".format(nom))


def centimes(prix):
    # Decimal évite les erreurs d'arrondi des flottants : "19.99" -> 1999
    return int((Decimal(prix) * 100).to_integral_value())


for champs in csv.reader(sys.stdin):
    if not champs:
        continue
    if champs[0].strip() == "transaction_id":   # en-tête : présent seulement dans le 1er bloc
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
    pays = champs[2].strip()
    print("{}\t{}".format(pays, montant))
    compteur("Ligne_valide")
