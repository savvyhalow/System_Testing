clear all;
close all;
testIDs = {'Test_1_1','Test_2_1','Test_3_1','Test_4_1','Test_5_1','Test_6_1','Test_7_1'};
ntests = length(testIDs);

row = 1;
row_90 = 1;

for test = 1:ntests
    
    clearvars -except test testIDs ntests row row_90 a240 p240 a90 p90;
    
    testID = string(testIDs(test));
    
    %%%%%%%%%%%%%%%%%%%%% File Import %%%%%%%%%%%%%%%%%%%%%
    dirName = strcat('E:\Box Sync\Box Sync\System Testing\Tracking Tests');
    dirName = char(dirName);
    cd(dirName);
    files_list = dir(dirName);
    
    if testID == 'Test_1_1'             
        data_file = regexpi({files_list.name},'Test_1_1.*\.mat', 'match');  % regex to find file to import
        currentTest = 1
    elseif testID == 'Test_2_1'
        data_file = regexpi({files_list.name},'Test_2_1.*\.mat', 'match');
        currentTest = 2
    elseif testID == 'Test_3_1'
        data_file = regexpi({files_list.name},'Test_3_1.*\.mat', 'match');
        currentTest = 3
    elseif testID == 'Test_4_1'
        data_file = regexpi({files_list.name},'Test_4_1.*\.mat', 'match');
        currentTest = 4
    elseif testID == 'Test_5_1'
        data_file = regexpi({files_list.name},'Test_5_1.*\.mat', 'match');
        currentTest = 5
    elseif testID == 'Test_6_1'
        data_file = regexpi({files_list.name},'Test_6_1.*\.mat', 'match');
        currentTest = 6
    elseif testID == 'Test_7_1'
        data_file = regexpi({files_list.name},'Test_7_1.*\.mat', 'match');
        currentTest = 7
    end
    
    % Import Ground Truth
    tracking_data_gt = regexpi({files_list.name},'Test_1_1.*\.mat', 'match');
    indx_gt = find(~cellfun(@isempty,tracking_data_gt));
    data_file_gt = char(tracking_data_gt{indx_gt});
    load(data_file_gt);
    steamVRYaw_gt = steamVRYaw;                 % Rename Variables
    optiGoYaw_gt = optiGoYaw;
    steamVRGO_Time_gt = steamVRGO_Time;
    optiY_gt = optiY;
    optitrackTime_gt = optitrackTime;
    
    % Import Test Data
    indx_1 = find(~cellfun(@isempty,data_file));
    data_file_1 = char(data_file{indx_1});
    load(data_file_1);
    steamVRYaw_1 = steamVRYaw;                  % Rename Variables
    optiGoYaw_1 = optiGoYaw;
    steamVRGO_Time_1 = steamVRGO_Time;
    optiY_1 = optiY;
    optitrackTime_1 = optitrackTime;
    
    
    %%%%%%%%%%%%%%%%%%%%% Precision Calculation %%%%%%%%%%%%%%%%%%%%%%%%%
    % Calculate Root Mean Square (Jitter)
    % Ground truth RMS
    GT_steamVRGO_RMS = rms(diff(steamVRYaw_gt))      % Ground Truth - steamvr gameobject
    GT_optiGO_RMS = rms(diff(optiGoYaw_gt))        % Ground Truth - opti gameobject
    GT_RB_RMS = rms(diff(optiY_gt))            % Ground Truth - opti rigidbody
    
    
    % Test RMS
    Test_steamVR_GO_RMS = rms(diff(steamVRYaw_1))
    if currentTest == 1 || currentTest == 2 || currentTest == 3 || currentTest == 4 || currentTest == 5    % Check if test involves OptiTrack
        Test_optiGO_RMS = rms(diff(optiGoYaw_1))
        Test_optiRB_RMS = rms(diff(optiY_1))
    end
    
    %%%%%%%%%%%%%%%%%%%%% Accuracy Calculation %%%%%%%%%%%%%%%%%%%%%%%%%
    
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
    GT_opti_RMS90 = rms(diff(optiY_gt90))
    
    % Downsampled vector for accuracy calculation
    rigidbody_sz_90 = length(optiY_gt90);  % Get length of new yaw vector
    gt_yaw_90 = optiY_gt90;
    gt_time_90 = optiTime_gt90;
    
    % Unchanged vector for accuracy calculation
    rigidbody_sz = length(optiY_gt);
    gt_yaw = optiY_gt;
    gt_time = optitrackTime_gt;
    
    
    %%%% This section assumes you're testing one optitrack tracking
    if (currentTest == 1 || currentTest == 2 || currentTest == 3 || currentTest == 4 || currentTest == 5)
        yaw_One = optiY_1;
        yaw_One_sz = length(optiY_1);
        yaw_One_90 = optiGoYaw_1;                                  % Yaw 1 to compare
        yaw_One_sz_90 = length(optiGoYaw_1);
        %%%% This section assumes you're testing base station tracking
    elseif (currentTest == 6 || currentTest == 7)
        yaw_One_90 = steamVRYaw_1;                                  % Yaw 1 to compare
        yaw_One_sz_90 = length(steamVRYaw_1);
    end
    
    %%%% 240 FPS Calculation
    if (currentTest == 1 || currentTest == 2 || currentTest == 3 || currentTest == 4 || currentTest == 5)
        if rigidbody_sz < yaw_One_sz                            % Comparison yaw Vector is bigger
            test_accuracy = zeros(rigidbody_sz,1);
            for i = 1:rigidbody_sz
                test_accuracy(i) = abs(gt_yaw(i)) - abs(yaw_One(i));
            end
            test_accuracy = mean(test_accuracy)
            
        elseif rigidbody_sz > yaw_One_sz                        % Rigidbody Vector is bigger
            test_accuracy = zeros(yaw_One_sz,1);
            for i = 1:yaw_One_sz
                test_accuracy(i) = abs(gt_yaw(i)) - abs(yaw_One(i));
            end
            test_accuracy = mean(test_accuracy)
            
        elseif rigidbody_sz == yaw_One_sz                       % Vectors are the same length
            test_accuracy = zeros(rigidbody_sz,1);
            for i = 1:rigidbody_sz
                test_accuracy(i) = abs(gt_yaw(i)) - abs(yaw_One(i));
            end
            test_accuracy = mean(test_accuracy)
        end
        
        % save to matrix
        a240(row,:)=[test_accuracy];
        p240(row,:)=[GT_RB_RMS Test_optiRB_RMS];
        
        row = row + 1;
        
    end
    
    
    %%%% 90 FPS Calculation
    if rigidbody_sz_90 < yaw_One_sz_90                            % Comparison yaw Vector is bigger
        test_accuracy_90 = zeros(rigidbody_sz_90,1);
        for i = 1:rigidbody_sz_90
            test_accuracy_90(i) = abs(gt_yaw_90(i)) - abs(yaw_One_90(i));
        end
        test_accuracy_90 = mean(test_accuracy_90)
        
    elseif rigidbody_sz_90 > yaw_One_sz_90                        % Rigidbody Vector is bigger
        test_accuracy_90 = zeros(yaw_One_sz_90,1);
        for i = 1:yaw_One_sz_90
            test_accuracy_90(i) = abs(gt_yaw_90(i)) - abs(yaw_One_90(i));
        end
        test_accuracy_90 = mean(test_accuracy_90)
        
    elseif rigidbody_sz_90 == yaw_One_sz_90                       % Vectors are the same length
        test_accuracy_90 = zeros(rigidbody_sz_90,1);
        for i = 1:rigidbody_sz_90
            test_accuracy_90(i) = abs(gt_yaw_90(i)) - abs(yaw_One_90(i));
        end
        test_accuracy_90 = mean(test_accuracy_90)
    end
    
    % save to matrix
    a90(row_90,:)=[test_accuracy_90];
    if currentTest == 1 || currentTest == 2 || currentTest == 3 || currentTest == 4 || currentTest == 5    % Check if test involves OptiTrack
        p90(row_90,:)=[GT_opti_RMS90 GT_optiGO_RMS Test_steamVR_GO_RMS Test_optiGO_RMS ];
    else
        p90(row_90,:)=[GT_opti_RMS90 GT_optiGO_RMS Test_steamVR_GO_RMS 0];
    end
    
    row_90 = row_90 + 1;
    
    %%%%%%%%%%%%%%%%%%%%% Plotting %%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% This section assumes you're testing one optitrack yaw and one base
    %%%% station yaw. See lower sections for other options
    if (currentTest == 1 || currentTest == 2 || currentTest == 3 || currentTest == 4 || currentTest == 5)
        
        tracking_plot = figure('Name','Tracking Plot - 240 FPS');
        axes
        hold on
        plot(gt_time,abs(gt_yaw),'color','k','linewidth',0.5);              % Ground truth
        plot(optitrackTime_1,abs(optiY_1),'color','b','linewidth',0.5);     % Rigidbody
        set(gca, 'fontsize',16);
        axis([-5 80 -10 40]);
        legend('Ground Truth','Test');
        xlabel('Time (Seconds)');
        ylabel('Yaw Rotation (Degrees)');
        
        figName = strcat(testID, '_Tracking_Plot.fig');
        savefig(figName);
        
        tracking_plot_2 = figure('Name','Tracking Plot - 90 FPS');
        axes
        hold on
        plot(gt_time_90,abs(gt_yaw_90),'color','k','linewidth',0.5);      % Ground truth
        plot(optitrackTime_1,abs(optiY_1),'color','b','linewidth',0.5);   % Gameobject
        set(gca, 'fontsize',16);
        axis([-5 80 -10 40]);
        legend('Ground Truth','Test');
        xlabel('Time (Seconds)');
        ylabel('Yaw Rotation (Degrees)');
        
        figName_90 = strcat(testID, '_Tracking_Plot.fig');
        savefig(figName_90);
        
        
    elseif (currentTest == 6 || currentTest == 7)   % Base Station Tracking
        tracking_plot = figure('Name','Tracking Plot');
        axes
        hold on
        plot(gt_time_90,abs(gt_yaw_90),'color','k','linewidth',0.5);      % Ground truth
        plot(steamVRGO_Time_1,abs(steamVRYaw_1),'color','b','linewidth',1);
        set(gca, 'fontsize',16);
        axis([-5 80 -10 40]);
        legend('Base Station Tracking');
        xlabel('Time (Seconds)');
        ylabel('Yaw Rotation (Degrees)');
        
        figName = strcat(testID, '_Tracking_Plot.fig');
        savefig(figName);
        
    end
    
    data_name = strcat('Prec_acc_Data.mat');
    save(data_name,'a90','p90','a240','p240');
    
    
end




