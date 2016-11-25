function Costs = NormAntCosts( Ant, BestAnt )

    Ant = [BestAnt;Ant];
        
    Costs=[];

    for i=1:length(Ant)
       
        Costs = [Costs; Ant(i).ConsEnergy];
        
    end
    
    Costs = 1./Costs;
    
    normData = max(Costs) - min(Costs);               % this is a vector
    
    normData = repmat(normData, [length(Costs) 1]);    % this makes it a matrix
    
    minmatrix= repmat(min(Costs), [length(Costs) 1]); % of the same size as A
                                                         
    Costs = (Costs-minmatrix)./normData;         % your normalized matrix

 
end

