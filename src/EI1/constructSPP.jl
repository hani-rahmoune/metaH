#Ex 1 Q1
function getRow(A) #takes the A matrix as an arg and return an array of arrays x where x[1] is the list of lines covered by 1 and so on 
    m, n = size(A) # lines cols 
    return [findall(!iszero, A[:, j]) for j in 1:n] #find all returns the index of the non zero values in the said vect 
end

function constructGreedy(A,C,key) # takes matrix cost array and cost only or no arg type array 
    n,m =size(A)
    rows = getRow(A) # array of arrays rows[1] index of lines coverd by 1
    sature = falses(n) # array of num of lines all false to check if the it was already covered 
    result = zeros(Int,m) # the return [0,0]
    ordered  = sortperm(key , rev = true ) # sort key desc highest cost and return the indexes of them [13,11,10,..] return [6,7,1,..]

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
    return result , dot(C,result) # [0,0,0,1,0,1,1,0,0], Z0 dot product 
end 

# case 1 we only take cost into consideration 
function greedyOnlyCost(A,C)
    return constructGreedy(A,C,C) #only cost matters 
end 
# case 2 cost and number of lines covered 
function greedyRatio(A,C)
    n,m = size(A)
    rows = getRow(A)
    covers = [length(rows[j]) for j in 1:m] # get how many are covered for each j 
    ratio = [C[j]/covers[j] for j in 1:m] #[3,333,....]
    return constructGreedy(A,C,ratio)
end