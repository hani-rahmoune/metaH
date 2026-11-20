# EI2 : metaheuristique GRASP sur le SPP (+ VND, + Path-Relinking)
#
#   include("livrableEI2.jl")
#   resoudreSPP("dat/pb_100rnd0100.dat")
#   experimentationSPP()


using LinearAlgebra, Statistics

# tp2_q1.jl : grasp, graspRatio, vnd, graspVnd, path_Relinking, createPool
# (il affiche un test a l'inclusion : on masque cette sortie)
redirect_stdout(devnull) do
    include(joinpath(@__DIR__, "src", "EI2", "tp2_q1.jl"))
end

# reglages retenus par l'etude des parametres (res/alpha_study.csv)
const ALPHA = 0.5
const POOLSIZE = 10

# une execution de la methode choisie pendant `budget` secondes ; retourne (x, z)
#   :pool  GRASP + path relinking (methode principale)
#   :vnd   GRASP + VND
#   :grasp GRASP simple (construction ratio + descente simple)
function lancerMethode(A, C, methode, budget, alpha, poolSize)
    if methode == :pool
        return createPool(A, C, alpha, budget, poolSize)
    elseif methode == :vnd
        return graspVnd(A, C, alpha, budget)
    elseif methode == :grasp
        t0 = time()
        x, z = graspRatio(A, C, alpha)
        x, z, _ = descentSimple(A, C, x)
        while time() - t0 < budget
            xn, zn = graspRatio(A, C, alpha)
            xn, zn, _ = descentSimple(A, C, xn)
            if zn > z
                x, z = xn, zn
            end
        end
        return x, z
    else
        error("methode inconnue : ", methode, " (choisir :pool, :vnd ou :grasp)")
    end
end

#resoudreSPP(fname) : resout une instance (fname : chemin du fichier .dat)
# methode  : :pool (defaut), :vnd ou :grasp
#   budget   : duree de la resolution en secondes
function resoudreSPP(fname; methode=:pool, budget=60, alpha=ALPHA, poolSize=POOLSIZE)
    C, A = loadSPP(fname)
    t = @elapsed (x, z) = lancerMethode(A, C, methode, budget, alpha, poolSize)
    faisable = maximum(A * x) <= 1
    println(basename(fname), "  methode ", methode, "  alpha = ", alpha, "  budget = ", budget, " s")
    println("  z = ", z, "  (", round(t, digits=2), " s)   solution realisable : ", faisable)
    return x, z
end

# experimentationSPP() : `runs` executions sur chacune des 10 instances,
# ecrit res/EI2_experimentation_<methode>.csv (z min, z max, z moyen)
instancesEI2 = ["pb_100rnd0100.dat", "pb_100rnd0300.dat", "pb_100rnd0500.dat",
                "pb_200rnd0100.dat", "pb_200rnd0900.dat", "pb_200rnd1700.dat",
                "pb_500rnd0100.dat", "pb_500rnd0500.dat",
                "pb_1000rnd0100.dat", "pb_2000rnd0100.dat"]

function experimentationSPP(; methode=:pool, budget=60, runs=10, alpha=ALPHA, poolSize=POOLSIZE, instances=instancesEI2)
    mkpath(joinpath(@__DIR__, "res"))
    out = open(joinpath(@__DIR__, "res", "EI2_experimentation_" * string(methode) * ".csv"), "w")
    println(out, "instance,z_min,z_max,z_mean")
    for f in instances
        C, A = loadSPP(joinpath(@__DIR__, "dat", f))
        zs = Int[]
        for run in 1:runs
            x, z = lancerMethode(A, C, methode, budget, alpha, poolSize)
            push!(zs, z)
        end
        println(f, "  ", methode, "  z min = ", minimum(zs), "  z max = ", maximum(zs), "  z moyen = ", round(mean(zs), digits=2))
        println(out, f, ",", minimum(zs), ",", maximum(zs), ",", round(mean(zs), digits=2))
        flush(out)
    end
    close(out)
    println("resultats : res/EI2_experimentation_", methode, ".csv")
end
