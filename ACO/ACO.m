%% Start of Program
clc;
clear;
close all;

%% Problem Definition

xArea = 100;             % Length and width of world

Area = xArea *xArea;     % Area of the world

T = 10;                  % Number of Time Periods

% a Struct for Network Properties

Network.nSensors = 100;
Network.Idle = 50;          % Idle State Energy Consumption
Network.PacketSize = 400;    % PacketSize
Network.BSPosition = [0 0]; % Position of BS
Network.InitialEnergySen =500000000;  % Initial energy of each sensor

nVar = Network.nSensors;
% How Many packets did exchange in each period in the Network?
load nPackets;
Network.nPackets = nPackets;

% Create a variable which it has iformation about the position of all nodes
% in the network
load Positions;

%% ACO Parameters

MaxIt=20;               % Maximum Number of Iterations

nAnt=50;              % Number of Ants (Population Size)

Q=1;

q0=0.7;             % Exploitation/Exploration Decition Factor

tau0=1;             % Initial Phromone

alpha=0.7;          % Phromone Exponential Weight
beta=0.3;           % Heuristic Exponential Weight

rho=0.7;           % Evaporation Rate

%% Initialization

eta=ones(Network.nSensors,2);               % Heuristic Information Matrix

tau=tau0*ones(Network.nSensors, 2);         % Phromone Matrix

BestCost=zeros(MaxIt,1);       % Array to Hold Best Cost Values

% Empty Ant
empty_ant.Status=[];
empty_ant.ConsEnergy=[];

% Ant Colony Matrix
ant=repmat(empty_ant,nAnt,1);

% Best Ant
BestAnt.ConsEnergy=-inf;

t=cputime;

%% ACO Main Loop
tic
for i=1:MaxIt
    %Move Ants
    for k=1:nAnt
        flag = false;
        while (~flag)
            for n=1:nVar

               q= rand;

                if(q<=q0)

                    [~, idx] = max((tau(n,:)).^alpha.*(eta(n,:)).^beta);

                else

                    P = (((tau(n,:)).^alpha.*(eta(n,:)).^beta)./sum((tau(n,:)).^alpha.*(eta(n,:)).^beta));

                    P = P/sum(P);

                    P = P';

                    idx = RouletteWheelSelection(P);

                end

                ant(k).Status(n) = idx;

            end
            if (length(find(ant(k).Status==2)))>2
                flag=true;
            end
        end
        %ant(k).Status = 1-ant(k).Status;
        
        [ant(k).ConsEnergy] = ObjectiveFunction(ant(k), Network , Positions, T);
        
    end
    
    
    [~, SortOrder]=sort([ant.ConsEnergy], 'descend');
    ant=ant(SortOrder);
    
    if ant(1).ConsEnergy > BestAnt.ConsEnergy
        BestAnt = ant(1);
    end
	

    update.Costs = NormAntCosts(ant, BestAnt);
    
    update.Ants = [BestAnt; ant ];
    
    % update best path
    for j=1:nVar    
                
        tau(j, update.Ants(1).Status(j))= tau(j, update.Ants(1).Status(j))+ rho*(update.Ants(1).ConsEnergy);
                
    end
    
    % update other paths
    for k=2:20
        
        for j=1:nVar    
                
                tau(j, update.Ants(k).Status(j))= tau(j, update.Ants(k).Status(j))+ update.Ants(k).ConsEnergy;
                
        end
        
    end
     
    % Evaporation
    tau=(1-rho)*tau;
    
    % Store Best Cost
    BestCost(i)=BestAnt.ConsEnergy;
    
    % Show Iteration Information
    disp(['Iteration ' num2str(i) ': Best Cost = ' num2str(BestCost(i))]);
    
        
end

[~, Network] = ObjectiveFunction (BestAnt,Network, Positions, T);
sensors = Network.OtherSensors;

%% Results

cpuTime = cputime-t;

disp(['Cpu Time for ' num2str(MaxIt) ' is : ' num2str(cpuTime)]);
disp(['Network lasts for ' num2str(floor(Network.InitialEnergySen/abs(BestAnt.ConsEnergy))) ' periods ']);
figure;
plot (BestCost, 'LineWidth', 2);
xlabel ('Iteration');
ylabel ('Best ConsEnergy');
