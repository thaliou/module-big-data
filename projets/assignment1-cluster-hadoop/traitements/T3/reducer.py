#!/usr/bin/env python3
# T3 - Chiffre d'affaires mensuel : reducer
# Entrée triée par mois (AAAA-MM) : mois<TAB>centimes
# Sortie : mois<TAB>nb_transactions<TAB>ca_centimes<TAB>ca_unites
import sys


def formater(c):
    return "{}.{:02d}".format(c // 100, c % 100)


cle_courante, nb, total = None, 0, 0

for ligne in sys.stdin:
    cle, valeur = ligne.rstrip("\n").split("\t")
    if cle != cle_courante:
        # Les lignes arrivent triées : un changement de clé signifie que le groupe précédent est complet
        if cle_courante is not None:
            print("{}\t{}\t{}\t{}".format(cle_courante, nb, total, formater(total)))
        cle_courante, nb, total = cle, 0, 0
    nb += 1
    total += int(valeur)

if cle_courante is not None:
    print("{}\t{}\t{}\t{}".format(cle_courante, nb, total, formater(total)))
