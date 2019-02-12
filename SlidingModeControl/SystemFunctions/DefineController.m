function cont = DefineController(eta, epsilon, lowLim, upLim, c)
%% param
% Create the parameters for the heart rate model
%
% NAME          | DESCRIPTION                                | UNIT
% -------------------------------------------------------------------------
% eta           | gain for the sliding mode controller       | [-]
% epsilon       | parameter for saturation function          | [-]
% lowLim, upLim | lower and upper bound for controller       | [-]
% c             | type of controller                         | [-]

cont.eta = eta;
cont.eps = epsilon;
cont.lowLim = lowLim;
cont.upLim = upLim;
% Specify controller
% 1 == Simple SMC
% 2 == Quasi SMC
cont.c = c;