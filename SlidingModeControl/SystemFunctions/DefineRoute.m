function route = DefineRoute(slope, rho, v_wind, g)
%% DEFINEROUTE
% Defines the characteristics of the route
%
% NAME          | DESCRIPTION                               | UNIT
% -------------------------------------------------------------------------
% slope         | slope of the route                        | [°]
% rho           | air density                               | [kg/m^3]
% v_wind        | velocity of the headwind (negative sign)  | [m/s]
% g             | gravity force                             | [m/s^2]

route.slope = slope;
route.rho = rho;
route.v_w = v_wind;
route.g = g;