% To remove all from the Workspace
clear; 
% To remove all from the Command Window
clc;
% Now we can start...
%==========================================
%% Point 1)
% Horizon 24 h = 24*60 min = 24*60*60 s
H = 24 * 60 * 60;% [s]

% Heating/cooling power range  
q_MAX = 1000;% [W]
q_min = -1000;% [W]

% mass of the cheese 
m_c = 1.3;% [Kg]
c_c = 2150;% [J/(Kg*K)] 
% Average thermal capacity of the mass of the cheese
C_c = c_c*m_c;% [J/K]

% mass of the air in the box
m_f = 1.3;% [Kg]
c_f = 1000;% [J/(Kg*K)] 
% Average thermal capacity of the mass of the air in the box
C_f = c_f*m_f;% [J/K]

% Average thermal transmittance per unit surface cheese/air
barK_fc = 100; % [W/(m^2*K)]
% Surface of the cheese
s_c = 0.12;% [m^2]
% Overall thermal transmittance between the air in the box and the cheese
k_fc = barK_fc*s_c; % [W/K]

% Average thermal transmittances per unit surface air/external environment
barK_af = 0.2;% [W/(m^2*K)]
% surface of the box
s_f = 6;%[m^2]
% Overall thermal transmittance between the air in the box and the external
%environment
k_af = barK_af*s_f;

% Addictive "cheese" noise variance
var_wc = 1;

% Addictive "box" noise variance
var_wf = 1;

% Load the extracted values
load('ExtractedData.mat')

% 'Fromworkspace' block in Simulink needs timeseries 
%The '.*' operator is used to multiply each entry of the vector by 60*60
%(indeed it's given in hours, but SI time unit is second s). Transpose
%since we want a row vector, while it's a column vector.
timeseriesHatTheta_c = timeseries(hatTheta_c', time.*(60*60)');
timeseriesHatTheta_a = timeseries(hatTheta_a', time.*(60*60)');

%% Point 2)
% Sample time
Ts = 1;%[s]

%% Point 3)
% Initial theta_c
theta0_c = Celsius2Kelvin(25);
% Initial theta_f
theta0_f = Celsius2Kelvin(8);
%% Point 4)
q_star = 100;