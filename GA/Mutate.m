function y=Mutate(x,mu)

    
    
    nVar=numel(x);
    
    nmu=ceil(mu*nVar);
    
    
    feasible = false;
    
    while (~feasible)
        j = randi(length(x),1,nmu);
    
        y=x;
        y(j)= randi([0,1],1, nmu);
        
        feasible = Feasible(y);

    end
        

   
end