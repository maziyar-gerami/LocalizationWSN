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

% How Many packets did exchange in each period in the Network?
load nPackets;
Network.nPackets = nPackets;


% Create a variable which it has iformation about the position of all nodes
% in the network
load Positions;
%% kmeans
k = 10;

H = randi(Network.nSensors, 1,k);

sol = zeros (1,Network.nSensors);

sol(H) =1;

ConsEnergy=ObjectiveFunction(sol, Network , Positions, T)

disp(['Network lasts for ' num2str(floor(Network.InitialEnergySen/abs(ConsEnergy))) ' periods ']);
figure;



