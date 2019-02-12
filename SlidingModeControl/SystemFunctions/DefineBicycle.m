function bike = DefineBicycle(A, cw, f_DR, f_SR, m, r_C, r_RW, r_FW, I_RW, I_FW, tau, motor)
%% Set up bicycle
% Create a bicycle with the given parameters
%
% NAME          | DESCRIPTION                               | UNIT
% -------------------------------------------------------------------------
% A             | front surface area                        | [m^2]
% cw            | drag coefficient                          | [-]
% f_DR          | dynamic rolling resistance coefficient    | [-]
% f_SR          | static rolling resistance coefficient     | [Ns/m]
% m             | weight of bicycle                         | [kg]
% r_C           | crank length                              | [m]
% r_RW          | radius of rear wheel                      | [m]
% r_FW          | radius of front wheel                     | [m]
% I_RW          | mass moment of inertia of rear wheel      | [kgm^2]
% I_FW          | mass moment of inertia of front wheel     | [kgm^2]
% tau           | gear (values from 1 to 7)                 | [-]
% motor         | struct with motor variables               | [-]

bike.A = A;
bike.cw = cw;
bike.f_DR = f_DR;
bike.f_SR = f_SR;
bike.m = m;
bike.r_C = r_C;
bike.r_RW = r_RW;
bike.r_FW = r_FW;
bike.I_RW = I_RW;
bike.I_FW = I_FW;

% the bicycle has 7 gears; transmission ratio is defined by
% (teeth front sprocket) / (teeth rear sprocket)
switch tau
    case 1
        bike.tau = 1.14;
    case 2
        bike.tau = 1.33;
    case 3
        bike.tau = 1.52;
    case 4
        bike.tau = 1.78;
    case 5
        bike.tau = 2.13;
    case 6
        bike.tau = 2.46;
    case 7
        bike.tau = 2.91;
end

bike.motor = motor;
