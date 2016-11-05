function [ConsEnergy, Network] = ObjectiveFunction (pop,Network, Positions, T)
    K=1;
    E_Star = 2.7;
    sensorsStatus = pop.Status;

    CH = find(sensorsStatus);                   % Head Clusters

    otherSensors = find(sensorsStatus==0);           % Other Sensors  


    Distance = zeros(length(otherSensors), length(CH));

    for i=1: length(otherSensors)

        for j=1:length(CH)

            Distance(i,j) = pdist2((Positions(otherSensors(1,i),:)), (Positions(CH(j),:)));

        end

        [~, I] = min(Distance(i,:));
        otherSensors(2,i) = CH(I);
    end
    
    Network.CH = CH;
    Network.OtherSensors = otherSensors;

    % the energy expenditure of a cluster
    % Energy  used by the head node to transmit aggregated messages to the BS
    ET_S=@(s,t) Network.Idle + Network.PacketSize...
        *sum(Network.nPackets(t,find(otherSensors(2,:)==s)))*...
        pdist2(Positions(s,:), Network.BSPosition)^4;
    % Energy  used by a Sensor to CH
    ET_I=@(I,t) Network.Idle + Network.PacketSize*Network.nPackets(t,I)*...
        pdist2(Positions(otherSensors(1,I),:), Positions(otherSensors(2,I),:))^2;

    ER=@(I,t) Network.Idle + Network.PacketSize*E_Star;
    
    % sum of Distances from CHs to BS
    
    for i=1:length(CH)
       
        sumDistance = pdist2(Positions(CH(i),:), Network.BSPosition);
        
    end
    

    E= computeE(CH,otherSensors,T,K, ET_I, ER, ET_S);
    
    E_Hat = computeE_Hat(Network, sensorsStatus,T,ET_S );
    
    E_prime = computeE_Prime(Network, Positions, otherSensors,T);
    
    ConsEnergy = E_Hat/(length(sensorsStatus)*Network.InitialEnergySen)+E_prime/sum(E)+1/sumDistance;

end

%% Compute E_prime
% E_Prime
function E_prime = computeE_Prime(Network,Positions, otherSensors,T)

    E_prime =0;
    
    for i=1:length(otherSensors)
        
        for t=1:T
            
            E_prime = E_prime + Network.Idle + ...
                Network.nPackets(t,i)*Network.PacketSize*...
                pdist2(Positions(otherSensors(1,i),:), Network.BSPosition);
            
        end
        
    end

end 


%% Compute E
function E = computeE(CH,otherSensors,t,k,ET_I, ER, ET_S)

    E = zeros(1,length(CH));
    
    for i=1:length(CH)

        temp=0;

       sensorsInC = find(otherSensors(2,:)==CH(i));

       for j=1:length(sensorsInC)

          temp = temp + ET_I(sensorsInC(j),t);

       end

        E(i) = temp + k*ER(CH(i),t) + ET_S(CH(i),t);
    end

end 

%% ComputeE_Hat
function E_Hat =  computeE_Hat(Network, sensorsStatus,T, ET_S )
    temp =0;

    for i=1:length(sensorsStatus)


       for t=1:T

          temp = temp+ ET_S(i, t);

       end

        E_Hat = Network.InitialEnergySen - temp;
    end

end

