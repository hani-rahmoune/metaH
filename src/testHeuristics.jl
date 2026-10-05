using LinearAlgebra
include("loadSPP.jl")
#include("question2.jl")   # includes constructSPP.jl itself
include("rechercheLocale.jl")



datdir = normpath(joinpath(@__DIR__, "..", "dat"))   # works from any working directory
instances = joinpath.(datdir, ["didactic.dat",
                               "pb_100rnd0100.dat",
                               "pb_100rnd0300.dat",
                               "pb_100rnd0500.dat",
                               "pb_200rnd0100.dat",
                               "pb_200rnd0900.dat",
                               "pb_200rnd1700.dat",
                               "pb_500rnd0100.dat",
                               "pb_500rnd0500.dat",
                               "pb_1000rnd0100.dat",
                               "pb_2000rnd0100.dat"])

mkpath(joinpath(@__DIR__, "..", "res")) #create if the res doesnt exists 
out = open(joinpath(@__DIR__, "..", "res", "heuristiques.csv"), "w") #open output file csv 
println(out, "instance,z_cost,t_cost,z_ratio,t_ratio,z_simple,t_simple,z_deep,t_deep") #headers 

for fname in instances
    C, A = loadSPP(fname)

    # Q1 : construction (reference)
    t1 = @elapsed (x1, z1) = constructionCostOnly(C, A)
    t2 = @elapsed (x2, z2) = constructionRatio(C, A)

    # Q2 : recherche locale (question2.jl)
    ts = @elapsed (xs, zs) =descenteSimple(C, A)
    td = @elapsed (xd, zd) = deepDescent(C, A)

    println(fname)
    println("  construction cost only : z0 = ", z1, " (", round(t1, digits=5), "s)")
    println("  construction ratio     : z0 = ", z2, " (", round(t2, digits=5), "s)")
    println("  descentSimple (Q2)     : z = ", zs, " (", round(ts, digits=5), "s)") 
    println("  deepDescent (Q2)       : z = ", zd, " (", round(td, digits=5), "s)")

    println(out, basename(fname), ",", z1, ",", t1, ",", z2, ",", t2, ",", zs, ",", ts, ",", zd, ",", td)
end
close(out)
