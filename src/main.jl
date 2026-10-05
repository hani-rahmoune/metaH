# =========================================================================== #
# Compliant julia 1.x

# Using the following packages
using JuMP, GLPK
using LinearAlgebra

include("loadSPP.jl")
include("setSPP.jl")
include("getfname.jl")
include("constructSPP.jl")
include("question2.jl")

# =========================================================================== #

# Loading a SPP instance
println("\nLoading...")
datdir = normpath(joinpath(@__DIR__, "..", "dat"))   
fname = joinpath(datdir, "didactic.dat")
C, A = loadSPP(fname)
@show C
@show A

# Solving a SPP instance with GLPK
println("\nSolving...")
solverSelected = GLPK.Optimizer
spp = setSPP(C, A)

set_optimizer(spp, solverSelected)
optimize!(spp)

# Displaying the results
println("z = ", objective_value(spp))
print("x = "); println(value.(spp[:x]))

# =========================================================================== #

# Collecting the names of instances to solve
println("\nCollecting...")
target = datdir
fnames = getfname(target)

println("\nThat's all folks !")

# =========================================================================== #
# ex1 q1 heuristique de construction 
case1 = greedyOnlyCost(A,C)
case2 = greedyRatio(A,C)
println(case1)
println("ratio : ")
println(case2)

# =========================================================================== #
# ex1 q2 heuristique de recherche locale
simple = descentSimple(A,C)
deep = deepDescent(A,C)
println("descente simple: ")
println(simple)
println("plus profonde descente")
println(deep)

#testing all the data at once 
instances = joinpath.(datdir, ["didactic.dat",
                               "pb_100rnd0100.dat",
                               "pb_200rnd0100.dat",
                               "pb_500rnd0100.dat",
                               "pb_1000rnd0100.dat",
                               "pb_2000rnd0100.dat"])

for fname in instances
    local C, A = loadSPP(fname)

    # Q1 : construction (reference)
    t1 = @elapsed (x1, z1) = greedyOnlyCost(A, C)
    t2 = @elapsed (x2, z2) = greedyRatio(A, C)

    # Q2 : recherche locale (question2.jl), construit x0 via greedyRatio en interne
    ts = @elapsed (xs, zs) = descentSimple(A, C)
    td = @elapsed (xd, zd) = deepDescent(A, C)

    println(fname)
    println("  construction cost only : z0 = ", z1, " (", round(t1, digits=5), "s)")
    println("  construction ratio     : z0 = ", z2, " (", round(t2, digits=5), "s)")
    println("  descentSimple (Q2)     : z = ", zs, " (", round(ts, digits=5), "s)") 
    println("  deepDescent (Q2)       : z = ", zd, " (", round(td, digits=5), "s)")
end