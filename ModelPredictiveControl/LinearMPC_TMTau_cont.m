function u_out = LinearMPC_TMTau_cont(in)
%LINEARMPC Final version of the linear MPC
%   final version of the linear MPC with a continous transmission ratio

persistent controller

%%
x1 = in(1);
x2 = in(2);
a = [in(3) in(4) in(5) in(6) in(7) in(8)];
P_max = in(9);
r_rw = in(10);
x_ref = in(11);
HR_max = in(12);
P_M_ref = in(13);
F_RES = in(14);
n_p = in(15);
u0 = in(16);
time = in(17);

T = 1;              % step time
phi_x = a(4)*(1+x1)/(1+exp(a(5)-x1));     % linearization of heart rate model
curr_x = [x1; x2];

if time==0
    omega_p = 2*pi*n_p;
    gamma = omega_p*a(6)/P_max;
    T_M_ref = P_M_ref/omega_p;

    N = 5;              % Prediction steps
    nx = 2;             % number of states
    nu = 2;             % number of inputs

    w1 = 0.03*(HR_max^2);
    w2 = 0.4;
    w3 = 2.2;
    w4 = 1;

    yalmip('clear')

    x = sdpvar(nx,N+1);
    u = sdpvar(nu,N);
    sdpvar u_prev F_est phi_x_est

    A = [-a(1) a(2); phi_x_est -a(3)];              % x_dot = A*x + B*u
    B = [-gamma gamma*F_est*r_rw; 0 0];

    Cost = 0;
    Constraints = [];

    Constraints = [Constraints, -0.2 <= u(2,1)-u_prev <= 0.2];
    Cost = Cost + w4*abs(u(2,1)-u_prev);
    for k = 2:1:N
        Constraints = [Constraints, -0.04 <= u(2,k)-u(2,k-1) <= 0.04];
        Cost = Cost + w4*abs(u(2,k)-u(2,k-1));
    end
    for k = 1:1:N
        Constraints = [Constraints, x(:,k+1) == x(:,k) + T*(A*x(:,k) + B*u(:,k))];      % Euler discretization -> x(k+1) = x(k) + T*x_dot(k) = x(k) + T*(A*x(k) + B*u(k))                          % limit motor torque
        Constraints = [Constraints, 1 <= u(1,k)*omega_p <= 250];                        % limit motor power
        Constraints = [Constraints, 1 <= u(1,k) <= 70];                                 % limit motor torque
        Constraints = [Constraints, 1.4 <= u(2,k)*omega_p*r_rw <= 6.9];                 % limit cycling velocity
        Constraints = [Constraints, 1.1 <= u(2,k) <= 2.5];                              % limit transmission ratio
        Cost = Cost + w1*(x(1,k)-x_ref)*(x(1,k)-x_ref) + w2*(u(1,k)/T_M_ref)*(u(1,k)/T_M_ref) + w3*(1/u(2,k));
    end

    Options = sdpsettings('verbose',0,'solver','fmincon');
    controller = optimizer(Constraints, Cost, Options, {x(:,1),u_prev,F_est,phi_x_est}, u(:,:));

    x2_new = x2 + T*(phi_x*x1 - a(3)*x2);
    U = controller{{curr_x,u0,F_RES,phi_x}};

    u_out(1,1) = value(U(1,1));
    u_out(2,1) = value(U(2,1));
    u_out(3,1) = x2_new;
else
    x2_new = x2 + T*(phi_x*x1 - a(3)*x2);
    U = controller{{curr_x,u0,F_RES,phi_x}};

    u_out(1,1) = value(U(1,1));
    u_out(2,1) = value(U(2,1));
    u_out(3,1) = x2_new;
end