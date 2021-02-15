clear all;
close all;
% testIDs = {'Test_1','Test_2','Test_3','Test_4','Test_5','Test_6','Test_7'};
% testID = string(testIDs);
desiredTest = input('Which test would you like to plot?        ');
rb_go = input('Rigidbody vs Rigidbody (1) or Rigidbody vs Gameobject (0)?        ');


%%%%%%%%%%%%%%%%%%%%% File Import %%%%%%%%%%%%%%%%%%%%%
%     selpath = uigetdir;
%     cd(selpath);
%   tracking_data = uigetfile ({testID,'*.mat'},'Tracking Data File');
dirName = strcat('E:\Box Sync\Box Sync\System Testing\Tracking Tests');
dirName = char(dirName);
cd(dirName);
files_list = dir(dirName);
if desiredTest == 1
    tracking_data_1 = regexpi({files_list.name},'Test_1_1.*\.mat', 'match');
    testID_1 = 'Test_1_1';
elseif desiredTest == 2
    tracking_data_1 = regexpi({files_list.name},'Test_2_1.*\.mat', 'match');
    testID_1 = 'Test_2_1';
elseif desiredTest == 3
    tracking_data_1 = regexpi({files_list.name},'Test_3_1.*\.mat', 'match');
    testID_1 = 'Test_3_1';
elseif desiredTest == 4
    tracking_data_1 = regexpi({files_list.name},'Test_4_1.*\.mat', 'match');
    testID_1 = 'Test_4_1';
elseif desiredTest == 5
    tracking_data_1 = regexpi({files_list.name},'Test_5_1.*\.mat', 'match');
    testID_1 = 'Test_5_1';
elseif desiredTest == 6
    tracking_data_1 = regexpi({files_list.name},'Test_6_1.*\.mat', 'match');
    testID_1 = 'Test_6_1';
elseif desiredTest == 7
    tracking_data_1 = regexpi({files_list.name},'Test_7_1.*\.mat', 'match');
    testID_1 = 'Test_7_1';
end

% Import Ground Truth
tracking_data_gt = regexpi({files_list.name},'Test_1_1.*\.mat', 'match');
indx_gt = find(~cellfun(@isempty,tracking_data_gt));
data_file_gt = char(tracking_data_gt{indx_gt});
load(data_file_gt);
% Rename Variables
steamVRYaw_gt = steamVRYaw;
optiGoYaw_gt = optiGoYaw;
steamVRGO_Time_gt = steamVRGO_Time;
optiY_gt = optiY;
optitrackTime_gt = optitrackTime;
% Calculate Root Mean Square (Jitter)
steamVR_RMS_gt = rms(diff(steamVRYaw_gt));
% Calculate RMS (jitter/precision) if test involves OptiTrack
if desiredTest == 1 || desiredTest == 2 || desiredTest == 3 || desiredTest == 4 || desiredTest == 5
    optiGO_RMS_gt = rms(diff(optiGoYaw_gt));
    optiRB_RMS_gt = rms(diff(optiY_gt));
end

% Get TestData
% tracking_data = regexpi({files_list.name},testID,'.*.mat', 'match');
indx_1 = find(~cellfun(@isempty,tracking_data_1));
data_file_1 = char(tracking_data_1{indx_1});
load(data_file_1);

% Rename Variables
steamVRYaw_1 = steamVRYaw;
optiGoYaw_1 = optiGoYaw;
steamVRGO_Time_1 = steamVRGO_Time;
optiY_1 = optiY;
optitrackTime_1 = optitrackTime;


%%%%%%%%%%%%%%%%%%%%% Precision Calculation %%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Test One - Calculate Root Mean Square (Jitter)
steamVR_RMS_1 = rms(diff(steamVRYaw_1))
if desiredTest == 1 || desiredTest == 2 || desiredTest == 3 || desiredTest == 4 || desiredTest == 5    % Check if test involves OptiTrack
    optiGO_RMS_1 = rms(diff(optiGoYaw_1))
    optiRB_RMS_1 = rms(diff(optiY_1))
end

%%%%%%%%%%%%%%%%%%%%% Accuracy Calculation %%%%%%%%%%%%%%%%%%%%%%%%%
if rb_go == 0
    % Downsample ground truth framerate - Rigidbody from Test One current Ground Truth
    OTframerate = 240;  %Optitrack Framerate
    gt_sz = length(optiY_gt);
    idx = 1:length(optiY_gt);
    idx = idx';
    numframes= size(optiY_gt,1)*10/OTframerate;                             % downsample from OTframerate to 90 Hz
    idxq = linspace(min(idx), max(idx), numframes);                         % Interpolation Vector
    idxq = idxq';
    optiY_gt90 = interp1(idx, optiY_gt, idxq, 'linear');                    % Downsampled Vector
    optiTime_gt90 = interp1(idx, optitrackTime_gt, idxq, 'linear');
    opti_GT_RMS90 = rms(diff(optiY_gt90))
    
    rigidbody_sz = length(optiY_gt90);  % Get length of new yaw vector
    gt_yaw = optiY_gt90;
    gt_time = optiTime_gt90;
    
else
    opti_GT_RMS = rms(diff(optiY_gt))
    rigidbody_sz = length(optiY_gt);  % Get length of new yaw vector
    gt_yaw = optiY_gt;
    gt_time = optitrackTime_gt;
end


%%%% This section assumes you're testing one optitrack tracking
if (desiredTest == 1 || desiredTest == 2 || desiredTest == 3 || desiredTest == 4 || desiredTest == 5)
    
    if rb_go == 0 % Gameobject
        yaw_One = optiGoYaw_1;                                  % Yaw 1 to compare
        yaw_One_sz = length(optiGoYaw_1);
    else %Rigidbody
        yaw_One = optiY_1;                                  % Yaw 1 to compare
        yaw_One_sz = length(optiY_1);
    end
    %%%% This section assumes you're testing base station tracking
elseif (desiredTest == 6 || desiredTest == 7)
    yaw_One = steamVRYaw_1;                                  % Yaw 1 to compare
    yaw_One_sz = length(steamVRYaw_1);
end

%%%% Calculation
if rigidbody_sz < yaw_One_sz                            % Comparison yaw Vector is bigger
    test_accuracy = zeros(rigidbody_sz,1);
    for i = 1:rigidbody_sz
        test_accuracy(i) = abs(abs(gt_yaw(i)) - abs(yaw_One(i)));
    end
    test_accuracy = mean(test_accuracy)
    
elseif rigidbody_sz > yaw_One_sz                        % Rigidbody Vector is bigger
    test_accuracy = zeros(yaw_One_sz,1);
    for i = 1:yaw_One_sz
        test_accuracy(i) = abs(abs(gt_yaw(i)) - abs(yaw_One(i)));
    end
    test_accuracy = mean(test_accuracy)
    
elseif rigidbody_sz == yaw_One_sz                       % Vectors are the same length
    test_accuracy = zeros(rigidbody_sz,1);
    for i = 1:rigidbody_sz
        test_accuracy(i) = abs(abs(gt_yaw(i)) - abs(yaw_One(i)));
    end
    test_accuracy = mean(test_accuracy)
end


%%%%%%%%%%%%%%%%%%%%% Plotting %%%%%%%%%%%%%%%%%%%%%%%%%
%%%% This section assumes you're testing one optitrack yaw and one base
%%%% station yaw. See lower sections for other options
if (desiredTest == 1 || desiredTest == 2 || desiredTest == 3 || desiredTest == 4 || desiredTest == 5)
    
    tracking_Data = figure('Name','Tracking Plot');
    axes
    hold on
    plot(gt_time,abs(gt_yaw),'color','g','linewidth',0.5);      % Ground truth    
    if rb_go == 1
        % Rigidbody plotting
        plot(optitrackTime_1,abs(optiY_1),'color','g','linewidth',0.5);
    else
        % GameObject Plotting
        plot(steamVRGO_Time_1,abs(optiGoYaw_1),'color','k','linewidth',1);
        %     plot(steamVRGO_Time_1,abs(steamVRYaw_1),'color','b','linewidth',1);
    end    
    set(gca, 'fontsize',16);
    axis([-5 80 -10 40]);
    if rb_go == 1           % Rigidbody plotting        
        legend('OptiTrack - No Manipulation','Optitrack - Manipulation');        
    else         % GameObject Plotting        
        legend('OptiTrack Rigidbody','Unity GameObject');
    end    
    xlabel('Time (Seconds)');
    ylabel('Yaw Rotation (Degrees)');
    %savefig(newtracking_Data, 'Tracking Plot');
    
    
elseif (desiredTest == 6 || desiredTest == 7)   % Base Station Tracking
    
    tracking_Data = figure('Name','Tracking Plot');
    axes
    hold on
    plot(steamVRGO_Time_1,abs(steamVRYaw_1),'color','b','linewidth',1);
    set(gca, 'fontsize',16);
    axis([-5 80 -10 40]);
    legend('Base Station Tracking');
    xlabel('Time (Seconds)');
    ylabel('Yaw Rotation (Degrees)');
    %savefig(tracking_Data, 'Tracking Plot');
    
end


