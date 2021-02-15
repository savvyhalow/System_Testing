%plots data from NIcontroller.cs
close all;

%import data
data = readtable('Rotating_Chair_Data full.txt');

%input voltage
voltInput = cell2mat(table2cell(data(2:end,1)))'; %note: to get velocity, multiply by 7.06

%recorded position
posOutputNoisy = cell2mat(table2cell(data(2:end,7))');

%moving average filter with zero-phase
windowSize = 20; 
b = (1/windowSize)*ones(1,windowSize);
a = 1;
posOutput = filtfilt(b,a,posOutputNoisy);

%output velocity
t = 0:1/90:(length(posOutput)/90)-(1/90); %(1/90) is sample time
velOutput = gradient(posOutput,t);

%plot positions pre and post filtering
figure(1)
plot(t,posOutput);
hold on
plot(t,posOutputNoisy);
xlabel('time(sec)');
ylabel('Position (degrees)');
legend('filtered position', 'original position');

%plot velocity input/output (post filtering)
figure(2)
plot(t,voltInput*7.06);
hold on
plot(t,velOutput);
xlabel('time (sec)');
ylabel('Angular Velocity (degrees/sec)');
legend('velocity input','velocity output (after filtered)');