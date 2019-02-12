%% Run simulation and process simulation data
% Simulate the model and prepare the data for plotting

%% Set variables
% Simulation time in [s]
time = (0:1:1800)';
len = length(time);

%% Create different heart rate profiles
% Profile 1: Constant heart rate
hrProfConst(1:len,1) = 135;

% Profile 2: Transition
hrProfTrans(1:300,1) = (100.1:0.1:130)';
hrProfTrans(301:900,1) = 130;
hrProfTrans(901:1020,1) = (130.125:0.125:145)';
hrProfTrans(1021:1600,1) = 145;
hrProfTrans(1601:len,1) = (145:-0.225:100);

% Profile 3: Intervals
hrProfInt(1:300,1) = 120;
for i=1:3
    hrProfInt(301+(i-1)*360:480+(i-1)*360,1) = 140;
    hrProfInt(481+(i-1)*360:660+(i-1)*360,1) = 120;
end
hrProfInt(1381:len,1) = 120;

%% Create different environmental disturbances
% Constant disturbance
alphaConst(1:len,1) = 1.0;

% Slow changing disturbance
alphaSlow(1:300,1) = 0.2;
alphaSlow(301:600,1) = 0.5;
alphaSlow(601:1200,1) = 1.1;
alphaSlow(1201:1500,1) = 0.5;
alphaSlow(1501:len,1) = 0.2;

% Fast changing disturbance
alphaFast(1:450,1) = 0.2;
for i=1:10
    alphaFast(451+(i-1)*120:510+(i-1)*120,1) = 1.3;
    alphaFast(511+(i-1)*120:570+(i-1)*120,1) = 0.2;
end
alphaFast(1651:len,1) = 0.5;

%% Create different velocity profiles
% Constant profile
nConst(1:len,1) = 60;

% fast changing profile
nFast(1:450,1) = 60;
for i=1:10
    nFast(451+(i-1)*120:510+(i-1)*120,1) = 70;
    nFast(511+(i-1)*120:570+(i-1)*120,1) = 50;
end
nFast(1651:len,1) = 60;

%% Create simulation inputs
rider = DefineRider(78.5, 183, 30, 2, 1, 52, 100, 60, 20);
param = DefineParameters(0.0113, 0.0072, 0.0049, 0.0041, 19.8002, 0.0072);
paramIH = DefineParameters(0.1106, 0.0290, 0.0249, 0.0104, -21.7188, 0.0290);
%paramIH = DefineParameters(0.0113, 0.0072, 0.0049, 0.0041, 19.8002, 0.0072);
motor = DefineMotor(2.58*10^-1, 3.51*10^-1, 9.27*10^-3, 250, 70, 0);
bike = DefineBicycle(0.8,1,0.1004,0.01,70,0.175,0.33,0.33,0.12,0.28,6,motor);
route = DefineRoute(alphaConst, 1.25, 0, 9.81);

%% Run simulations and process data
% Follow a constant heart rate profile with slow changing disturbances
cont = DefineController(1, 0.1, -50, 50, 2);
Torque_chr_sd = runSimulationQuadRad(time,alphaSlow,nConst,hrProfConst,'TORQUE');
cont = DefineController(1, 0.1, -50, 50, 2);
Assist_chr_sd = runSimulationQuadRad(time,alphaSlow,nConst,hrProfConst,'ASSIST');

% Process data
RTorque_chr_sd = processData(Torque_chr_sd,time,'SMC+FF');
RAssist_chr_sd = processData(Assist_chr_sd,time,'SMC+FF');

%% Plot results
compareHRandT(time, [RTorque_chr_sd RAssist_chr_sd])

%% Run simulations and process data
% Follow a constant heart rate profile with fast changing disturbances
cont = DefineController(1, 0.1, -50, 50, 2);
Torque_chr_fd = runSimulationQuadRad(time,alphaFast,nConst,hrProfConst,'TORQUE');
Assist_chr_fd = runSimulationQuadRad(time,alphaSlow,nConst,hrProfConst,'ASSIST');

% Process data
RTorque_chr_fd = processData(Torque_chr_fd,time,'SMC+FF');
RAssist_chr_fd = processData(Assist_chr_fd,time,'SMC+FF');

%% Plot results
compareHRandT(time, [RTorque_chr_fd RAssist_chr_fd])

%% Run simulations and process data
% Follow a constant heart rate profile with slow changing disturbances
cont = DefineController(1, 0.1, -20, 20, 2);
TorqueSimple_chr_sd = runSimulationQuadRad(time,alphaSlow,nConst,hrProfConst,'TORSIM');
TorqueSimple_chr_fd = runSimulationQuadRad(time,alphaFast,nConst,hrProfConst,'TORSIM');

% Process data
RTorqueSimple_chr_sd = processData(TorqueSimple_chr_sd,time,'SMC+FF');
RTorqueSimple_chr_fd = processData(TorqueSimple_chr_fd,time,'SMC+FF');

%% Plot results
compareHRandT(time, [RTorqueSimple_chr_fd RTorqueSimple_chr_sd])

%% Run simulations and process data
% Follow a interval type heart rate profile with slow changing disturbances
cont = DefineController(1, 0.1, -50, 50, 2);
TorqueSimple_shr_sd = runSimulationQuadRad(time,alphaSlow,nConst,hrProfTrans,'TORSIM');
TorqueSimple_fhr_fd = runSimulationQuadRad(time,alphaFast,nConst,hrProfInt,'TORSIM');

% Process data
RTorqueSimple_shr_sd = processData(TorqueSimple_shr_sd,time,'SMC+FF');
RTorqueSimple_fhr_fd = processData(TorqueSimple_fhr_fd,time,'SMC+FF');

%% Plot results
compareHRandT(time, [RTorqueSimple_fhr_fd RTorqueSimple_shr_sd])

%% Run simulations and process data
% Follow a constant heart rate profile with slow changing disturbances
cont = DefineController(1, 3, -12, 12, 2);
TorqueSimple_chr_fd = runSimulationQuadRad(time,alphaConst,nConst,hrProfConst,'TORSIM');

% Process data
RTorqueSimple_chr_fd = processData(TorqueSimple_chr_fd,time,'SMC+FF');

%% Plot results
compareHRandT(time, RTorqueSimple_chr_fd)

%% Plot results
compareHRandT2(time, RTorqueSimple_chr_fd)
