using LinearAlgebra
include("construction.jl")


function getRow(A) #returns the rows covered by each element ex :x[1]=[1,7] 1 covers rows 1 and 7
    n,m = size(A)
    list = []
    for j in 1:m
        l=[]
        for i in 1:n
            if(A[i,j]==1)
                push!(l,i)
            end
        end
        push!(list,l)
    end
    return list #list of lists 
end

function descenteSimple(C,A)
    x,z= constructionRatio(C,A)
    m,n = size(A)
    rows = getRow(A)

    for j in 1:n #[6,7...]
        if(x[j]==1) #6 works with 4
            for i in 1:n # works with 1 when we take j = 4 
                if(i!=j && C[i]>C[j]&& x[i]==0)
                    conflict = false 
                    for k in eachindex(rows)
                        if(x[k]==1 && k!=j && !isempty(intersect(rows[i],rows[k]))) #check for every chosen number and avoid the one we picked cuz even if theres a conflict it will be replaced by the new value 
                            conflict = true 
                            break
                        end
                    end
                    if(!conflict)
                        x[i]=1
                        x[j]=0
                        break # stop the loop if we replace j with the highest cost 
                    end
                end
            end
        end
        
    end 
    return x,dot(C,x)

end


function deepDescent(C,A)
    x,z= constructionRatio(C,A)
    m,n = size(A)
    rows = getRow(A)
    better = true 

    while(better)
        better = false 
        for j in 1:n #[6,7...]
            if(x[j]==1) #6 works with 4
                for i in 1:n # works with 1 when we take j = 4 
                    if(i!=j && C[i]>C[j]&& x[i]==0) # avoiding replacing by the same checking if the cost is higher than the already chosen one and checking if it isnt already chosen 
                        conflict = false 
                        for k in eachindex(rows)
                            if(x[k]==1 && k!=j && !isempty(intersect(rows[i],rows[k]))) #check for every chosen number and avoid the one we picked cuz even if theres a conflict it will be replaced by the new value 
                                conflict = true 
                                break
                            end
                        end
                        if(!conflict)
                            x[i]=1
                            x[j]=0
                            better = true 
                            break # stop the loop if we replace j with the highest cost 
                        end
                    end
                end
            end
            
        end
    end 
    return x,dot(C,x)

end