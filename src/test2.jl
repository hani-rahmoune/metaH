C = [10, 9, 8, 7]
 
A = [
    1 1 0 0   # element 1
    0 1 1 0   # element 2
    0 0 1 1   # element 3
]

c1 = [5, 4, 3, 8, 5]
 
B= [
    1 0 0 1 0   # element 1
    0 1 0 1 0   # element 2
    0 1 0 0 1   # element 3
    0 0 1 0 0   # element 4
    0 0 0 0 1   # element 5 (remplissage)
    0 0 0 0 1   # element 6 (remplissage)
]
using LinearAlgebra
include("constructSPP.jl")

#for every chosen number we check if theres a number with a higher cost that does not conflict with the other chosen number and doing this for every chosen one afterward 
function descentSimple(A,C)
    res,z = greedyRatio(A,C)
    n,m= size(A)
    rows = getRow(A) #[[1][1,2],[3,4],[4]]
    for j in eachindex(res)
        if res[j] ==1 
            for i in eachindex(C)
                if(C[i]>C[j] && i!=j)
                    noConflict = true 
                    for x in eachindex(rows)
                        if !isempty(intersect(rows[i],rows[x])) && x !=j && res[x] == 1 
                            noConflict = false 
                        end   
                    end
                    if noConflict == true 
                        res[j] = 0 
                        res[i] = 1
                        break
                    end 
                end     
            end
        end
    end
    return res,dot(C,res)
end

res,z = greedyRatio(B,c1)
println(res,z)
r,z1 = descentSimple(B,c1)
println(r,z1)


function deepDescent(A,C)
    res,z = greedyRatio(A,C)
    n,m= size(A)
    rows = getRow(A) #[[1][1,2],[3,4],[4]]
    betterCost = true 
    while(betterCost)
        betterCost = false 
        for j in eachindex(res)
            if res[j] ==1 
                for i in eachindex(C)
                    if(C[i]>C[j] && i!=j)
                        noConflict = true 
                        for x in eachindex(rows)
                            if !isempty(intersect(rows[i],rows[x])) && x !=j && res[x] == 1 
                                noConflict = false 
                            end   
                        end
                        if noConflict == true 
                            res[j] = 0 
                            res[i] = 1
                            betterCost = true 
                            break
                        end 
                    end     
                end
            end
        end
    end
    return res,dot(C,res)
end

deepR,z2 = deepDescent(B,c1)
println(deepR,z2)