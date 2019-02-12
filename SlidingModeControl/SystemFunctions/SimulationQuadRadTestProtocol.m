%% Run simulation and process simulation data
% Simulate the model and prepare the data for plotting

%% Set variables
% Simulation time in [s]
time = (0:1:3600)';
len = length(time);

%% Create different environmental disturbances
% Constant disturbance
alphaConst(1:len,1) = -0.3;

% Changing disturbances
alphaSlow(1:300,1) = -0.3;
alphaSlow(301:900,1) = 0;
alphaSlow(901:1800,1) = 0.8;
alphaSlow(1801:2400,1) = 1.6;
alphaSlow(2401:3300,1) = 0.8;
alphaSlow(3301:len,1) = -0.3;


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
rider = DefineRiderSimple(78.5, 183, 30, 2, 1, 52, 100, 60, 20);
param = DefineParameters(0.0113, 0.0072, 0.0049, 0.0041, 19.8002, 0.0072);
paramIH = DefineParameters(0.1106, 0.0290, 0.0249, 0.0104, -21.7188, 0.0290);
%paramIH = DefineParameters(0.0113, 0.0072, 0.0049, 0.0041, 19.8002, 0.0072);
motor = DefineMotor(2.58*10^-1, 3.51*10^-1, 9.27*10^-3, 250, 70, 0);
bike = DefineBicycle(0.8,1,0.1004,0.01,70,0.175,0.33,0.33,0.12,0.28,6,motor);
route = DefineRoute(alphaConst, 1.25, 0, 9.81);

%% Create different heart rate profiles
% Profile 1: Constant heart rate
hrProfConst(1:len,1) = 135;

% Profile 2: Training protocol
hrProfTrans(1:600,1) = 0.62*rider.HR_max;
hrProfTrans(601:1500,1) = 0.69*rider.HR_max;
hrProfTrans(1501:2100,1) = 0.79*rider.HR_max;
hrProfTrans(2101:3000,1) = 0.69*rider.HR_max;
hrProfTrans(3001:len,1) = 0.62*rider.HR_max;

%% Run simulations and process data
% Follow a constant heart rate profile with slow changing disturbances
cont = DefineController(0.18, 0.3, -10, 20, 2);
TorqueSimple_chr_fd = runSimulationQuadRad_V2(time,alphaSlow,nConst,hrProfTrans,rider,'TORSIM2');

% Process data
RTorqueSimple_chr_fd = processData(TorqueSimple_chr_fd,time,'SMC+FF');

%% Plot results
compareHRandT(time, RTorqueSimple_chr_fd)

%% Plot results
compareHRandT2(time, RTorqueSimple_chr_fd)
