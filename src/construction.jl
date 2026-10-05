# construction.jl

function construction(C, A)                        
    m,n =size(A)    # rows x cols                              
    x=zeros(Int, n)    # an array of zeros                           
    ligneUtilisee= zeros(Int, m)    # 0 for not used 1 for used               
 
    note =zeros(n)    # cost                             
    for j = 1:n                                    
        poids =sum(A[:, j]) # since its binary it returns how many times it appears or how many lines are covered 
        if poids>0
            note[j]= C[j]/poids # cost/lines covered
        else
            note[j]=0.0              
        end
    end
 
    ordre=sortperm(note,rev=true)     #order them by index for the first example it will be [6,7,1,4...]         
 
    for j in ordre #[6,7...]                             
        compatible= true                          
        for i = 1:m                              
            if A[i, j]==1 && ligneUtilisee[i]==1   #get the line that is covered by J then check if it was already covered by a previous pick 
                compatible =false
                break                
            end
        end
        if compatible                              
            x[j] = 1  #updating results                              
            for i = 1:m                            
                if A[i, j] == 1                    
                    ligneUtilisee[i] = 1   #updating the covered lines         
                end
            end
        end
    end
 
    z = sum(C[j] * x[j] for j = 1:n)  # returning the dot product z0 dot(C,x)            
    return x, z                                    
end
 
C, A = loadSPP("Data/pb_500rnd0100.dat")                     
x, z = construction(C, A)                          
println("x = ", x)                                 
println("z = ", z)