function [ nPackets ] = createPackets( T, nSensors )
rng(1);

for t=1:T
    
    for i=1:nSensors

        nPackets(t,i) = randi(20);

    end
end


end

