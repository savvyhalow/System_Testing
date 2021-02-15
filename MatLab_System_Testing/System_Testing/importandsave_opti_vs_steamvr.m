clear all;
close all;
% Select path to folder with data
selpath = uigetdir;
cd(selpath);

%Select files to be plotted
filename1 = uigetfile ({'*.txt'},'Accepted Trials Data File');
filename2 = uigetfile ({'*.txt'},'Rejected Trials Data File');
filename3 = uigetfile ({'*.csv'},'Optitrack Data File');
filename4 = uigetfile ({'*.txt'},'SteamVR Data File');

% Import
% Trials
[Trial,WorldTime,MovementStart,MovementEnd,Movementdistance,Velocity,Gain,LengthofTrial,With0orAgainst1,Left0orRight1,Userchosewith0oragainst1,ChoseCorrectly1Correct] = import_accepted_trials(filename1);
accepted_trials = Trial;
accepted_numtrials=length(accepted_trials);
accept_move_start = MovementStart;
accept_move_end = MovementEnd;
accept_LR = Left0orRight1;
[Trial,WorldTime,MovementStart,MovementEnd,Movementdistance,Velocity,Gain,LengthofTrial,With0orAgainst1,Left0orRight1,Userchosewith0oragainst1,ChoseCorrectly1Correct,Reasonforrejection] = importrejectedtrials(filename2);
rejected_trials = Trial;
rejected_numtrials=length(rejected_trials);
%OptiTrack
[Frame,TimeSeconds,X,Y,Z,X1,Y1,Z1,VarName9] = importopti(filename3);
opti_x = X;
opti_y = Y;
opti_z = Z;
%SteamVR
[Trial,WorldTime,TrialTimeSeconds,X,Y,Z,Timebetweenlast6frames] = importsteamvrgameobject(filename4);

time_sync = 31.333;

% Opti 1 = 20.11
% Opti 2 = 89.3
% Opti 3 = 31.333
% opti 4 = 32.489

save('imported_opti_vs_steam_3.mat');

