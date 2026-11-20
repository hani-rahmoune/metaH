using LinearAlgebra, Statistics
include("tp2_q1.jl")

budget = 60            # run length in seconds
runs = 10              # runs per method and instance
steps = 10:10:60       # best z found so far is read at these times

# best alpha and best pool size, got from the parameter study csv
include("best_params.jl")
alpha, poolSize = bestParams(joinpath(@__DIR__, "..", "..", "res", "alpha_study.csv"))

datdir = normpath(joinpath(@__DIR__, "..", "..", "dat"))
instances = joinpath.(datdir, ["pb_200rnd0100.dat",
                               "pb_200rnd1700.dat",
                               "pb_500rnd0100.dat",
                               "pb_1000rnd0100.dat"])

mkpath(joinpath(@__DIR__, "..", "..", "res"))
out = open(joinpath(@__DIR__, "..", "..", "res", "experiment_trace.csv"), "w")
println(out, "instance,method,run,t,z")   # z is empty when no iteration had finished at time t

for fname in instances
    local C, A, x, z      # tp2_q1.jl already defines globals with these names
    C, A = loadSPP(fname)

    for method in ["grasp", "vnd", "pool"]
        for run in 1:runs
            trace = Tuple{Float64,Int}[]    # (time, best z so far) after each iteration

            if method == "grasp"
                t0 = time()
                bestZ = 0
                while time() - t0 < budget
                    x, z = graspRatio(A, C, alpha)
                    x, z, _ = descentSimple(A, C, x)
                    bestZ = max(bestZ, z)
                    push!(trace, (time() - t0, bestZ))
                end
            elseif method == "vnd"
                graspVnd(A, C, alpha, budget, trace)
            else
                createPool(A, C, alpha, budget, poolSize, trace)
            end

            for t in steps
                zt = ""
                for (ti, zi) in trace
                    if ti <= t
                        zt = zi
                    end
                end
                println(out, basename(fname), ",", method, ",", run, ",", t, ",", zt)
            end
            flush(out)
            println(basename(fname), "  ", method, "  run ", run, " : z = ", trace[end][2])
        end
    end
end
close(out)
