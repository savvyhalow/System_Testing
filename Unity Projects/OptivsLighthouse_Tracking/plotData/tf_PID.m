%calculates transfer function and PID values from PIDcontroller.cs

% close all;
% 
% %import data
% selpath = uigetdir;
% cd(selpath);
% 
% 
% filename1 = uigetfile ({'*.txt'},'Rotating chair Data File');

% 
% [Timestamp,PremadeVoltage,ActualSentVoltage,PremadeVelocity,ActualVelocity] = import_initial(filename1);

data = readtable('Rotating_Chair_Data full new.txt');
voltIdeal = cell2mat(table2cell(data(2:end,1)))';
velOutput = cell2mat(table2cell(data(2:end,3)))';
t = 0:1/90:(length(voltIdeal)/90)-(1/90); %(1/90) is sample time


% %*******Convert initial recording times to minutes/seconds
% trial_str = Timestamp;
% expression = '[ \.:]';
% 
%             
% % split to find minutes
% trial_splitstr = regexp(trial_str,expression,'split');
% 
% for i = 1:length(trial_splitstr)
%     
% trial_time_Minutes=trial_splitstr{i}{3};
% trial_num_Minutes=str2num(trial_time_Minutes);
% 
% %Convert to seconds
% if trial_num_Minutes ~= 0
%     trial_num_Minutes=trial_num_Minutes*60;
% end
% 
% %Find seconds
% trial_time_Seconds=trial_splitstr{i}{4};
% trial_num_Seconds=str2num(trial_time_Seconds);
% 
% %split again to find milliseconds
% trial_time_milli_Seconds=trial_splitstr{i}{5};
% trial_num_milli_Seconds=str2num(trial_time_milli_Seconds);
% 
% %convert to seconds
% if trial_num_milli_Seconds ~= 0
%     trial_num_milli_Seconds=trial_num_milli_Seconds/60;
% end
% 
% %Add times to get time recording start in seconds
% trial_time(i)=trial_num_Minutes+trial_num_Seconds+trial_num_milli_Seconds;
% 
% 
% end
% 
% trial_time = trial_time';

%transfer function
dataOpti = iddata(velOutput',voltIdeal',[],'SamplingInstants',t');
sysOpti = tfest(dataOpti,2,1); %specify number of poles/zeros here
H = tf(sysOpti.Numerator,sysOpti.Denominator)
[poles,zeros] = pzmap(sysOpti)


% transfer function
% dataOpti = iddata(ActualVelocity,PremadeVoltage,[],'SamplingInstants',trial_time);
% sysOpti = tfest(dataOpti,2,1); %specify number of poles/zeros here
% H = tf(sysOpti.Numerator,sysOpti.Denominator)
% [poles,zeros] = pzmap(sysOpti)

%creates PID controller
pidTuner(sysOpti, 'PID')

%Tunes PID controller
pidtune(sysOpti,'PID')

%plot recorded output vs output calculated from transfer function
%simulated transfer function result
y = lsim(H,voltIdeal,t);
figure(1)
%recording pre-PID implementation
plot(t,velOutput-velOutput(1));
hold on
plot(t, y);
xlabel('time (sec)');
ylabel('Velocity (degrees/sec)');
legend('Recorded Output', 'TF Output');