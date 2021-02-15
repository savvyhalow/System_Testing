% PID controller example - for testing/tuning PID output

% The example system is 
%      -100.6 s + 3908
% H= --------------------
%     s^2 + 26.93 s + 520.1
% The controller is 
% C = kp * error + ki * Sum of error + kd * derivative of error 
% The desired output is vd, sampling time T 


% step 1: change H to differential equ, c is control output, y is actual chair
% output
%     Y       -100.6 s + 3908
% H= ---- = ---------------------  
%     C     s^2 + 26.93 s + 520.1
% this is equivlent to 
%  y''  + 26.03 y' + 520.1 y = -100.6 c' + 3908 c 
%                                       y(n)-y(n-1)
% where ' means derivative, and y'(n) = ------------.
%                                           T
% if n = 2:
%
%        y(2)-y(1)                        c(2)-c(1)
% 26.93 ------------ + 520.1 y(2)= -100.6 ----------  +3908 c(2)
%           T                                T
%
%                                 c(2)-c(1)
% so, (26.93/T+520.1)y(2)= -100.6 ----------  +3908 c(2) + 26.93/T*y(1)
%                                   T
% if n>2:
%
%  y''  + 26.03 y' + 520.1 y = -100.6 c' + 3908 c 
%
%
% y(n)-2y(n-1)+y(n-2)         y(n)-y(n-1)                      c(n)-c(n-1)
% -------------------  +26.93------------ + 520.1 y(n)= -100.6 ----------  +3908 c(n)
%      T^2                        T                               T
%
%                                     c(n)-c(n-1)
%so, (1/T^2+26.93/T+520.1)y(n)=-100.6 ----------  +3908 c(n) + 26.93/T*y(n-1)+1/T^2*(2y(n-1)-y(n-2))
%                                        T

clear all 

%import data
data = readtable('Rotating_Chair_Data full new.txt');
vd = cell2mat(table2cell(data(2:end,1)))'; %note: to get velocity, multiply by 7.06
T = 1/90;
time = 0:T:(length(vd)/90)-(1/90);

sumerror=0;error(length(time))=0;c(length(time))=0;y(length(time))=0;


% H =
%  
%      -100.6 s + 3908
%   ---------------------
%   s^2 + 26.93 s + 520.1
%  where a = -100.6, b = 3908, c = 36.93, d = 520.1

    a = -100.6; %change values based on tf
    b = 3908; %change values based on tf
    x = 26.93; %change values based on tf
    z = 520.1; %change values based on tf


for n=1:length(time)
    if n==1
        error(1)=vd(1);
        sumerror=error(1);
        deriverror = error(1)/T;
    end
    if n==2
        error(2)=vd(2)-y(1);
        sumerror=sumerror+error(1);
        deriverror = (error(2)-error(1))/T;
    end   
    
    if n>2
        error(n)=vd(n)-y(n-1);
        sumerror=sumerror+error(n);
        deriverror = (error(n)-error(n-1))/T;
    end
    
    % PID values to tune
    kp=0.089; ki=1.42; kd = 0.00112; %change values
    
    c(n)=kp*error(n)+ki*sumerror*T+kd*deriverror;
    if n==1 
        y(1)=b/z*c(1); %change coefficients
    end
    if n==2
        y(2)=(a*(c(2)-c(1))/T+b*c(2)+x/T*y(1))/(x/T+z); %change coefficients
    end
    if n>2
       y(n)=(a*(c(n)-c(n-1))/T+b*c(n)+x/T*y(n-1)+1/T/T*(2*y(n-1)-y(n-2)))/(1/T/T+x/T+z); %change coefficients
    end
end

figure;
plot(time,vd);
hold on 
plot(time,y);
hold on
plot(time, error)
legend('desired velocity','actual velocity','error')
xlabel('time (s)');
ylabel('velocity')
