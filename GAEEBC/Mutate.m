function y=Mutate(x,mu, nVar)

    
   
    
    nmu=ceil(mu*nVar);
    
    
    feasible = false;
    
    while (~feasible)
        j = randi(nVar,1,nmu);
    
        y=x;
        y(j)= randi([1,100],1, nmu);
        
        feasible = Feasible(y);

    end
        

   
end