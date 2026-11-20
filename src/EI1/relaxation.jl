# Relaxation lineaire des instances : borne superieure de l'optimum
# Meme modele que setSPP, mais x continu dans [0,1] au lieu de binaire.

using JuMP, GLPK, LinearAlgebra
include("loadSPP.jl")

datdir = normpath(joinpath(@__DIR__, "..", "..", "dat"))
instances = ["didactic.dat",
             "pb_100rnd0100.dat", "pb_100rnd0300.dat", "pb_100rnd0500.dat",
             "pb_200rnd0100.dat", "pb_200rnd0900.dat", "pb_200rnd1700.dat",
             "pb_500rnd0100.dat", "pb_500rnd0500.dat",
             "pb_1000rnd0100.dat", "pb_2000rnd0100.dat"]

out = open(joinpath(@__DIR__, "..", "..", "res", "relaxation.csv"), "w")
println(out, "instance,z_lp,t_solver")

for f in instances
    C, A = loadSPP(joinpath(datdir, f))
    m, n = size(A)

    spp = Model(GLPK.Optimizer)
    @variable(spp, 0 <= x[1:n] <= 1)                  # relaxation : x continu
    @objective(spp, Max, dot(C, x))
    @constraint(spp, cte[i=1:m], sum(A[i,j] * x[j] for j=1:n) <= 1)
    set_silent(spp)

    t = @elapsed optimize!(spp)
    z = objective_value(spp)

    println(f, "  z_LP=", round(z, digits=2), "  t=", round(t, digits=3), "s")
    println(out, f, ",", z, ",", t)
end

close(out)
