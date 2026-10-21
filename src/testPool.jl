using LinearAlgebra
include("tp2_q1.jl")   # createPool(A,C,alpha,budget), loadSPP, ...

alpha = 0.5
budget = 10            # seconds of GRASP + path relinking per instance

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
out = open(joinpath(@__DIR__, "..", "res", "pool.csv"), "w") #open output file csv
println(out, "instance,z_pool,t_pool") #headers

for fname in instances
    local C, A, x, z      # tp2_q1.jl already defines globals with these names
    C, A = loadSPP(fname)

    # GRASP (ratio) + path relinking with a pool
    t = @elapsed (x, z) = createPool(A, C, alpha, budget)

    println(fname)
    println("  createPool (grasp + path relinking) : z = ", z, " (", round(t, digits=5), "s)")

    println(out, basename(fname), ",", z, ",", t)
end
close(out)
