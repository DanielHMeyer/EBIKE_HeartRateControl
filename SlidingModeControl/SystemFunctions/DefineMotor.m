function motor = DefineMotor(tc, I, f, P_max, T_max, T_min)
%% Motor
% Create a motor with the parameters
%
% NAME          | DESCRIPTION                               | UNIT
% -------------------------------------------------------------------------
% tc            | torque constant                           | [Nm/A]
% I             | Motor inertia                             | [Nms^2/rad]
% f             | motor friction coefficient                | [Nms^2/rad]
% P_max         | maximum power output of motor             | [W]
% T_max         | maximum torque output of motor            | [Nm]
% T_min         | minimum torque output of motor            | [Nm]

motor.tc = tc;
motor.I = I;
motor.f = f;
motor.P_max = P_max;
motor.T_max = T_max;
motor.T_min = T_min;