#!/usr/bin/env python3
# T2 - Ventes par catégorie : reducer
# Entrée triée par catégorie : category<TAB>quantite<TAB>centimes
# Sortie : category<TAB>nb_transactions<TAB>quantite_totale<TAB>ca_centimes<TAB>ca_unites
import sys


def formater(c):
    return "{}.{:02d}".format(c // 100, c % 100)


def emettre(cle, nb, qte, total):
    print("{}\t{}\t{}\t{}\t{}".format(cle, nb, qte, total, formater(total)))


cle_courante, nb, qte, total = None, 0, 0, 0

for ligne in sys.stdin:
    cle, quantite, montant = ligne.rstrip("\n").split("\t")
    if cle != cle_courante:
        if cle_courante is not None:
            emettre(cle_courante, nb, qte, total)
        cle_courante, nb, qte, total = cle, 0, 0, 0
    nb += 1
    qte += int(quantite)
    total += int(montant)

if cle_courante is not None:
    emettre(cle_courante, nb, qte, total)
