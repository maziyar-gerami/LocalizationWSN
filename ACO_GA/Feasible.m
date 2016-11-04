function feasible = Feasible( Status )
%FEASIBLE Summary of this function goes here
%   Detailed explanation goes here

feasible = false;

if length(find(Status))>1
    
    feasible = true;
    
end

