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
% model name
model_relay = 'Greenhouse_4thPoint_Relay'; 
model_pid = 'Greenhouse_4thPoint_PID';
% 24 hours simulation time
simTime = 24*60*60; 
% run the simulation
simOutRelay = sim(model_relay, 'StopTime', num2str(simTime));
simOutPID = sim(model_pid, 'StopTime', num2str(simTime));
% acquire simulation data output
desiredTempM1 = simOutRelay.get('desiredTempM1');
measuredTempRelayM1 = simOutRelay.get('measuredTempRelayM1');
desiredTempM2 = simOutRelay.get('desiredTempM2');
measuredTempRelayM2 = simOutRelay.get('measuredTempRelayM2');
measuredTempPIDM1 = simOutPID.get('measuredTempPIDM1');
measuredTempPIDM2 = simOutPID.get('measuredTempPIDM2');
powerM1Relay = simOutRelay.get('powerM1Relay');
powerM2Relay = simOutRelay.get('powerM2Relay');


% extract 
desiredTempM1_values = desiredTempM1.Data;
desiredTempM2_values = desiredTempM2.Data;
measuredTempRelayM1_values = measuredTempRelayM1.Data;
measuredTempRelayM2_values = measuredTempRelayM2.Data;
measuredTempPIDM1_values = measuredTempPIDM1.Data;
measuredTempPIDM2_values = measuredTempPIDM2.Data;
powerM1Relay_values = powerM1Relay.Data;
powerM2Relay_values = powerM2Relay.Data;

%for i = 1:length(desiredTempM1_values)
%    fprintf('Temperature: %.2f \n', desiredTempM1_values(i));
%end

% compute mean square error
mseM1_relay = mse(desiredTempM1_values, measuredTempRelayM1_values);
mseM2_relay = mse(desiredTempM2_values, measuredTempRelayM2_values);
mseM1_PID = mse(desiredTempM1_values, measuredTempPIDM1_values);
mseM2_PID = mse(desiredTempM2_values, measuredTempPIDM2_values);

fprintf('MSE of Module 1 using relay: %2f \n', mseM1_relay);
fprintf('MSE of Module 2 using relay: %2f \n', mseM2_relay);
fprintf('MSE of Module 1 using PID: %2f \n', mseM1_PID);
fprintf('MSE of Module 2 using PID: %2f \n', mseM2_PID);

energyM1 = trapz(time_values, heatingPowerM1_values);