#!/usr/bin/env python3
# T4 - Top 3 des produits par chiffre d'affaires dans chaque catégorie : reducer
# Entrée triée par (catégorie, produit) : category<TAB>product<TAB>centimes
# Sortie : category<TAB>rang<TAB>product<TAB>nb_transactions<TAB>ca_centimes<TAB>ca_unites
#
# Deux niveaux de regroupement grâce au tri :
#  - changement de produit   -> le total du produit précédent est complet ;
#  - changement de catégorie -> tous les produits de la catégorie sont connus : on classe et on émet le top 3.
import sys

TOP = 3


def formater(c):
    return "{}.{:02d}".format(c // 100, c % 100)


def emettre_top(categorie, produits):
    # Tri par CA décroissant ; à égalité, ordre alphabétique pour un résultat déterministe
    classes = sorted(produits, key=lambda p: (-p[2], p[0]))[:TOP]
    for rang, (produit, nb, total) in enumerate(classes, 1):
        print("{}\t{}\t{}\t{}\t{}\t{}".format(categorie, rang, produit, nb, total, formater(total)))


cat_courante, prod_courant = None, None
nb, total = 0, 0
produits = []          # produits terminés de la catégorie courante : (produit, nb, total)

for ligne in sys.stdin:
    categorie, produit, montant = ligne.rstrip("\n").split("\t")
    if (categorie, produit) != (cat_courante, prod_courant):
        if prod_courant is not None:
            produits.append((prod_courant, nb, total))
        if categorie != cat_courante:
            if cat_courante is not None:
                emettre_top(cat_courante, produits)
            cat_courante, produits = categorie, []
        prod_courant, nb, total = produit, 0, 0
    nb += 1
    total += int(montant)

if prod_courant is not None:
    produits.append((prod_courant, nb, total))
    emettre_top(cat_courante, produits)
