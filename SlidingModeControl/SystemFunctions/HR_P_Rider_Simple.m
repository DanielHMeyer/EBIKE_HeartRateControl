function [HR_max, P_max, HR_IAT, P_IAT, grade_IAT, grade_MAX, t_IAT, t_MAX] = HR_P_Rider_Simple(age, gender, height, weight)

% HR_P_Rider calculates the individual power output of a rider for a given Heart Rate
% Output:   
% Input:    Age: age [years]
%           sex: sex [1==male, 2==female]
%           Height: height [cm]
%           Weight: weight [kg]

BMI = weight/height^2;

%% Calculate maximum Heart Rate by linear regression model
% Berechnung der maximalen Herzfrequenz des Fahrers
% #########################################################################
% ### HR_max = b0_HRmax + b1_HRmax*age + b2_HRmax*gender + b3_HRmax*BMI ###
% #########################################################################
b0_HRmax = 233.64;
b1_HRmax = -0.84;
b2_HRmax = -2.11;
b3_HRmax = -0.92;
HR_max = b0_HRmax + b1_HRmax*age + b2_HRmax*gender + b3_HRmax*BMI;

%% Calculating the maximum Power Output by linear regression model
% Berechnung der maximalen Leistung des Fahrers
% ####################################################################
% ### P_max = b0_Pmax + b1_Pmax*age + b2_Pmax*gender + b3_Pmax*BMI ###
% ####################################################################
b0_Pmax = 366.48;
b1_Pmax = -1.73;
b2_Pmax = -87.86;
b3_Pmax = -1.62;
P_max = b0_Pmax + b1_Pmax*age + b2_Pmax*gender + b3_Pmax*BMI;


%% Calculating the Heart Rate and Power at IAS and low intensities
% Berechnung der Herzfrequenz an der individuellen anaeroben Schwelle des Fahrers
% #########################################################################
% ### HR_IAT = b0_HRIAT+ b1_HRIAT*age + b2_HRIAT*gender + b3_HRIAT*BMI ###
% #########################################################################
b0_HRIAT = 192.25;
b1_HRIAT = -0.67;
b2_HRIAT = 1.38;
b3_HRIAT = -0.77;
HR_IAT = b0_HRIAT + b1_HRIAT*age + b2_HRIAT*gender + b3_HRIAT*BMI;

% Coefficient for the Power at the individual anaerobic threshold
% Berechnung der Leistung an der individuellen anaeroben Schwelle des Fahrers
% ####################################################################
% ### P_IAT = b0_PIAT + b1_PIAT*age + b2_PIAT*gender + b3_PIAT*BMI ###
% ####################################################################
b0_PIAT = 247.34;
b1_PIAT = -0.96;
b2_PIAT = -62.48;
b3_PIAT = -1.18;
P_IAT = b0_PIAT + b1_PIAT*age + b2_PIAT*gender + b3_PIAT*BMI;

%%
% Berechnung der Steigung unter der individuellen anaeroben Schwelle
% ####################################################################
% ### grad_IAT = b0_IAT + b1_IAT*age + b2_IAT*gender + b3_IAT*BMI ###
% ####################################################################
b0_IAT = 0.8811;
b1_IAT = 0.0012; % statistisch nicht signifikant
b2_IAT = 0.3719;
b3_IAT = -0.0118;
grade_IAT = b0_IAT + b1_IAT*age + b2_IAT*gender + b3_IAT*BMI;

% Berechnung der Steigung über der individuellen anaeroben Schwelle
% ####################################################################
% ### grad_MAX = b0_max + b1_max*age + b2_max*gender + b3_max*BMI ###
% ####################################################################
b0_max = 0.2306;
b1_max = 0.0040;
b2_max = 0.1582;
b3_max = 0.0002;     % statistisch nicht signifikant
grade_MAX = b0_max + b1_max*age + b2_max*gender + b3_max*BMI;

% Berechnung des Schnittpunkts der Geraden IAT und der Geraden MAX
t_IAT = HR_IAT - P_IAT*grade_IAT;
t_MAX = HR_max - P_max*grade_MAX;

end