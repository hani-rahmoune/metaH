SPP : Set Packing Problem (ponderé) - EI1 et EI2
===============================================

Organisation du dossier
-----------------------
  livrableEI1.jl   point d'entree de l'EI1 (construction, descentes, solution exacte)
  livrableEI2.jl   point d'entree de l'EI2 (GRASP, GRASP + VND, GRASP + Path-Relinking)
  src/EI1/         codes sources Julia de l'EI1 (construction, descentes, solution exacte)
  src/EI2/         codes sources Julia de l'EI2 (GRASP, VND, Path-Relinking) ; reutilise src/EI1/
  src/old/         anciens brouillons (non utilises)
  dat/             instances (format OR-library)
  res/             fichiers de resultats (.csv)
  doc/             documentation

Prerequis
---------
Julia 1.x avec les paquets JuMP et GLPK (Pkg.add(["JuMP", "GLPK"])).
Les chemins sont calcules a partir de l'emplacement des fichiers livrable*.jl :
se placer dans le dossier, lancer julia, puis les commandes ci-dessous.

EI1
---
  include("livrableEI1.jl")
  resoudreSPP("dat/pb_100rnd0100.dat")     # une instance : constructions, descentes, solution exacte
  experimentationSPP()                     # les 10 instances ; ecrit res/EI1_experimentation.csv

Variantes :
  resoudreSPP(fname, exact=false)          # sans la resolution exacte (GLPK)
  resoudreSPP(fname, timelimit=300)        # limite de temps de GLPK en secondes (defaut 60)
  experimentationSPP(exact=false)

EI2
---
  include("livrableEI2.jl")
  resoudreSPP("dat/pb_100rnd0100.dat")     # GRASP + Path-Relinking pendant 60 s
  experimentationSPP()                     # 10 instances x 10 executions de 60 s ; ecrit res/EI2_experimentation_pool.csv

Variantes :
  resoudreSPP(fname, budget=10)                      # duree en secondes (defaut 60)
  resoudreSPP(fname, methode=:vnd)                   # GRASP + VND
  resoudreSPP(fname, methode=:grasp)                 # GRASP simple (construction ratio + descente simple)
  experimentationSPP(budget=5, runs=2)               # essai rapide
  experimentationSPP(methode=:vnd)                   # ecrit res/EI2_experimentation_vnd.csv
  Reglages par defaut : alpha = 0.5 (alpha=...), taille du pool = 10 (poolSize=...), issus de l'etude res/alpha_study.csv.

Remarques :
  - livrableEI1.jl et livrableEI2.jl definissent les memes noms de fonctions : charger un seul des deux par session Julia.
  - experimentationSPP() de l'EI2 avec les valeurs par defaut dure environ 100 minutes (10 instances x 10 x 60 s).
  - Les descentes et le VND sont lents sur les instances de 1000 et 2000 variables : une iteration peut depasser le budget.

Scripts d'experimentation (a lancer depuis leur dossier avec : julia nom_du_fichier.jl)
----------------------------------------------------------------------------------
  EI1/testHeuristics.jl       res/heuristiques.csv        EI1 : constructions et descentes
  EI1/exact.jl                res/exact.csv               EI1 : solution exacte (JuMP + GLPK, 300 s max par instance)
  EI1/relaxation.jl           res/relaxation.csv          EI1 : relaxation lineaire (borne superieure)
  EI2/alpha_study.jl          res/alpha_study.csv         EI2 : etude de alpha et de la taille du pool
  EI2/experiment_grasp.jl     res/experiment_grasp*.csv   EI2 : GRASP simple, 10 executions de 60 s
  EI2/experiment_vnd.jl       res/experiment_vnd*.csv     EI2 : GRASP + VND
  EI2/experiment_pool.jl      res/experiment_pool*.csv    EI2 : GRASP + Path-Relinking
  EI2/experiment_trace.jl     res/experiment_trace.csv    EI2 : valeur atteinte a 10, 20, ... 60 s (les 3 methodes, 4 instances)

Le dossier latex/ contient le rapport (CR type EI.tex, qui inclut CR_EI1.tex et CR_EI2.tex,
avec tables/ et figures/). Compilation depuis latex/ : pdflatex "CR type EI.tex" (deux passes).
