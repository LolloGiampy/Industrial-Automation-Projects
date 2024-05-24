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
%average thermal capacity of the mass of the air in the greenhouse modules,
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
Ts = 1;%[s]

%% Point 3a)
q_star_m1 = 25000*4; %[W]
q_star_m2 = 15000*4; %[W]

%% Point 3b)
qMAX_m1 = 25000*4;
qmin_m1 = -25000*4;
qMAX_m2 = 15000*4;  
qmin_m2 = -15000*4;