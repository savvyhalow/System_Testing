clear all;
close all;
% testIDs = {'Test_1','Test_2','Test_3','Test_4','Test_5','Test_6','Test_7'};
% testID = string(testIDs);

test_One = input('Test One?        ');
test_Two = input('Test Two?        ');
% if desiredTest == 1
%     testID = 'Test_1_1';
% elseif desiredTest == 2
%     testID = 'Test_2_1';
% elseif desiredTest == 3
%     testID = 'Test_3_1';
% elseif desiredTest == 4
%     testID = 'Test_4_1';
% elseif desiredTest == 5
%     testID = 'Test_5_1';
% elseif desiredTest == 6
%     testID = 'Test_6_1';
% elseif desiredTest == 7
%     testID = 'Test_7_1';
% end

%%%%%%%%%%%%% File Import %%%%%%%%%%%%%%
%     selpath = uigetdir;
%     cd(selpath);
%   tracking_data = uigetfile ({testID,'*.mat'},'Tracking Data File');
dirName = strcat('E:\Box Sync\Box Sync\System Testing\Tracking Tests');
dirName = char(dirName);
cd(dirName);
files_list = dir(dirName);
if test_One == 1
    tracking_data_1 = regexpi({files_list.name},'Test_1_1.*\.mat', 'match');
    testID_1 = 'Test_1_1';
elseif test_One == 2
    tracking_data_1 = regexpi({files_list.name},'Test_2_1.*\.mat', 'match');
    testID_1 = 'Test_2_1';
elseif test_One == 3
    tracking_data_1 = regexpi({files_list.name},'Test_3_1.*\.mat', 'match');
    testID_1 = 'Test_3_1';
elseif test_One == 4
    tracking_data_1 = regexpi({files_list.name},'Test_4_1.*\.mat', 'match');
    testID_1 = 'Test_4_1';
elseif test_One == 5
    tracking_data_1 = regexpi({files_list.name},'Test_5_1.*\.mat', 'match');
    testID_1 = 'Test_5_1';
elseif test_One == 6
    tracking_data_1 = regexpi({files_list.name},'Test_6_1.*\.mat', 'match');
    testID_1 = 'Test_6_1';
elseif test_One == 7
    tracking_data_1 = regexpi({files_list.name},'Test_7_1.*\.mat', 'match');
    testID_1 = 'Test_7_1';
end

if test_Two == 1
    tracking_data_2 = regexpi({files_list.name},'Test_1_1.*\.mat', 'match');
    testID_2 = 'Test_1_1';
elseif test_Two == 2
    tracking_data_2 = regexpi({files_list.name},'Test_2_1.*\.mat', 'match');
    testID_2 = 'Test_2_1';
elseif test_Two == 3
    tracking_data_2 = regexpi({files_list.name},'Test_3_1.*\.mat', 'match');
    testID_2 = 'Test_3_1';
elseif test_Two == 4
    tracking_data_2 = regexpi({files_list.name},'Test_4_1.*\.mat', 'match');
    testID_2 = 'Test_4_1';
elseif test_Two == 5
    tracking_data_2 = regexpi({files_list.name},'Test_5_1.*\.mat', 'match');
    testID_2 = 'Test_5_1';
elseif test_Two == 6
    tracking_data_2 = regexpi({files_list.name},'Test_6_1.*\.mat', 'match');
    testID_2 = 'Test_6_1';
elseif test_Two == 7
    tracking_data_2 = regexpi({files_list.name},'Test_7_1.*\.mat', 'match');
    testID_2 = 'Test_7_1';
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
if test_One == 1 || test_One == 2 || test_One == 3 || test_One == 4 || test_One == 5
    optiGO_RMS_gt = rms(diff(optiGoYaw_gt));
    optiRB_RMS_gt = rms(diff(optiY_gt));
end

% Get Test One Data
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

% Calculate Root Mean Square (Jitter)
steamVR_RMS_1 = rms(diff(steamVRYaw_1))
% Calculate RMS (jitter/precision) if test involves OptiTrack
if test_One == 1 || test_One == 2 || test_One == 3 || test_One == 4 || test_One == 5
    optiGO_RMS_1 = rms(diff(optiGoYaw_1))
    optiRB_RMS_1 = rms(diff(optiY_1))
end

% Get Test Two Data
% tracking_data = regexpi({files_list.name},testID,'.*.mat', 'match');
indx_2 = find(~cellfun(@isempty,tracking_data_2));
data_file_2 = char(tracking_data_2{indx_2});
load(data_file_2);

% Rename Variables
steamVRYaw_2 = steamVRYaw;
optiGoYaw_2 = optiGoYaw;
steamVRGO_Time_2 = steamVRGO_Time;
optiY_2 = optiY;
optitrackTime_2 = optitrackTime;

% Calculate Root Mean Square (Jitter)
steamVR_RMS_2 = rms(diff(steamVRYaw_2))
% Calculate RMS (jitter/precision) if test involves OptiTrack
if test_Two == 1 || test_Two == 2 || test_Two == 3 || test_Two == 4 || test_Two == 5
    optiGO_RMS_2 = rms(diff(optiGoYaw_2))
    optiRB_RMS_2 = rms(diff(optiY_2))
end




%%%%%%%%%%%%%%%%%%%%% Plotting %%%%%%%%%%%%%%%%%%%%%%%%%
if (test_One == 1 || test_One == 2 || test_One == 3 || test_One == 4 || test_One == 5) && (test_Two == 6 || test_Two == 7)
    
    %Optitrack Framerate
    OTframerate = 240;
    % Using Rigidbody from Test One as Ground Truth
    gt_sz = length(optiY_gt);
    % Downsample before saving
    %     idx = 1:size(optiY_gt,1); % Index
    idx = 1:length(optiY_gt); % Index
    idx = idx';
    numframes= size(optiY_gt,1)*10/OTframerate;                             % downsample from OTframerate to 90 Hz
    idxq = linspace(min(idx), max(idx), numframes);                         % Interpolation Vector
    idxq = idxq';
    % for i=1:1:numtrials
    %     for i=1:gt_sz
    %         optiY_gt90(i,:) = interp1(idx, optiY_gt(i,:), idxq, 'linear');       % Downsampled Vector
    %         optiTime_gt90(i,:) = interp1(idx, optitrackTime_gt(i,:), idxq, 'linear');
    %     end
    
    optiY_gt90 = interp1(idx, optiY_gt, idxq, 'linear');       % Downsampled Vector
    optiTime_gt90 = interp1(idx, optitrackTime_gt, idxq, 'linear');
    
    optiGO_RMS90_gt = rms(diff(optiY_gt90))
    % Using Rigidbody from Test One as Ground Truth
    rigidbody_sz = length(optiY_gt90);
        
    % Yaw 1 to compare
    yaw_One_sz = length(optiGoYaw_1);
    
    % Yaw 2 to Compare
    yaw_Two_sz = length(steamVRYaw_2);
    
    
    % Compare Test One
    if rigidbody_sz < yaw_Two_sz
        t1_accuracy = zeros(rigidbody_sz,1);
        for i = 1:rigidbody_sz
            t1_accuracy(i) = abs(abs(optiY_gt(i)) - abs(optiGoYaw_1(i)));
        end
        t1_accuracy = mean(t1_accuracy)
        % Rigidbody Vector is bigger
    elseif rigidbody_sz > yaw_Two_sz
        t1_accuracy = zeros(yaw_Two_sz,1);
        for i = 1:yaw_Two_sz
            t1_accuracy(i) = abs(abs(optiY_gt(i)) - abs(optiGoYaw_1(i)));
        end
        t1_accuracy = mean(t1_accuracy)
        % Vectors are the same length
    elseif rigidbody_sz == yaw_Two_sz
        t1_accuracy = zeros(rigidbody_sz,1);
        for i = 1:rigidbody_sz
            t1_accuracy(i) = abs(abs(optiY_gt(i)) - abs(optiGoYaw_1(i)));
        end
        t1_accuracy = mean(t1_accuracy)
    end
    
%         acc_test = zeros(rigidbody_sz,1);
%         for i = 1:rigidbody_sz - 1
%             acc_test(i) = abs(abs(optiY_gt(i)) - abs(optiY_gt(i)));
%         end
%         acc_test = mean(acc_test)

    
    % Compare Test Two
    % Test Yaw Vector is bigger
    if rigidbody_sz < yaw_Two_sz
        t2_accuracy = zeros(rigidbody_sz,1);
        for i = 1:rigidbody_sz - 1
            t2_accuracy(i) = abs(abs(optiY_gt(i)) - abs(steamVRYaw_2(i)));
        end
        t2_accuracy = nanmean(t2_accuracy)
        
        % Rigidbody Vector is bigger
    elseif rigidbody_sz > yaw_Two_sz
        t2_accuracy = zeros(yaw_Two_sz,1);
        for i = 1:yaw_Two_sz
            t2_accuracy(i) = abs(abs(optiY_gt(i)) - abs(steamVRYaw_2(i)));
        end
        t2_accuracy = nanmean(t2_accuracy)
        % Vectors are the same length
    elseif rigidbody_sz == yaw_Two_sz
        t2_accuracy = zeros(rigidbody_sz,1);
        for i = 1:rigidbody_sz
            t2_accuracy(i) = abs(abs(optiY_gt(i)) - abs(steamVRYaw_2(i)));
        end
        t2_accuracy = nanmean(t2_accuracy)
    end
    
    
    
    
    tracking_Data = figure('Name','Tracking Plot');
    axes
    hold on
    plot(optiTime_gt90,abs(optiY_gt90),'color',[0.4660 0.6740 0.1880],'linewidth',2);
    %       plot(optitrackTime_gt,abs(optiY_gt),'color','g','linewidth',0.5);
    
    plot(steamVRGO_Time_1,abs(optiGoYaw_1),'color','k','linewidth',1);
    plot(steamVRGO_Time_2,abs(steamVRYaw_2),'color','b','linewidth',1);
    
    set(gca, 'fontsize',16);
    axis([-5 80 -10 40]);
    %         legend('OptiTrack Tracking: Unity GameObject - SteamVR','Unity GameObject - Optitrack','Optitrack - Rigidbody');
    legend('OptiTrack Rigidbody','OptiTrack Tracking','Base Station Tracking');
    xlabel('Time (Seconds)');
    ylabel('Yaw Rotation (Degrees)');
    
    %This for saving plots with no latency - latency is compensated for
    %savefig(newtracking_Data, 'Tracking Plot without latency');
    
    % elseif test == 6 || test == 7
    %
    %     tracking_Data = figure('Name','Tracking Plot');
    %     axes
    %     hold on
    %     plot(steamVRGO_Time,abs(steamVRYaw),'color','r','linewidth',1);
    %     set(gca, 'fontsize',16);
    %     axis([0 60 -100 100]);
    %     legend('Unity GameObject - SteamVR');
    %     xlabel('Time (Seconds)');
    %     ylabel('Yaw Rotation (Degrees)');
    %
    %     %Cannot compensate for latency here since we can't know what it is
    %     %savefig(tracking_Data, 'Tracking Plot with latency');
    
end


