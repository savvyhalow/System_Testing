%for plotting PID controlld data

close all;

data = readtable('Rotating_Chair_Data 07-18-2019 02.07.22.txt'); %full original velocity profiles
%data = readtable('Rotating_Chair_Data 07-18-2019 02.20.32.txt');%setpoint control with head movements


voltIdeal = cell2mat(table2cell(data(2:end,1)))'; %ideal voltage
velOutput = cell2mat(table2cell(data(2:end,3)))'; %recorded velocity
controlInput = cell2mat(table2cell(data(2:end,4)))'; %voltage actually sent to chair
error = cell2mat(table2cell(data(2:end,5)))'; %error between recorded and ideal voltage
t = 0:1/90:(length(voltIdeal)/90)-(1/90); %(1/90) is sample time

 figure(1)
 plot(t,voltIdeal);
 hold on
 plot(t,velOutput);
 hold on
 plot(t,controlInput);
 hold on
 plot(t,error);
 xlabel('time (sec)');
 ylabel('Angular Velocity (degrees/sec)');
 legend('ideal velocity','velocity output', 'control input', 'error');
