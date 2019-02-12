function [Pref] = HeartRateToPower(age, trainLevel, sex, height, weight, HRref)


% HEARTRATETOPOWER calculates the individual power output of a rider for a given Heart Rate
% Output:   Pref: power output at reference heart rate[Watt]
% Input:    HRref: reference Heart rate [bpm]
%           Age: age [years]
%           Training Level: trainLevel [1==untrained, 2==average, 3==trained]
%           sex: sex [1==male, 2==female]
%           Height: height [cm]
%           Weight: weight [kg]

BMI = weight/height^2;

% get BMI
if BMI<25
    BMICount = 1;
else
    BMICount = 2;
end

% get age group
if age<35
    ageCount = 1;
elseif age<65
    ageCount = 2;
else
    ageCount = 3;
end


%% Calculate maximum Heart Rate by linear regression model
% ####################################
% ### HR_max = b0_HR + b1_HR * age ###
% ####################################
%
% Coefficient b0_HR for the linear regression model
% Rows represent BMI: 1==BMI<25; 2==BMI>25
% Columns represent Training level: 1==untrained; 2==average;
%       3==ambitious recreational sportsman
b0_HR = [208 206 210; 211 204 213];

% Coefficient b1_HR for the linear regression model
% Rows represent BMI: 1==BMI<25; 2==BMI>25
% Columns represent Training level: 1==untrained; 2==average;
%       3==ambitious recreational sportsman
b1_HR = [-0.83 -0.68 -0.72; -1.05 -0.76 -0.85];



% Calculating the maximum Heart Rate for given age depending on
% BMI and Training Level
HR_max = b0_HR(BMICount,trainLevel) + b1_HR(BMICount, trainLevel)*age;

%% Calculating the maximum Power Output by linear regression model
% #################################################
% ### P_max = b0_P + b1_P * age + b2_P * weight ###
% #################################################
%
% Coefficient b0_P for the linear regression model
% Rows represent sex: 1==male; 2==female
% Columns represent Training level: 1==untrained; 2==average;
%       3==ambitious recreational sportsman
b0_P = [160.86 323.98 252.15; 186.15 170.84 170.84];

% Coefficient b1_P for the linear regression model
% Rows represent sex: 1==male; 2==female
% Columns represent Training level: 1==untrained; 2==average;
%       3==ambitious recreational sportsman
b1_P = [-1.23 -1.47 -0.96; -1.19 -0.82 -0.82];

% Coefficient b2_P for the linear regression model
% Rows represent sex: 1==male; 2==female
% Columns represent Training level: 1==untrained; 2==average;
%       3==ambitious recreational sportsman
b2_P = [0.93 -0.13 0.96 0.21 0.66 0.66];

% Calculating the maximum Power Output for given age and weight depending
% on sex and training level
P_max = b0_P(sex,trainLevel) + b1_P(sex,trainLevel)*age + b2_P(sex,trainLevel)*weight;


%% Calculating the Heart Rate and Power at IAS and low intensities
% Coefficient for the Heart Rate at low intensities
% ##############################
% ### HR_1 = alpha1 * HR_max ###
% ##############################
% Rows represent age: 1==<35; 2==<65; 3==>65
% Columns represent Training level: 1==untrained; 2==average;
%       3==ambitious recreational sportsman
alpha1Male = [0.61 0.53 0.40; 0.61 0.53 0.40; 0.66 0.57 0.42];
alpha1Female = [0.65 0.60 0.40; 0.65 0.60 0.40; 0.72 0.64 0.64];


% Coefficient for the Heart Rate at the individual anaerobic threshold
% ################################
% ### HR_IAT = alpha2 * HR_max ###
% ################################
% Rows represent age: 1==<35; 2==<65; 3==>65
% Columns represent Training level: 1==untrained; 2==average;
%       3==ambitious recreational sportsman
alpha2Male = [0.84 0.82 0.72; 0.84 0.82 0.72; 0.88 0.83 0.85];
alpha2Female = [0.85 0.85 0.73; 0.85 0.85 0.73; 0.86 0.84 0.84];

% Coefficient for the Power at the individual anaerobic threshold
% ##############################
% ### P_IAT = alpha3 * P_max ###
% ##############################
% Rows represent age: 1==<35; 2==<65; 3==>65
% Columns represent Training level: 1==untrained; 2==average;
%       3==ambitious recreational sportsman
alpha3 = [0.68 0.68 0.69; 0.72 0.70 0.73; 0.78 0.72 0.74];

if sex==1
    alpha1 = alpha1Male;
    alpha2 = alpha2Male;
elseif sex==2
    alpha1 = alpha1Female;
    alpha2 = alpha2Female;
end

HR_1 = alpha1(ageCount, trainLevel)*HR_max;
HR_IAT = alpha2(ageCount, trainLevel)*HR_max;
P_IAT = alpha3(ageCount, trainLevel)*P_max;

if HRref<HR_IAT
    gradient = (HR_IAT - HR_1)/(P_IAT - 75);
    offset = HR_IAT - gradient*P_IAT;
elseif HRref<HR_max
    gradient = (HR_max - HR_IAT)/(P_max - P_IAT);
    offset = HR_max - gradient*P_max;
end

Pref = (HRref-offset)/gradient;

end

