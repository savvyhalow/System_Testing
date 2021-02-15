close all;
clear all;

% % Find Prec/Acc Data
% dirName = strcat('E:\Box Sync\Box Sync\System Testing\Tracking Tests');
% dirName = char(dirName);
% cd(dirName);
% A = readtable('A.xlsx');
% A = A{:,:};
% P = readtable('P.xlsx');
% P = P{:,:};


%%%%%%% 90 FPS - GameObjects %%%%%%%
% Opti vs Basestations
% OptiTrack Tracking - NoMS
% OptiTrack Tracking - MS
% Base Station Tracking - NoMS
% Base Station Tracking - MS

A_90 = [-2.06486061487706 -2.04566669327918 -2.20220850884510 -2.22716009339902];
P_90 = [0.1193	0.0897	0.1183	0.118];
C_90 = {'Opti-NoMS', 'Opti-MS', 'BaseS-NoMS', 'BaseS-NoMS'};

% ANOVA
S=[1 1 1 1];
F1=[1 1 2 2]; % Tracking: 1 = OptiTrack, 2 = Base Station
F2=[1 2 1 2]; % Manipulation: 1 = No Motion Smoothing, 2 = Motion Smoothing

precision_stats_90 = rm_anova2(P_90(:),S,F1,F2,{'Opti_Base','NoMS_MS'})
accuracy_stats_90 = rm_anova2(A_90(:),S,F1,F2,{'Opti_Base','NoMS_MS'})
X1 = [1 2 3 4];


% Plot Precision Values
figure('name','Precision plot');
hold on
% boxplot(P,C,'symbol','');
plot(X1,P_90(:),'o','MarkerSize',10,'MarkerEdgeColor',[0.4,0.4,0.4],'MarkerFaceColor',[0.4,0.4,0.4]);
set(gca, 'fontsize',15);
axis([-0.25 5 0.08 0.13]);
xticks([1 2 3 4]);
xtickangle(45);
xticklabels({'Opti - NoMS','Opti - MS', 'BaseStat - NoMS','BaseStat - MS'})
ylabel('Precision (RMS)');
% savefig('Precision');

% Plot Accuracy Values
figure('name','Accuracy Plot');
hold on
% boxplot(A,C,'symbol','');
plot(X1,A_90(:),'o','MarkerSize',10,'MarkerEdgeColor',[0.4,0.4,0.4],'MarkerFaceColor',[0.4,0.4,0.4]);
set(gca, 'fontsize',15);
axis([-0.25 5 -2.5 -2]);
xticks([1 2 3 4]);
xtickangle(45);
xticklabels({'Opti - NoMS','Opti - MS', 'BaseStat - NoMS','BaseStat - MS'})
ylabel('Accuracy (Avg Degree Offset)');
% savefig('Accuracy');



%%%%%%%% 240 FPS Opti vs Opti %%%%%%%%%%%

% Motion Smoothing and Forward Prediction

A_240 = [0 -0.241360614480543 0 0.0497537778024173];
P_240 = [0.0521	0.0324	0.0521	0.0549];
C_240 = {'NoMS', 'MS', 'NoFwdP', 'FwdP'};

% ANOVA
S2=[1 1 1 1];
F3=[1 1 2 2]; % Motion Smoothing: 1 = Off, 2 = On
F4=[1 2 1 2]; % Forward Prediction: 1 = Off, 2 = On

precision_stats_240 = rm_anova2(P_90(:),S2,F3,F4,{'NoMS_MS','NoFwP_FwP'})
accuracy_stats_240 = rm_anova2(A_90(:),S2,F3,F4,{'NoMS_MS','NoFwP_FwP'})

X2 = [1 2 3 4];

% Plot Precision Values
figure('name','Precision 240 FPS');
hold on
% boxplot(P,C,'symbol','');
plot(X2,P_240(:),'o','MarkerSize',10,'MarkerEdgeColor',[0.4,0.4,0.4],'MarkerFaceColor',[0.4,0.4,0.4]);
set(gca, 'fontsize',15);
axis([-0.25 5 0.02 0.06]);
xticks([1 2 3 4]);
xtickangle(45);
xticklabels({'NoMS','MS', 'NoFwdP','FwdP'})
ylabel('Precision (RMS)');
% savefig('Precision');

% Plot Accuracy Values
figure('name','Accuracy 240 FPS');
hold on
% boxplot(A,C,'symbol','');
plot(X2,A_240(:),'o','MarkerSize',10,'MarkerEdgeColor',[0.4,0.4,0.4],'MarkerFaceColor',[0.4,0.4,0.4]);
set(gca, 'fontsize',15);
axis([-0.25 5 -1 3]);
xticks([1 2 3 4]);
xtickangle(45);
xticklabels({'NoMS','MS', 'NoFwdP','FwdP'})
ylabel('Accuracy (Avg Degree Offset)');
% savefig('Accuracy');







