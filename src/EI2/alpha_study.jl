using LinearAlgebra
include("tp2_q1.jl")   # createPool(A,C,alpha,budget,poolSize), loadSPP, ...

alphas = [0.1, 0.3, 0.5, 0.7, 0.9]
poolSizes = [3, 5, 10]
budget = 10            # seconds of GRASP + path relinking per run
runs = 3               # runs per setting (the method is random)

datdir = normpath(joinpath(@__DIR__, "..", "..", "dat"))   # works from any working directory
instances = joinpath.(datdir, ["pb_100rnd0100.dat",
                               "pb_200rnd0100.dat",
                               "pb_200rnd1700.dat",
                               "pb_500rnd0100.dat"])

mkpath(joinpath(@__DIR__, "..", "..", "res")) #create if the res doesnt exists
out = open(joinpath(@__DIR__, "..", "..", "res", "alpha_study.csv"), "w") #open output file csv
println(out, "instance,pool_size,alpha,run,z,t") #headers

for fname in instances
    local C, A, x, z      # tp2_q1.jl already defines globals with these names
    C, A = loadSPP(fname)

    for pSize in poolSizes
        for a in alphas
            for run in 1:runs
                t = @elapsed (x, z) = createPool(A, C, a, budget, pSize)

                println(basename(fname), "  pool = ", pSize, "  alpha = ", a, "  run ", run, " : z = ", z, " (", round(t, digits=2), "s)")

                println(out, basename(fname), ",", pSize, ",", a, ",", run, ",", z, ",", t)
                flush(out)
            end
        end
    end
end
close(out)
