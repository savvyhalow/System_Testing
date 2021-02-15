clear all;
% close all;

% Select path to folder with data
selpath = uigetdir;
cd(selpath);
% %Select files to be plotted
% filename1 = uigetfile ({'*.txt'},'Accepted Trials Data File');
% filename2 = uigetfile ({'*.txt'},'Rejected Trials Data File');
% filename3 = uigetfile ({'*.csv'},'Optitrack Data File');
% filename4 = uigetfile ({'*.txt'},'SteamVR Data File');
% 
% % Import
% % Trials
% [Trial,WorldTime,MovementStart,MovementEnd,Movementdistance,Velocity,Gain,LengthofTrial,With0orAgainst1,Left0orRight1,Userchosewith0oragainst1,ChoseCorrectly1Correct] = import_accepted_trials(filename1);
% accepted_trials = Trial;
% accepted_numtrials=length(accepted_trials);
% accept_move_start = MovementStart;
% accept_move_end = MovementEnd;
% accept_LR = Left0orRight1;
% [Trial,WorldTime,MovementStart,MovementEnd,Movementdistance,Velocity,Gain,LengthofTrial,With0orAgainst1,Left0orRight1,Userchosewith0oragainst1,ChoseCorrectly1Correct,Reasonforrejection] = importrejectedtrials(filename2);
% rejected_trials = Trial;
% rejected_numtrials=length(rejected_trials);
% %OptiTrack
% [Frame,TimeSeconds,X,Y,Z,X1,Y1,Z1,VarName9] = importopti(filename3);
% opti_x = X;
% opti_y = Y;
% opti_z = Z;
% %SteamVR
% [Trial,WorldTime,TrialTimeSeconds,X,Y,Z,Timebetweenlast6frames] = importsteamvrgameobject(filename4);

plot_data = uigetfile ({'*.mat'},'Tracking Data File');
load(plot_data);

% Align time
for i = 1:size(TimeSeconds)
    TimeSeconds(i) = TimeSeconds(i) - time_sync;
end
% Opti 1 = 20.11
% Opti 2 = 89.3
% Opti 3 = 30.393

% Move starting roll andyaw back to zero
for i = 1:size(opti_y)
    opti_y(i) = opti_y(i) - opti_y(1);
    if opti_y(i) > 180
        opti_y(i) = opti_y(i) - 360;
    end
end
for i = 1:size(opti_z)
    opti_z(i) = opti_z(i) - opti_z(1);
    if opti_z(i) > 180
        opti_z(i) = opti_z(i) - 360;
    end
end

for i = 1:size(X)
    X(i) = X(i) - X(1);
    if X(i) > 180
        X(i) = X(i) - 360;
    end
end
for i = 1:size(Y)
    Y(i) = Y(i) - Y(1);
    if Y(i) > 180
        Y(i) = Y(i) - 360;
    end
end
for i = 1:size(Z)
    Z(i) = Z(i) - Z(1);
    if Z(i) > 180
        Z(i) = Z(i) - 360;
    end
end



midyaw=nanmean(opti_y);

% % Create Plot
% tracking_Data = figure('Name','Tracking Plots');
% hold on
% %Plot trial lines
% for i=1:1:numtrials
%     if Left0orRight1(i)==0
%         line([MovementStart(i) MovementEnd(i)],[midyaw midyaw],'color','r');
%     end
%     if Left0orRight1(i)==1
%         line([MovementStart(i) MovementEnd(i)],[midyaw midyaw],'color','b');
%     end
%     hold on;
% end
% plot(TimeSeconds,abs(opti_x),'-','color',[0.8500, 0.3250, 0.0980],'linewidth',1);               % plot opti pitch?
% plot(TimeSeconds,abs(opti_y),'-','color','k','linewidth',1);                                    % plot opti yaw
% plot(TimeSeconds,abs(opti_z),'-','color','b','linewidth',1);                                    % plot opti roll
% plot(TrialTimeSeconds,abs(X),'-','color',[0, 0.4470, 0.7410],'linewidth',1);                    % plot steamVR PITCH
% plot(TrialTimeSeconds,abs(Y),'-','color','g','linewidth',1);                                    % plot steamVR yaw
% plot(TrialTimeSeconds,abs(Z),'-','color',[0.6350, 0.0780, 0.1840],'linewidth',1);               % plot steamVR roll
% set(gca, 'fontsize',16);
% axis([-10 100 -20 50]);
% legend('Opti Pitch','Opti Yaw','Opti Roll','SteamVR Pitch','SteamVR Yaw','SteamVR Roll');
% xlabel('Time (seconds)');
% ylabel('Rotation (degrees)');

% Calculate RMS of Jitter (precision)


% Create Plot
tracking_Data = figure('Name','Yaw Versus Roll');
hold on
plot(TimeSeconds,abs(opti_y),'-','color','k','linewidth',1);                                    % plot opti yaw
plot(TimeSeconds,abs(opti_z),'-','color','b','linewidth',1);                                    % plot opti roll
plot(TrialTimeSeconds,abs(Y),'-','color','g','linewidth',1);                                    % plot steamVR yaw
plot(TrialTimeSeconds,abs(Z),'-','color',[0.6350, 0.0780, 0.1840],'linewidth',1);               % plot steamVR roll
%Plot trial lines
for i=1:1:accepted_numtrials
    if accept_LR(i)==0
        line([accept_move_start(i) accept_move_end(i)],[midyaw midyaw],'color',	[0.6350, 0.0780, 0.1840]);
    end
    if accept_LR(i)==1
        line([accept_move_start(i) accept_move_end(i)],[midyaw midyaw],'color',	[0, 0, 1]);
    end
    hold on;
end
for i=1:1:rejected_numtrials
    if Left0orRight1(i)==0
        line([MovementStart(i) MovementEnd(i)],[midyaw midyaw],'color',[0.8500, 0.3250, 0.0980]);
    end
    if Left0orRight1(i)==1
        line([MovementStart(i) MovementEnd(i)],[midyaw midyaw],'color',[0.3010, 0.7450, 0.9330]);
    end
    hold on;
end
set(gca, 'fontsize',16);
axis([-10 100 -20 50]);
legend('Opti Yaw','Opti Roll','SteamVR Yaw','SteamVR Roll','Rejected Left Trials', 'Rejected Right Trials','Accepted Left Trials', 'Accepted Right Trials');
xlabel('Time (seconds)');
ylabel('Rotation (degrees)');


% Create Plot
roll_Data = figure('Name','Roll Figure');
hold on
plot(TimeSeconds,abs(opti_z),'-','color','b','linewidth',1);                                         % plot opti roll
plot(TrialTimeSeconds,abs(Z),'-','color',[0.6350, 0.0780, 0.1840],'linewidth',1);                    % plot steamVR roll
%Plot trial lines
for i=1:1:accepted_numtrials
    if accept_LR(i)==0
        line([accept_move_start(i) accept_move_end(i)],[midyaw midyaw],'color',	[0.6350, 0.0780, 0.1840]);
    end
    if accept_LR(i)==1
        line([accept_move_start(i) accept_move_end(i)],[midyaw midyaw],'color',	[0, 0, 1]);
    end
    hold on;
end
for i=1:1:rejected_numtrials
    if Left0orRight1(i)==0
        line([MovementStart(i) MovementEnd(i)],[midyaw midyaw],'color',[0.8500, 0.3250, 0.0980]);
    end
    if Left0orRight1(i)==1
        line([MovementStart(i) MovementEnd(i)],[midyaw midyaw],'color',[0.3010, 0.7450, 0.9330]);
    end
    hold on;
end
set(gca, 'fontsize',16);
axis([-10 100 -20 50]);
legend('Opti Roll','SteamVR Roll');
xlabel('Time (seconds)');
ylabel('Rotation (degrees)');

% % Create Plot
% pitch_Data = figure('Name','Pitch Plots');
% hold on
% plot(TimeSeconds,abs(opti_x),'-','color',[0.8500, 0.3250, 0.0980],'linewidth',1);                                    % plot opti pitch?
% plot(TrialTimeSeconds,abs(X),'-','color',[0, 0.4470, 0.7410],'linewidth',1);                                         % plot steamVR PITCH
% set(gca, 'fontsize',16);
% axis([-10 100 -20 50]);
% legend('Opti Pitch','SteamVR Pitch');
% xlabel('Time (seconds)');
% ylabel('Rotation (degrees)');
% 
% % Create Plot
% yaw_Data = figure('Name','Yaw Plots');
% hold on
% plot(TimeSeconds,abs(opti_y),'-','color','k','linewidth',1);                                          % plot opti yaw
% plot(TrialTimeSeconds,abs(Y),'-','color','g','linewidth',1);                                         % plot steamVR yaw
% set(gca, 'fontsize',16);
% axis([-10 100 -20 50]);
% legend('Opti Yaw','SteamVR Yaw');
% xlabel('Time (seconds)');
% ylabel('Rotation (degrees)');


%%%%%%%%%%%%%%%%%%%%%%

% cd('E:');