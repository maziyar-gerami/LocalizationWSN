%% Start of Program
clc;
clear;
close all;

%% Problem Definition

xArea = 100;             % Length and width of world

Area = xArea *xArea;     % Area of the world

T = 10;                  % Number of Time Periods

% a Struct for Network Properties

Network.nSensors = 50;
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

MaxItACO=10;               % Maximum Number of Iterations

nAnt=50;              % Number of Ants (Population Size)

Q=1;

q0=0.7;             % Exploitation/Exploration Decition Factor

tau0=1;             % Initial Phromone

alpha=0.7;          % Phromone Exponential Weight
beta=0.3;           % Heuristic Exponential Weight

rho=0.7;           % Evaporation Rate

%% GA Parameters

MaxItGA=10;      % Maximum Number of Iterations

nPop=50;        % Population Size

pc=0.8;                 % Crossover Percentage
nc=2*round(pc*nPop/2);  % Number of Offsprings (Parnets)

pm=0.4;                 % Mutation Percentage
nm=round(pm*nPop);      % Number of Mutants

mu=0.2;         % Mutation Rate

%% Initialization

eta=ones(Network.nSensors,2);               % Heuristic Information Matrix

tau=tau0*ones(Network.nSensors, 2);         % Phromone Matrix

BestCost=zeros(MaxItACO+MaxItGA,1);       % Array to Hold Best Cost Values

% Empty Ant
empty_ant.Status=[];
empty_ant.ConsEnergy=[];

% Ant Colony Matrix
ant=repmat(empty_ant,nAnt,1);

% Best Ant
BestAnt.ConsEnergy=-inf;

t =cputime;
%% ACO Main Loop

for i=1:MaxItACO
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
        
        [ant(k).ConsEnergy] = ObjectiveFunctionACO(ant(k), Network , Positions, T);
        
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

%GA


%% Initialization

empty_individual.Status=[];
empty_individual.ConsEnergy=[];

pop=repmat(empty_individual,nPop,1);

% Create first population
for i=1:nPop
    
    pop(i).Status = ant(i).Status-1;
    pop(i).ConsEnergy = ant(i).ConsEnergy;
    
end


% Best Solution Ever Found
BestSol=pop(1);
%% Main Loop

for it=MaxItACO+1:MaxItACO+MaxItGA
    
    
    P=[pop.ConsEnergy]/sum([pop.ConsEnergy]);
    
    % Crossover
    popc=repmat(empty_individual,nc/2,2);
    for k=1:nc/2
        flag = false;
        while(~flag)
        
            %  Select Parents Indices
            i1=RouletteWheelSelection(P);
            i2=RouletteWheelSelection(P);

            % Select Parents
            p1=pop(i1);
            p2=pop(i2);

            % Apply Crossover
            [popc(k,1).Status, popc(k,2).Status]=Crossover(p1.Status,p2.Status);
            
            if (length(find(popc(k,1).Status==1)))>2 && (length(find(popc(k,2).Status==1)))>2
                    flag=true;
            end
        
        end

            % Evaluate Offsprings
            popc(k,1).ConsEnergy = ObjectiveFunctionGA(popc(k,1), Network , Positions, T);
            popc(k,2).ConsEnergy = ObjectiveFunctionGA(popc(k,2), Network , Positions, T);

            
        
    end
    popc=popc(:);
    
    % Mutation
    popm=repmat(empty_individual,nm,1);
    for k=1:nm
        
        % Select Parent
        i=randi([1 nPop]);
        p=pop(i);
        
        % Apply Mutation    
        popm(k).Status=Mutate(p.Status,mu);
        
        % Evaluate Mutant
        popm(k).ConsEnergy=ObjectiveFunctionGA(popm(k), Network , Positions, T);
        
    end
    
    % Create Merged Population
    pop=[pop
         popc
         popm];
    
    % Sort Population
    [~, SortOrder]=sort([pop.ConsEnergy], 'descend');
    pop=pop(SortOrder);
    
    
    % Truncation
    pop=pop(1:nPop);
    
    % Store Best Solution Ever Found
    BestSol=pop(1);
    
    % Store Best ConsEnergy Ever Found
    BestCost(it)=BestSol.ConsEnergy;
    
    % Show Iteration Information
    disp(['Iteration ' num2str(it) ': Best ConsEnergy = ' num2str(BestCost(it))]);
    
    
end
[~, Network] = ObjectiveFunctionGA (BestSol,Network, Positions, T);
sensors = Network.OtherSensors;

cpuTime = cputime-t;

disp(['Cpu Time for ' num2str(it) ' is : ' num2str(cpuTime)]);

disp(['Network lasts for ' num2str(floor(Network.InitialEnergySen/abs(BestSol.ConsEnergy))) ' periods ']);
figure;
plot (BestCost, 'LineWidth', 2);
xlabel ('Iteration');
ylabel ('Best ConsEnergy');
