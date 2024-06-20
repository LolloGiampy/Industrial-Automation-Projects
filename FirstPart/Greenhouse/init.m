clear;
clc;

%% Point 1)
%Horizon 24h in seconds
H = 24 * 60 * 60; % [s]

%thermal transmittence by a single glazing
t_t = 5.7; %[W/(m^2⋅K)]
%Area of the walls of module 1 heating from external temperature
Sm1_ext = (50 + 50 + 10)*3 + 50 * 10; %[m^2]
%Area of the wall in common
Sm_int = 10 * 3; %[m2]
%Area of the walls of module 2 heating from external temperature
Sm2_ext = (10 + 10 + 10)*4 + 10 * 10 + 10; %[m2]

%air thermal capacity
c_f = 1005;% [J/(Kg*K)]
%mass forumla = density * volume
%mass of the air in module 1   
m_f1 = 1225 * (50*10*3); %[Kg]
%and module 2
m_f2 = 1225 * (10*10*4);
%average thermal cap  ir in the greenhouse modules,
%1 and 2 respectively
C_f1 = c_f * m_f1;
C_f2 = c_f * m_f2; %[J/K]
%Overall thermal transmittence between the air and 
%the external environment
kaf1 = t_t * Sm1_ext;
kaf2 = t_t * Sm2_ext; %[W/K]
%Overall thermal transmittence between the air inside the two modules
kaf_int = t_t * Sm_int;

% Additive first module "air" noise variance
var_wf1 = 1;

% Additive second module "air" noise variance
var_wf2 = 1;

%load the extracted data
load('ExtractedData.mat');

% 'Fromworkspace' block in Simulink needs timeseries 
%The '.*' operator is used to multiply each entry of the vector by 60*60
%(indeed it's given in hours, but SI time unit is second s). Transpose
%since we want a row vector, while it's a column vector.
timeseriesextK = timeseries(extK', time.*(60*60)');
timeseriestrack_m1K = timeseries(track_m1K', time.*(60*60)');
timeseriesradiation = timeseries(radiation'*0.95, time.*(60*60)');
timeseriestrack_m2K = timeseries(track_m2K', time.*(60*60)');


% Initial theta_a
theta0_a = 291;

% Sample time
Ts = 2;%[s]

%% Point 3a)
q_star_m1 = 25000*4; %[W]
q_star_m2 = 15000*4; %[W]

%% Point 3b)
qMAX_m1 = 25000*4;
qmin_m1 = -25000*4;
qMAX_m2 = 15000*4;  
qmin_m2 = -15000*4;

%% Point 4)
% set visualization format
format long g;

% model name
model_relay = 'Greenhouse_4thPoint_Relay'; 
model_pid = 'Greenhouse_4thPoint_PID';

% 24 hours simulation time
simTime = 24*60*60; 

% run the simulation
simOutRelay = sim(model_relay, 'StopTime', num2str(simTime));
simOutPID = sim(model_pid, 'StopTime', num2str(simTime));

% acquire simulation data output
eTempM1Relay = simOutRelay.get('eTempM1Relay');
eTempM2Relay = simOutRelay.get('eTempM2Relay');
eTempM1PID = simOutPID.get('eTempM1PID');
eTempM2PID = simOutPID.get('eTempM2PID');
qM1Relay = simOutRelay.get('qM1Relay');
qM2Relay = simOutRelay.get('qM2Relay');
qM1PID = simOutPID.get('qM1PID');
qM2PID = simOutPID.get('qM2PID');

% extract arrays from timeseries
eTempM1Relay_values = eTempM1Relay.Data;
eTempM2Relay_values = eTempM2Relay.Data;
eTempM1PID_values = eTempM1PID.Data;
eTempM2PID_values = eTempM2PID.Data;
qM1Relay_values = qM1Relay.Data;
qM2Relay_values = qM2Relay.Data;
qM1PID_values = qM1PID.Data;
qM2PID_values = qM2PID.Data;

% compute mse
mseM1Relay = mse(eTempM1Relay_values);
mseM2Relay = mse(eTempM2Relay_values);
mseM1PID = mse(eTempM1PID_values);
mseM2PID = mse(eTempM2PID_values);

fprintf('MSE module 1 relay: %f \n', mseM1Relay);
fprintf('MSE module 2 relay: %f \n', mseM2Relay);
fprintf('MSE module 1 PID: %f \n', mseM1PID);
fprintf('MSE module 2 PID: %f \n', mseM2PID);

% mse graph plotting
mse_values = [mseM1Relay, mseM2Relay, mseM1PID, mseM2PID];
mse_categories = {'M1 Relay', 'M2 Relay', 'M1 PID', 'M2 PID'};

figure;
bar(mse_values);
set(gca, 'XTickLabel', mse_categories);
xlabel('Modules and controls');
ylabel('Mean Square Error (MSE)');
title('Mean Square Error (MSE) for Different Modules and controls');

% compute energy consumption
energyM1Relay = EnergyConsumption(qM1Relay_values);
energyM2Relay = EnergyConsumption(qM2Relay_values);
energyM1PID = EnergyConsumption(qM1PID_values);
energyM2PID = EnergyConsumption(qM2PID_values);

totalEnergyRelay = (energyM1Relay*24) + (energyM2Relay*24);
totalEnergyPID = (energyM1PID*24) + (energyM2PID*24);

% average hour consumption graph plotting
energy_values = [energyM1Relay, energyM2Relay, energyM1PID, energyM2PID]/1000;
energy_categories = {'M1 Relay', 'M2 Relay', 'M1 PID', 'M2 PID'};

figure;
bar(energy_values);
set(gca, 'XTickLabel', energy_categories);
xlabel('Modules and controls');
ylabel('KW/h energy consumption');
title('KW/h energy consumption for Different Modules and Methods');

% average daily total energy consumption with relay and PID
total_energy_values = [totalEnergyRelay, totalEnergyPID]/1000000;
total_energy_categories = {'Relay', 'PID'};

figure;
bar(total_energy_values);
set(gca, 'XTickLabel', total_energy_categories);
xlabel('Modules and controls');
ylabel('Daily energy consumption GW');
title('Daily energy consumption in GW for Different Modules and Methods');

fprintf('Average energy module 1 relay: %f W/h\n', energyM1Relay);
fprintf('Average energy module 2 relay: %f W/h\n', energyM2Relay);
fprintf('Average energy module 1 PID: %f W/h\n', energyM1PID);
fprintf('Average energy module 2 PID: %f W/h\n', energyM2PID);
fprintf('Average daily total energy relay: %f W\n', totalEnergyRelay);
fprintf('Average daily total energy relay: %f W\n', totalEnergyPID);

