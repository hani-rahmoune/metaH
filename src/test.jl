A = [
    1 1 1 0 1 0 1 1 0   # element 1
    0 1 1 0 0 0 0 1 0   # element 2
    0 0 0 0 1 1 0 1 1   # element 3
    0 0 0 1 0 0 0 0 0   # element 4
    1 0 1 0 1 1 0 0 1   # element 5
    0 1 1 0 0 0 1 0 1   # element 6
    1 0 0 1 1 0 0 1 1   # element 7
]
n, m = size(A)
#=
println(n)
println(m)
println(A[:,1])
println(findall(!iszero,A[:,1])) =# 

function getRow(A)
    n,m = size(A)
    return [findall(!iszero,A[:,j]) for j in 1:m]
end

#= x = getRow(A)
println(x) =#

function constructGreedy(A,C,key) 
    n,m =size(A)
    rows = getRow(A)
    sature = falses(m) # array of num of lines all false to check if the it was already covered 
    result = zeros(Int,m)
    ordered  = sortperm(key , rev = true ) # sort key desc

    for j in ordered #[6,7,1...]
        compatible = true
        for i in rows[j] # [3,5]
            if sature[i] 
                compatible = false 
                break 
            end
        end 
        if compatible
            result[j]= 1
            for i in rows[j]
                sature[i]= true 
            end
        end
    end
    return result
end 
C = [10, 5, 8, 6, 9, 13, 11, 4, 6]

function GreedyOnlyCost(A,C)
    return constructGreedy(A,C,C)
end 

function GreedyRatio(A,C)
    n,m = size(A)
    rows = getRow(A)
    covers = [length(rows[j]) for j in 1:m]
    ratio = [C[j]/covers[j] for j in 1:m]
    return constructGreedy(A,C,ratio)
end 

res = GreedyRatio(A,C)
println(res)