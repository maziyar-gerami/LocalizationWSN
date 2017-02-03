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

% How Many packets did exchange in each period in the Network?

load nPackets;
Network.nPackets = nPackets;


% Create a variable which it has iformation about the position of all nodes
% in the network
load Positions;
%% GA Parameters
nVar=3;
MaxIt=50;      % Maximum Number of Iterations

nPop=50;        % Population Size

pc=0.8;                 % Crossover Percentage
nc=2*round(pc*nPop/2);  % Number of Offsprings (Parnets)

pm=0.2;                 % Mutation Percentage
nm=round(pm*nPop);      % Number of Mutants

mu=0.02;         % Mutation Rate

%% Initialization

empty_individual.Status=[];
empty_individual.ConsEnergy=[];

pop=repmat(empty_individual,nPop,1);

% Create first population
for i=1:nPop
    
    pop(i).Status = randi([1,Network.nSensors],1, nVar);
    pop(i).ConsEnergy = ObjectiveFunction(pop(i).Status, Network , Positions, T);
    
end

% Sort Population
[~, SortOrder]=sort([pop.ConsEnergy], 'descend');
pop=pop(SortOrder);

% Best Solution Ever Found
BestSol=pop(1);

% Array to Hold Best ConsEnergy
BestConsEnergy=zeros(MaxIt,1);

t=cputime;

%% Main Loop

for it=1:MaxIt
    
    
    P=[pop.ConsEnergy]/sum([pop.ConsEnergy]);
    
    % Crossover
    popc=repmat(empty_individual,nc/2,2);
    for k=1:nc/2
        
        %  Select Parents Indices
        i1=RouletteWheelSelection(P);
        i2=RouletteWheelSelection(P);

        % Select Parents
        p1=pop(i1);
        p2=pop(i2);
        
        % Apply Crossover
        [popc(k,1).Status, popc(k,2).Status]=Crossover(p1.Status,p2.Status);
            
        % Evaluate Offsprings
        popc(k,1).ConsEnergy = ObjectiveFunction(popc(k,1).Status, Network , Positions, T);
        popc(k,2).ConsEnergy = ObjectiveFunction(popc(k,2).Status, Network , Positions, T);
        
        
    end
    popc=popc(:);
    
    % Mutation
    popm=repmat(empty_individual,nm,1);
    for k=1:nm
        
        % Select Parent
        i=randi([1 nPop]);
        p=pop(i);
        
        % Apply Mutation    
        popm(k).Status=Mutate(p.Status,mu, nVar);
        
        % Evaluate Mutant
        popm(k).ConsEnergy=ObjectiveFunction(popm(k).Status, Network , Positions, T);
        
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
    BestConsEnergy(it)=BestSol.ConsEnergy;
    
    % Show Iteration Information
    disp(['Iteration ' num2str(it) ': Best ConsEnergy = ' num2str(BestConsEnergy(it))]);
    
    
end
[~, Network] = ObjectiveFunction (BestSol.Status,Network, Positions, T);
sensors = Network.OtherSensors;

cpuTime = cputime-t;

BestSol.ConsEnergy
disp(['Cpu Time for ' num2str(MaxIt) ' is : ' num2str(cpuTime)]);
disp(['Network lasts for ' num2str(floor(Network.InitialEnergySen/abs(BestSol.ConsEnergy))) ' periods ']);
figure;
plot (BestConsEnergy, 'LineWidth', 2);
xlabel ('Iteration');
ylabel ('Best ConsEnergy');
