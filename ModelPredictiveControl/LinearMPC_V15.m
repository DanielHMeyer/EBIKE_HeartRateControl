function u_out = LinearMPC_V15(x1, u_TM_prev, u_tau_prev, x2, a, P_max, r_rw, x_ref, P_M_ref, T_RES, n_p, P_low, P_high, w, N, W_Bat)
%LINEARMPC Summary of this function goes here
%   Detailed explanation goes here

%% Define parameters
P_ref = (P_high+P_low)/2;
phi_x = a(4)*(1+x1)/(1+exp(a(5)-x1));       % linearization of heart rate model
curr_x = [x1; x2];                          % current states
omega_p = 2*pi*n_p;                         % pedaling frequency [rad/s]
gamma = omega_p*a(6)/P_max;                 % variable
if W_Bat<0
    T_M_ref = 0.01;
elseif P_M_ref<1
    T_M_ref = 0.01;
elseif P_M_ref/omega_p>70
    T_M_ref = 70;                  % reference motor torque
else
    T_M_ref = P_M_ref/omega_p;
end
%T_R_ref = P_R_ref/omega_p;                  % reference rider torque

A_model = [-a(1) a(2); phi_x -a(3)];        % model matrix (x_dot = A*x + B*u)
B_model = [-gamma gamma*T_RES; 0 0];        % model matrix 

T = 1;                                      % step time
%N = 5;                                      % Prediction steps
nx = 2;                                     % number of states
nu = 2;                                     % number of inputs

%% Calculate optimal solution
u0 = zeros(nu,N);                   % control input vector
u0(1,:) = u_TM_prev;
u0(2,:) = u_tau_prev;

A = [omega_p 0; -omega_p 0; 0 omega_p*r_rw; 0 -omega_p*r_rw];   % linear inequality constraints (A*u <= b)
A_ineq = [];
for i=1:N
    A_ineq = blkdiag(A_ineq,A);
end
b_ineq = repmat([P_M_ref; 0; 6.9; -1.4],N,1);                      % linear inequality contstraints
lb = repmat([0; 1.1],1,N);                                       % lower limit for control input
ub = repmat([T_M_ref; 2.5],1,N);                                      % upper limit for control input

opts = optimoptions('fmincon','MaxFunEvals',3000,'TolFun', 1e-6);

u = fmincon(@(u) computeCosts(nx,N,T,curr_x,x_ref,A_model,B_model,u,u_tau_prev,T_RES,omega_p,P_ref,w), u0, A_ineq, b_ineq, [], [], lb, ub, [],opts);

%x2_new = x2 + T*(phi_x*x1 - a(3)*x2);

u_out = u(:,1);

end

%% Compute Solution
% Computes the solution of the system for the prediction horizon
%
% INPUTS
% Variable  | Description
% ----------------------------------------------------
% nx        | Number of states
% N         | Prediction horizon
% T         | step size
% x0        | initial states for heart rate
% A         | model matrice (x(k+1) = A*x(k) + B*u(k))
% B         | model matrice
% u         | control input vector
%
function x_sol = computeSolution(nx,N,T,x0,A,B,u)

    x_sol = zeros(nx,N+1);
    x_sol(:,1) = x0;
    for k=1:N
        x_sol(:,k+1) = x_sol(:,k) + T*(A*x_sol(:,k)+B*u(:,k));
    end
    
end

%% Cost function
% Computes the cost of the optimization
%
% INPUTS
% Variable  | Description
% ----------------------------------------------------
% nx        | Number of states
% N         | Prediction horizon
% T         | step size
% x0        | initial states for heart rate
% x_target  | target heart rate
% A         | model matrice (x(k+1) = A*x(k) + B*u(k))
% B         | model matrice
% u         | control input vector
% u_prev    | gear ratio of previous step
% T_M_ref   | reference motor torque
% w         | weight vector for costs
%
function cost = computeCosts(nx,N,T,x0,x_target,A,B,u,u_prev,T_RES,omega_p,P_ref,w)
    
    cost = 0;
    x = computeSolution(nx,N,T,x0,A,B,u);
    u_cost = [0 u(1,:); u_prev u(2,:)];
    
    for k=2:N+1
        cost = cost + w(1)*(x(1,k)-x_target)^2 + w(2)*(2.5-u_cost(2,k))^2 + w(3)*(u_cost(2,k)-u_cost(2,k-1))^2 + w(4)*(T_RES*omega_p*u_cost(2,k)-omega_p*u_cost(1,k)-P_ref)^2;
    end

end
