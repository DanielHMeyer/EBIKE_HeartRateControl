function rider = DefineRider(m, h, age, TL, sex, HR_rest, n_max, n_des, v_ref)
%% Motor
% Create a motor with the parameters
%
% NAME          | DESCRIPTION                               | UNIT
% -------------------------------------------------------------------------
% m             | weight of rider                           | [kg]
% h             | height of rider                           | [cm]
% age           | age of rider                              | [years]
% TL            | training level of rider                   | 1=untrained, 2=average, 3=trained
% sex           | sex of rider                              | 1=male, 2=female
% HR_rest       | heart rate at rest                        | [bpm]
% n_max         | maximum pedaling frequency                | [rpm]
% n_des         | desired pedaling frequency                | [rpm]
% n_min         | minimum pedaling frequency                | [rpm]
% v_ref         | desired cycling velocity                  | [km/h]

% P_max         | maximum power output of rider             | [W]
% HR_max        | maximum heart rate                        | [bpm]
% HR_IAT
% HR_1
% P_IAT

rider.m = m;
rider.h = h;
rider.TL = TL;
rider.age = age;
rider.sex = sex;
[rider.HR_max, rider.P_max, rider.HR_1, rider.HR_IAT, rider.P_IAT] = HR_P_Rider(age,TL,sex,h,m);
rider.HR_rest = HR_rest;
rider.n_max = n_max;
rider.n_des = n_des;
rider.n_min = 20;
rider.v_ref = v_ref;