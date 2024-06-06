% model name
model_relay = 'CoolingCheese_Relays'; 
model_pid = 'CoolingCheese_PID';
% 24 hours simulation time
simTime = 24*60*60; 
% run the simulation
simOutRelay = sim(model_relay, 'StopTime', num2str(simTime));
simOutPID = sim(model_pid, 'StopTime', num2str(simTime));
% acquire simulation data output
eCheeseTempRelay = simOutRelay.get('eCheeseTempRelay');
qRelay = simOutRelay.get('qRelay');
%eCheeseTempPID = simOutPID.get('eCheeseTempPID');
qPID = simOutPID.get('qPID');
eCheeseTempPID = reshape(out.eCheeseTempPID.Data,[1,H+1]);