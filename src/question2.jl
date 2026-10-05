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
                if(C[i]>C[j] && i!=j && res[i]==0) # checks if the cost is higher and its not the same element and its not already in the result list 
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



#same logic as the previous one we just try to find a better fit everytime we get a higher score incase some conflict were resolved after the changes were made 
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
                    if(C[i]>C[j] && i!=j && res[i]==0)
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

