function RES = processData(DATA, time, controller)
%% PROCESSDATE
% Extract the simulation data and prepare it for comparison and plotting

tdata = DATA.get('HR').time;
data = DATA.get('HR').data;
data(:,2) = DATA.get('HR_ref').data;
data(:,3) = DATA.get('T_M').data;
data(:,4) = DATA.get('T_Res').data;
data(:,5) = DATA.get('T_RRW').data;
data(:,6) = DATA.get('v').data;
data(:,7) = DATA.get('v_Ref').data;

resultDATA = zeros(length(time),size(data,2));
for i=1:size(data,2)
    resultDATA(:,i) = interp1(tdata,data(:,i),time);
end

RES.Time = time;
RES.CT = controller;
RES.HR.Name = 'HR';
RES.HR.HR = resultDATA(:,1);
RES.HR.HR_ref = resultDATA(:,2);
RES.T.Name = 'T';
RES.T.T_M = resultDATA(:,3);
RES.T.T_Res = resultDATA(:,4);
RES.T.T_RRW = resultDATA(:,5);
RES.v.Name = 'v';
RES.v.v = resultDATA(:,6);
RES.v.v_ref = resultDATA(:,7);
