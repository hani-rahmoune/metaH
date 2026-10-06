# EI1 Q4 : exact solution of the SPP instances with JuMP + GLPK

using JuMP, GLPK, LinearAlgebra
include("loadSPP.jl")
include("setSPP.jl")

datdir = normpath(joinpath(@__DIR__, "..", "dat"))
instances = ["didactic.dat",
             "pb_100rnd0100.dat", "pb_100rnd0300.dat", "pb_100rnd0500.dat",
             "pb_200rnd0100.dat", "pb_200rnd0900.dat", "pb_200rnd1700.dat",
             "pb_500rnd0100.dat", "pb_500rnd0500.dat",
             "pb_1000rnd0100.dat", "pb_2000rnd0100.dat"]

out = open(joinpath(@__DIR__, "..", "res", "exact.csv"), "w")
println(out, "instance,z_opt,t_solver,status") #headers 

for f in instances
    C, A = loadSPP(joinpath(datdir, f))
    spp = setSPP(C, A) #create a jump model from this data 
    set_optimizer(spp, GLPK.Optimizer) # attach glpk to the model 
    set_silent(spp) #no progress log 
    set_time_limit_sec(spp, 300) # stop after 5min at most 

    t = @elapsed optimize!(spp) #returns time 
    z = objective_value(spp) # z0
    status = termination_status(spp)# reason why the solver stopped optimal all good time limit is self explanatory 

    println(f, "  z=", z, "  t=", round(t, digits=3), "s  ", status)
    println(out, f, ",", z, ",", t, ",", status)
end

close(out)
