function u_out = LinearMPC_V8(in)
%LINEARMPC Summary of this function goes here
%   Detailed explanation goes here

%% Store inputs
x1 = in(1);
x2 = in(2);
a = [in(3) in(4) in(5) in(6) in(7) in(8)];
P_max = in(9);
r_rw = in(10);
x_ref = in(11);
HR_max = in(12);
P_M_ref = in(13);
F_est = in(14);
n_p = in(15);
u_tau_prev = in(16);
time = in(17);

%% Define parameters
phi_x = a(4)*(1+x1)/(1+exp(a(5)-x1));       % linearization of heart rate model
curr_x = [x1; x2];                          % current states
omega_p = 2*pi*n_p;                         % pedaling frequency [rad/s]
gamma = omega_p*a(6)/P_max;                 % variable
T_M_ref = P_M_ref/omega_p;                  % reference motor torque

A_model = [-a(1) a(2); phi_x -a(3)];        % model matrix (x_dot = A*x + B*u)
B_model = [-gamma gamma*F_est*r_rw; 0 0];   % model matrix 

T = 1;                                      % step time
N = 5;                                      % Prediction steps
nx = 2;                                     % number of states
nu = 2;                                     % number of inputs

w = [0.03*(HR_max^2); 0.1; 2.2; 1];         % weights for cost function

%% Calculate optimal solution
u0 = zeros(nu,N);                   % control input vector
u0(2,:) = u_tau_prev;

%x = computeSolution(nx,N,T,curr_x,A_model,B_model,u0);

A = [omega_p 0; -omega_p 0; 0 omega_p*r_rw; 0 -omega_p*r_rw];   % linear constraints (A*u <= b)
A_ineq = blkdiag(A,A,A,A,A);
b_ineq = repmat([250; -1; 6.9; -1.4],5,1);                           % linear contstraints
lb = repmat([1; 1.1],1,5);                                                  % lower limit for control input
ub = repmat([70; 2.5],1,5);                                                 % upper limit for control input

[u, fval, exitflag, output] = fmincon(@(u) computeCosts(nx,N,T,curr_x,x_ref,A_model,B_model,u,u_tau_prev,T_M_ref,w), u0, A_ineq, b_ineq, [], [], lb, ub);

x2_new = x2 + T*(phi_x*x1 - a(3)*x2);

u_out = [u(:,1); x2_new];

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
% T_ref     | reference motor torque#
% w         | weight vector for costs
%
function cost = computeCosts(nx,N,T,x0,x_target,A,B,u,u_prev,T_ref,w)
    
    cost = 0;
    x = computeSolution(nx,N,T,x0,A,B,u);
    u_cost = [0 u(1,:); u_prev u(2,:)];
    
    for k=2:N+1
        cost = cost + w(1)*(x(1,k)-x_target)^2 + w(2)*(u_cost(1,k)-T_ref)^2 + w(3)*(1/u_cost(2,k)) + w(4)*abs(u_cost(2,k)-u_cost(2,k-1));
    end

end
