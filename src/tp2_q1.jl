using LinearAlgebra
include("constructSPP.jl")
include("loadSPP.jl")
include("question2.jl")
fname = joinpath(@__DIR__, "..", "dat", "didactic.dat")
C,A = loadSPP(fname)

function grasp(A,C,alpha,key= C)
    n,m = size(A)
    rows = getRow(A) # [1covers[1,3,4],2covers[]]
    result = zeros(Int ,m)
    sature = falses(n)
    candidats = collect(1:m) #to keep track of the indexes 

    while !isempty(candidats)
        best = maximum(key[candidats])
        worst = minimum(key[candidats])
        thershold = best - alpha *(best - worst)

        group = filter(x -> key[x]>= thershold , candidats) # we keep getting the right indexes cause we are using candidats and not C even when candidats gets smaller
        pick = rand(group)
        compatible = true 
        for i in rows[pick]
            if(sature[i])
                compatible = false 
                break
            end
        end
        if(compatible)
            result[pick] = 1
            for i in rows[pick]
                sature[i]=true 
            end
        end
        filter!(x ->x!=pick,candidats) #delete the picked one adding ! allows it to update the array  
    end
    return result , dot(result,C)
end

x =grasp(A,C,0.5)
println(x)

function graspOnlyCost(A,C,alpha)
    return grasp(A,C,alpha) #only cost matters 
end 
# case 2 cost and number of lines covered 
function graspRatio(A,C,alpha)
    n,m = size(A)
    rows = getRow(A)
    covers = [max(length(rows[j]),1) for j in 1:m] # get how many are covered for each j 
    ratio = [C[j]/covers[j] for j in 1:m] #[3,333,....]
    return grasp(A,C,alpha,ratio)
end


#helper functions 

function fits(used,row,i) #used : array of the covered rows by the solution row : row[i] is the rowers covered by i  (array of arrays) i :index 
    for x in row[i]
        if used[x] !=0
            return false
        end
    end
    return true 
end

function addSolution(used,result,i,row) #same used , #result : array where result[i]= 1 means i what a solution we took 
    result[i] = 1
    for x in row[i]
        used[x] += 1
    end
end

function removeSolution(used,result,i,row) #same used , #result : array where result[i]= 1 means i what a solution we took 
    result[i] = 0
    for x in row[i]
        used[x]-=1
    end
end


function vnd(A,C,res)
    res = copy(res) # to avoid changing the passed in res to print the older values 
    n,m = size(A)
    rows = getRow(A)
    used = zeros(Int,n)
    for i in eachindex(res)
        if res[i]!=0
            for x in rows[i]
                used[x]+=1 #using +1 instead of =1 to keep in mind if its covered by more than one element 
            end
        end
    end
    k = 1
    while k <= 4 
        found = false
        if(k==1)
            for i in 1:m
                if(fits(used,rows,i) && res[i]==0) # element with no contraint will always be added even if its already in 
                    found = true 
                    addSolution(used,res,i,rows)
                    break
                end
            end
            if found 
                k=1
            
            else
            k+=1
            end

        elseif(k==2)
            resx , z0 , edited = descentSimple(A,C,res)
            if(edited) # the already built function does take one add one and added a bool as a third return to track the k 
                found = true
                res = resx 
                used = zeros(Int,n) # have to do it cuz decent simple does not use add and remove so used doesnt get updated neither does res 
                for q in eachindex(resx)
                    if resx[q]!= 0
                        for p in rows[q]
                            used[p]+=1
                        end
                    end
                end
            end
            if found 
                k=1
            
            else
            k+=1
            end
        

        elseif(k==3) # take 2 add one 
            chosen = findall(x->x!=0,res)
            toTest = findall(x-> x==0,res)
            for i in chosen
                for j in chosen 
                    if(i==j) 
                        break
                    end
                    for y in toTest
                        if(C[i]+C[j]< C[y])
                            removeSolution(used,res,i,rows)
                            removeSolution(used,res,j,rows) # we remove them just to test 
                            if(fits(used,rows,y))
                                addSolution(used,res,y,rows)
                                found = true
                                break 
                            else
                                addSolution(used,res,i,rows)
                                addSolution(used,res,j,rows)
                            end

                        end 
                    end
                    if found break end 
                end
                if found break end 
            
            end
            if found 
                k=1
            
            else
            k+=1
            end
            
        elseif k==4 # same logic as 3 just flip it 
            chosen = findall(x->x!=0,res)
            toTest = findall(x-> x==0,res)
            for i in chosen
                for j in toTest 
                    for y in toTest
                        if(j==y) 
                        break
                        end
                        if(C[i]<C[j]+ C[y])
                            removeSolution(used,res,i,rows)
                            if(fits(used,rows,j))
                                addSolution(used,res,j,rows)
                                if(fits(used,rows,y))
                                    found = true
                                    addSolution(used,res,y,rows)
                                    break
                                else
                                    removeSolution(used,res,j,rows) 
                                    addSolution(used,res,i,rows) # in case we entered the second if 
                                end
                            else
                                addSolution(used,res,i,rows)
                            end

                        end 
                    end
                    if found break end 
                end
                if found break end 
            
            end
            if found 
                k=1
            
            else
            k+=1
            end

        end
    
    
    end 
    return res , dot(C,res)

end 



function graspVnd(A,C,alpha,budget) # 60sec
    n,m = size(A)
    bestRes = zeros(Int,m)
    bestZ = 0
    t0 = time()
    while time()- t0 < budget 
        res , z = graspRatio(A,C,alpha)
        res , z = vnd(A,C,res)
        if(z>bestZ)
            bestZ = z 
            bestRes = res
        end
    end
    return bestRes , bestZ
end




#trying path relinking 
#idea : Path relinking walks from a start solution to a target solution. First, collect the variables that are in the target but not in the start (toAdd). Then remove from the start every variable that conflicts with one of them. Next, add the variables of toAdd one at a time, computing the solution value after each addition and saving the best solution seen (bestZ). Once every variable of toAdd has been added, the path has reached the target, and the best solution found along the way is returned. The target is feasible and all conflicting variables were removed, so every intermediate solution stays feasible.


function path_Relinking(A,C,start,target)
    current = copy(start)
    rows = getRow(A)
    n,m = size(A)
    used = zeros(Int,n)
    for i in eachindex(start) 
        if(start[i] == 1)
            for q in rows[i]
            used[q]+=1 
            end
        end
    end

    best = copy(current)
    bestZ = dot(best,C)

    toAdd = [i for i in eachindex(current) if target[i] == 1 && current[i] == 0] #exists in the target but not in the start
    for i in toAdd
        for j in findall(==(1) , current) # only the indexes that are 1 used ones 
            if(!isempty(intersect(rows[i],rows[j]))) #remove all the constraints until i can add the i
                removeSolution(used,current,j,rows)
            end
        end
        addSolution(used,current,i,rows)

        #checking if we have open space after we removed some solution 
        for k in 1:m
            if(fits(used,rows,k))
                addSolution(used,current,k,rows)
            end
        end

        #computing the new Z to compare 
        newZ = dot(current,C)
        if(newZ>bestZ)
            bestZ = newZ 
            best = copy(current)
        end
    end
    return best,bestZ
end



function createPool(A,C,alpha,budget = 60)
    pool = Dict{Vector{Int},Int}()
    t0 = time()
    while time()- t0 < budget 
        res , z = graspRatio(A,C,alpha)

        if(!isempty(pool))
            target = rand(collect(keys(pool))) # get a random res from pool
            if(res!= target)
                if(z > pool[target])
                    s,t = res , target #start should be the better one 
                else 
                   s,t = target ,res 
                end
                resLink , zLink = path_Relinking(A,C,s,t)
                if(zLink > z )
                    res , z = resLink,zLink
                end
            end
        end

        if(haskey(pool,res)) # just skip do nothing
        elseif(length(pool)<5) #check if the pool is still not full 
            pool[copy(res)] = z
        elseif(minimum(values(pool))<z) # new z is still bigger than the smallest z in the pool so we keep only the best results 
            delete!(pool, argmin(pool)) # delete the element with min z 
            pool[copy(res)] = z
        end
    end
    return argmax(pool) , maximum(values(pool))

end

