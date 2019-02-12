%% RunSimulinkSim_MPC

%% Load variables
%load altitudeProfile.mat
%load ReferencesMPC.mat
load Data_Validation_MPC.mat
fRES = smooth(forceResistances,60);
%fRES60 = smooth(forceResistances,60);
%% Define variables
% Cyclist (sex, age, height [cm], weight [kg], cadence [U/min])
cyclist = initCyclist(0, 30, 183, 75, 80);

% Bicycle (weight [kg], cR [-], cwA [m²], r_rw [m], l_c [m], k_M [A/Nm], tau_M [-], W_Bat [Wh], U_Bat [V])
bicycle = initBicycle(60, 0.01468, 0.79, 0.33, 0.17, 5.5, 24, 50, 48);

% Environment
environment = initEnvironment_V2(altitude, distance, fRES, 9.81, 1.2041);

clear acceleration altitude distance forceResistances fRES motorPower power velocity

%% Calculate variables
% Calculate the relationship of heart rate and power
cyclist.HR_rest = 70;
[cyclist.P_max, cyclist.P_iat, cyclist.HR_max, cyclist.HR_iat, cyclist.slope_max, cyclist.slope_iat] = estHRPowerV2(cyclist);

cyclist.HR_ref = 0.69*cyclist.HR_max;   % reference heart rate [bpm]
cyclist.HR_low = 0.64*cyclist.HR_max;
cyclist.HR_high = 0.74*cyclist.HR_max;
cyclist.P_ref = 1/cyclist.slope_iat*(cyclist.HR_ref-cyclist.HR_iat)+cyclist.P_iat;  % reference power output at HR_ref
cyclist.P_low = 1/cyclist.slope_iat*(cyclist.HR_low-cyclist.HR_iat)+cyclist.P_iat;
cyclist.P_high = 1/cyclist.slope_iat*(cyclist.HR_high-cyclist.HR_iat)+cyclist.P_iat;

% Heart rate model
system = initHRmodel(0.0113, 0.0072, 0.0049, 0.0041, 19.8002, 0.0072, cyclist.P_max, cyclist.cadence);

% Calculate riding resistances
[environment.F_RES, ~] = calculateRES(cyclist,bicycle,environment);

%% Initial conditions
init.omega_p = 1.33*2*pi;
init.tau = 1.1;
init.v_Bike = init.omega_p*init.tau*bicycle.rrw;
init.d_Bike = 1;
init.x1 = (110-cyclist.HR_rest)/cyclist.HR_max;
init.x2 = 0;
init.x2_est = 0;
init.P_RES = 600;
init.T_RES = init.P_RES/init.omega_p;

%% Simulation variations
% type of riding resistances:
% 1 := real measurements
% 2 := Constant resistances
% 3 := constant resistances + white noise
% 4 := custom resistances (F_RES)
variation.rideRes = 2;

% type of trip information
% 1 := Trip Optimization (rideRes == 1)
% 2 := Constant reference motor power
% 3 := custom reference power (P_M_REF)
variation.tripInfo = 1;

% type of controller
% 1 := Linear MPC
% 2 := SMC
% 3 := Constant proportional assistance
% 4 := No control
variation.controller = 1;

%% Prepare Simulation
version = '';
model = 'TorqueControl_QuadRad_MPC';
model_name = strcat(model,version);
time = (1:1:4000)';
len = length(time);

%% Create custom signals
F_RES = repmat([75 125 75 125],1,len/4000);
for i=1:len/1000
    custom.F_RES(1+(i-1)*1000:i*1000,1) = F_RES(1,i);
end

custom.TAU(1:len,1) = 1.9;
%custom.TAU = tau_MPC(1:500,1);          % necessary for SMC and PropControl

clear i version model len F_RES

%% Set the MPC Controller and run simulation
% Weights for cost function: default 
% w1 = (HR_max/delta_HR)^2
% w2 = 1/1.96
% w3 = 50
% w4 = 1/delta_P^2
delta_P = (cyclist.P_high-cyclist.P_low)/2;
delta_HR = (cyclist.HR_high-cyclist.HR_low)/2;
weights = [(cyclist.HR_max/delta_HR)^2 1/1.96 50 1/delta_P^2];      % weights for cost function

%% Run one simulation
mpc.predHor = 5;
mpc.weights = weights.*[1 4 8 1];

clear delta_P delta_HR weights

%%
custL(1:20,1) = 250;
in = [cyclist.cadence; cyclist.P_ref; bicycle.kM; bicycle.tauM; bicycle.cwA; bicycle.W_Bat; 0; 0; 0; 250; custL; 1; environment.F_RES'];
[~, ~, ~, P_M_ref, fac, P_M_ref_exc] = TripOptimization_Start(in);
P_M = P_M_ref+fac.*P_M_ref_exc;
P_M(P_M>250) = 250;

clear custL in P_M_ref fac P_M_ref_exc

%%
res = runSimMPCQuadRad(time, custom, model_name);

%%
t = res.get('simData');
result = t.Data;

%%
resultHor = cell(1,5);
mpc.weights = weights;
for i=1:5
    
    mpc.predHor = i*5;                                                       % prediction horizon
    % Run simulation
    res = runSimMPCQuadRad(time, custom, model_name);
    resultHor{1,i} = res;
end
%% Run simulation
mpc.predHor = 5;
results = cell(81,1);
factor = [1 50 100];

for i=1:3
    for j=1:3
        for k=1:3
            for l=1:3
                mpc.weights = weights.*[factor(1,i) factor(1,j) factor(1,k) factor(1,l)];
                res = runSimMPCQuadRad(time, custom, model_name);
                results{(i-1)*27+(j-1)*9+(k-1)*3+l,1} = res;
            end
        end
    end
end
    
%%
result = cell(81,1);

for k=1:81
    t = results{k,1}.get('simData');
    result{k,1} = t.Data;
end
