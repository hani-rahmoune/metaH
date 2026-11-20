using LinearAlgebra, Statistics
include("tp2_q1.jl") 

budget = 60            # run length for plain grasp (ratio + descentSimple) 
runs = 10              # 10 fois sur la meme machine 

# best alpha and best pool size  from the parameter study csv using best params file 
include("best_params.jl")
alpha, poolSize = bestParams(joinpath(@__DIR__, "..", "..", "res", "alpha_study.csv"))

datdir = normpath(joinpath(@__DIR__, "..", "..", "dat"))   
instances = joinpath.(datdir, ["pb_100rnd0100.dat",
                               "pb_100rnd0300.dat",
                               "pb_100rnd0500.dat",
                               "pb_200rnd0100.dat",
                               "pb_200rnd0900.dat",
                               "pb_200rnd1700.dat",
                               "pb_500rnd0100.dat",
                               "pb_500rnd0500.dat",
                               "pb_1000rnd0100.dat",
                               "pb_2000rnd0100.dat"])

mkpath(joinpath(@__DIR__, "..", "..", "res")) 
out = open(joinpath(@__DIR__, "..", "..", "res", "experiment_grasp_runs.csv"), "w") #every run
println(out, "instance,run,z,t")
summary = open(joinpath(@__DIR__, "..", "..", "res", "experiment_grasp.csv"), "w") #min max mean per instance
println(summary, "instance,z_min,z_max,z_mean")

for fname in instances
    local C, A, x, z      #avoiding conflict with tp_q1
    
    C, A = loadSPP(fname)

    zs = Int[]
    for run in 1:runs
        t = @elapsed begin
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
        end
        push!(zs, z)

        println(basename(fname), "  run ", run, " : z = ", z, " (", round(t, digits=2), "s)")
        println(out, basename(fname), ",", run, ",", z, ",", t)
        flush(out)
    end

    println(basename(fname), "  z min = ", minimum(zs), "  z max = ", maximum(zs), "  z mean = ", round(mean(zs), digits=2))
    println(summary, basename(fname), ",", minimum(zs), ",", maximum(zs), ",", round(mean(zs), digits=2))
    flush(summary)
end
close(out)
close(summary)
