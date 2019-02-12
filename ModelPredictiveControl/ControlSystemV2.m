function u_out = ControlSystemV2(in)
%LINEARMPC Summary of this function goes here
%   Detailed explanation goes here

%% Store inputs
x1 = in(1);
u_TM_prev = in(2);
u_tau_prev = in(3);
x2 = in(4);
a = [in(5) in(6) in(7) in(8) in(9) in(10)];
P_max = in(11);
x_ref = in(12);
n_p = in(13)/2/pi;
P_high = in(14);
P_low = in(15);
P_ref = in(16);
r_rw = in(17);
P_M_ref = in(18);
T_RES = in(19);
T_Rp = in(20);
control = in(21);
weights = [in(22) in(23) in(24) in(25)]';
N = in(26);
tau = in(27);
W_Bat = in(28);

%% 
epsilon = 0.1;
eta = (-0.4*a(6)-a(1)*0.3657)*(0.5*18.7/187+epsilon)/(0.5*(-18.7)/187);
factor = 2;

%% Calculate x2
phi_x = a(4)*(1+x1)/(1+exp(a(5)-x1));       % linearization of heart rate model
T = 1;
x2_new = x2 + T*(phi_x*x1 - a(3)*x2);

%% Calculate control output
switch control
    case 1  % Model predictive Control
        u = LinearMPC_V15(x1, u_TM_prev, u_tau_prev, x2, a, P_max, r_rw, x_ref, P_M_ref, T_RES, n_p, P_low, P_high, weights, N, W_Bat);
        u_out = [u; x2_new];
    case 2  % Sliding mode control
        T_M = SMC(x1, x2, x_ref, a, P_ref, T_RES, epsilon, eta, P_max, n_p);
        u_out = [T_M; tau; x2_new];
    case 3  % Proportional control
        T_M = PropControl(T_Rp, factor);
        u_out = [T_M; tau; x2_new];
    case 4  % No control
        u_out = [0; tau; x2_new];
        
end

end