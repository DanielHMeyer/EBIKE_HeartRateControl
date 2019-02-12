function res = runSimulationQuadRad(time, alpha, ndes, hrprofile, controller)
%% runs the simulation and outputs results 

% specify length of simulation
len = length(time);
simtime = num2str(len);

% set timeseries objects
ALPHA = timeseries(alpha,time);
assignin('base', 'ALPHA', ALPHA);
HRPROFILE = timeseries(hrprofile,time);
assignin('base', 'HRPROFILE', HRPROFILE);
NDES = timeseries(ndes, time);
assignin('base', 'NDES', NDES);

% Run simulation
switch controller
    case 'TORQUE'
        % Run simulation of FF+SMC model
        set_param('TorqueControl_QuadRad_FF_SMC', 'Solver','ode4');
        set_param('TorqueControl_QuadRad_FF_SMC', 'FixedStep','1');
        res = sim('TorqueControl_QuadRad_FF_SMC', 'StopTime', simtime);
    case 'ASSIST'
        % Run simulation of SMC model
        set_param('AssistControl_QuadRad_FF_SMC', 'Solver','ode4');
        set_param('AssistControl_QuadRad_FF_SMC', 'FixedStep','1');
        res = sim('AssistControl_QuadRad_FF_SMC', 'StopTime', simtime);
    case 'TORSIM'
                % Run simulation of FF+SMC model with simple FF
        set_param('TorqueControl_QuadRad_FFSimple_SMC', 'Solver','ode4');
        set_param('TorqueControl_QuadRad_FFSimple_SMC', 'FixedStep','1');
        res = sim('TorqueControl_QuadRad_FFSimple_SMC', 'StopTime', simtime);
        
    case 'TORSIM2'
                % Run simulation of FF+SMC model with simple FF (Version 2)
        set_param('TorqueControl_QuadRad_FFSimple_SMC_V2', 'Solver','ode4');
        set_param('TorqueControl_QuadRad_FFSimple_SMC_V2', 'FixedStep','1');
        res = sim('TorqueControl_QuadRad_FFSimple_SMC_V2', 'StopTime', simtime);
end
        