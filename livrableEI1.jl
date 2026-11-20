# =========================================================================== #
# EI1 : heuristique de construction et recherche locale pour le SPP
#
#   include("livrableEI1.jl")
#   resoudreSPP("dat/pb_100rnd0100.dat")
#   experimentationSPP()
# =========================================================================== #

using LinearAlgebra, JuMP, GLPK

include(joinpath(@__DIR__, "src", "EI1", "loadSPP.jl"))      # loadSPP(fname)
include(joinpath(@__DIR__, "src", "EI1", "setSPP.jl"))       # setSPP(C, A) : modele JuMP
include(joinpath(@__DIR__, "src", "EI1", "constructSPP.jl")) # greedyOnlyCost(A,C), greedyRatio(A,C)
include(joinpath(@__DIR__, "src", "EI1", "question2.jl"))    # descentSimple(A,C,x0), deepDescent(A,C,x0)

# --------------------------------------------------------------------------- #
# resolution exacte avec JuMP + GLPK (arret apres timelimit secondes)
function exactSPP(C, A, timelimit)
    spp = setSPP(C, A)
    set_optimizer(spp, GLPK.Optimizer)
    set_silent(spp)
    set_time_limit_sec(spp, timelimit)
    t = @elapsed optimize!(spp)
    return objective_value(spp), t, string(termination_status(spp))
end

# --------------------------------------------------------------------------- #
# resoudreSPP(fname) : resout une instance (fname : chemin du fichier .dat)
#   exact=false   : pas de resolution exacte
#   timelimit     : limite de temps (s) de la resolution exacte
function resoudreSPP(fname; exact=true, timelimit=60)
    C, A = loadSPP(fname)
    println(basename(fname), "   (", size(A, 1), " contraintes, ", size(A, 2), " variables)")

    t1 = @elapsed (x1, z1) = greedyOnlyCost(A, C)
    t2 = @elapsed (x2, z2) = greedyRatio(A, C)
    ts = @elapsed (xs, zs) = descentSimple(A, C, x2)
    td = @elapsed (xd, zd) = deepDescent(A, C, x2)

    println("  construction cout seul   : z = ", z1, "  (", round(t1, digits=5), " s)")
    println("  construction ratio       : z = ", z2, "  (", round(t2, digits=5), " s)")
    println("  descente simple          : z = ", zs, "  (", round(ts, digits=5), " s)")
    println("  plus profonde descente   : z = ", zd, "  (", round(td, digits=5), " s)")

    zbest = max(z1, z2, zs, zd)
    ze, te, status = NaN, NaN, "-"
    if exact
        ze, te, status = exactSPP(C, A, timelimit)
        println("  exact (JuMP + GLPK)      : z = ", ze, "  (", round(te, digits=3), " s)  ", status)
        println("  ecart du meilleur z^     : ", round(100 * (ze - zbest) / ze, digits=2), " %")
    end
    return (z_cost=z1, t_cost=t1, z_ratio=z2, t_ratio=t2, z_simple=zs, t_simple=ts,
            z_deep=zd, t_deep=td, z_exact=ze, t_exact=te, status=status)
end

# --------------------------------------------------------------------------- #
# experimentationSPP() : resout les 10 instances selectionnees, ecrit res/EI1_experimentation.csv
instancesEI1 = ["pb_100rnd0100.dat", "pb_100rnd0300.dat", "pb_100rnd0500.dat",
                "pb_200rnd0100.dat", "pb_200rnd0900.dat", "pb_200rnd1700.dat",
                "pb_500rnd0100.dat", "pb_500rnd0500.dat",
                "pb_1000rnd0100.dat", "pb_2000rnd0100.dat"]

function experimentationSPP(; exact=true, timelimit=60, instances=instancesEI1)
    mkpath(joinpath(@__DIR__, "res"))
    out = open(joinpath(@__DIR__, "res", "EI1_experimentation.csv"), "w")
    println(out, "instance,z_cost,t_cost,z_ratio,t_ratio,z_simple,t_simple,z_deep,t_deep,z_exact,t_exact,status")
    for f in instances
        r = resoudreSPP(joinpath(@__DIR__, "dat", f), exact=exact, timelimit=timelimit)
        println(out, f, ",", r.z_cost, ",", r.t_cost, ",", r.z_ratio, ",", r.t_ratio, ",", r.z_simple, ",", r.t_simple,
                ",", r.z_deep, ",", r.t_deep, ",", r.z_exact, ",", r.t_exact, ",", r.status)
        flush(out)
    end
    close(out)
    println("resultats : res/EI1_experimentation.csv")
end
