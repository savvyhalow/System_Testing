clear all;
close all;
testIDs = {'Test_1_1','Test_2_1','Test_3_1','Test_4_1','Test_5_1','Test_6_1','Test_7_1'};
%Excluded: none
nTest = length(testIDs);
testCount = 0;

for test = 1:nTest
    
     %clearvars -except test testID testIDs nTest steamVRYaw_T1 optiGoYaw_T1 steamVRTime_T1 optiY_T1 optitrackTime_T1 steamVRYaw_T2 optiGoYaw_T2 steamVRTime_T2 optiY_T2 optitrackTime_T2 steamVRYaw_T3 optiGoYaw_T3 steamVRTime_T3 optiY_T3 optitrackTime_T3 steamVRYaw_T4 optiGoYaw_T4 steamVRTime_T4 optiY_T4 optitrackTime_T4 steamVRYaw_T5 optiGoYaw_T5 steamVRTime_T5 optiY_T5 optitrackTime_T5 steamVRYaw_T6 steamVRTime_T6 steamVRYaw_T7 steamVRTime_T7;
    clearvars -except test testID testIDs nTest;
    
    testID = string(testIDs(test));
    
    %Time sync stuff
    % Compensation values taken by comparing unity recording start
    % to optitrack recording start
    if testID == 'Test_1_1'
        testCount = 1
        opti_compensation = 4.135;
        gameobject_compensation = 5.304;
    elseif testID == 'Test_2_1'
        testCount = 2
        opti_compensation = 3.27;
        gameobject_compensation = 4.116;
    elseif testID == 'Test_3_1'
        testCount = 3
        opti_compensation = 3.375;
        gameobject_compensation = 4.307;
    elseif testID == 'Test_4_1'
        testCount = 4
        opti_compensation = 3.199;
        gameobject_compensation = 3.886;
    elseif testID == 'Test_5_1'
        testCount = 5
        opti_compensation = 3.333;
        gameobject_compensation = 4.137;
    elseif testID == 'Test_6_1'
        testCount = 6
        gameobject_compensation = 7.717;
    elseif testID == 'Test_7_1'
        testCount = 7
        gameobject_compensation = 3.357;
    end
    
    
    %%%%%%%%%%%%%%%% Data Import %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find files
    dirName = strcat('E:\Box Sync\Box Sync\System Testing\Tracking Tests\',testID);
    dirName = char(dirName);
    cd(dirName);
    files_list = dir(dirName);
    
    % Import SteamVR Unity GO Data    
    % Search for SteamVR GO Files
    steamVR_search_List = regexpi({files_list.name},'.*SteamVR.*\.txt', 'match');
    steamVR_Index_Number = find(~cellfun(@isempty,steamVR_search_List));
    steamVR_file_Name = char(steamVR_search_List{steamVR_Index_Number});
    %SteamVR Gameobject import
    [WorldTimestamp,RecordingTimestamp,SteamVRGameObjectRoll,SteamVRGameObjectPitch,SteamVRGameObjectYaw,SentTrajectoryYaw] = import_SteamVR_Gameobject(steamVR_file_Name);
    steamVRGO_Time = RecordingTimestamp;
    % Correct for co-ordinate system differences
%     for i = 1:size(SteamVRGameObjectYaw)
    for i = 1:size(SteamVRGameObjectYaw)
        if SteamVRGameObjectYaw(i) > 180
            SteamVRGameObjectYaw(i) = SteamVRGameObjectYaw(i) - 360;
        end
        if SteamVRGameObjectYaw(i) < -180
            SteamVRGameObjectYaw(i) = SteamVRGameObjectYaw(i) + 360;
        end
    end    
    startingSVyaw = SteamVRGameObjectYaw(1);
    for i = 1:size(SteamVRGameObjectYaw)
        SteamVRGameObjectYaw(i) = SteamVRGameObjectYaw(i) - startingSVyaw(1);
    end    
    steamVRYaw = SteamVRGameObjectYaw;


    % Start recording time at zero
    gameobject_compensation = steamVRGO_Time(1);
    for i = 1:size(steamVRGO_Time)
        steamVRGO_Time(i) = steamVRGO_Time(i) - gameobject_compensation;
        %             steamVRTime(i) = steamVRTime(i) - steamVRTime(1);
    end
    
    
    %%%% Conditional Importing for OptiTrack
    if testCount == 1 || testCount == 2 || testCount == 3 || testCount == 4 || testCount == 5
        % Search for Optitrack gameobject file
        Optitrack_Gameobject_search_List = regexpi({files_list.name},'.*Optitrack_Object.*\.txt', 'match');
        Optitrack_Gameobject_Index_Number = find(~cellfun(@isempty,Optitrack_Gameobject_search_List));
        Optitrack_Gameobject_file_Name = char(Optitrack_Gameobject_search_List{Optitrack_Gameobject_Index_Number});
        %Optitrack Gameobject Data import
        [WorldTimestamp,RecordingTimestamp,OptitrackGameObjectRoll,OptitrackGameObjectPitch,OptitrackGameObjectYaw,SentTrajectoryYaw] = import_Optitrack_GameObject(Optitrack_Gameobject_file_Name);
        optiGO_Time = RecordingTimestamp;
        for i = 1:size(OptitrackGameObjectYaw)  % Correct Coordinate System
            if OptitrackGameObjectYaw(i) > 180
                OptitrackGameObjectYaw(i) = OptitrackGameObjectYaw(i) - 360;
            end
            if OptitrackGameObjectYaw(i) < -180
                OptitrackGameObjectYaw(i) = OptitrackGameObjectYaw(i) + 360;
            end
        end
        startingOptiGOyaw = OptitrackGameObjectYaw(1);
        for i = 1:size(OptitrackGameObjectYaw)  % Zero out yaw
            OptitrackGameObjectYaw(i) = OptitrackGameObjectYaw(i) - startingOptiGOyaw;
        end
        optiGoYaw = OptitrackGameObjectYaw;
        
        % Search for opti files
        opti_search_List = regexpi({files_list.name},'.*M.*\.csv', 'match');
        opti_Index_Number = find(~cellfun(@isempty,opti_search_List));
        opti_file_Name = char(opti_search_List{opti_Index_Number});
        [TimeSeconds,X,Y,Z] = import_opti_TimeCompensated(opti_file_Name);
        for i = 1:size(Y)  % Correct Coordinate System
            if Y(i) > 180
                Y(i) = Y(i) - 360;
            end
            if Y(i) < -180
                Y(i) = Y(i) + 360;
            end
          
        end
        startingOptiyaw = Y(1);
        for i = 1:size(Y)  % Zero out yaw
            Y(i) = Y(i) - startingOptiyaw;
        end
%         optiY = abs(Y);
        optiY = Y;
        optitrackTime = TimeSeconds;
        opti_compensation = optitrackTime(1);        
        for i = 1:size(optitrackTime)
            optitrackTime(i) = optitrackTime(i) - opti_compensation;
            %             optitrackTime(i) = optitrackTime(i) - optitrackTime(1);
        end
        
    end
    
    %%%%%%%%%% Save Data %%%%%%%%%%%%%%%%
    
%     if testCount == 1
%         steamVRYaw_T1 = steamVRYaw;
%         optiGoYaw_T1 = optiGoYaw;
%         steamVRTime_T1 = steamVRGO_Time;
%         optiY_T1 = optiY;
%         optitrackTime_T1 = optitrackTime;
%         
%     elseif testCount == 2
%         steamVRYaw_T2 = steamVRYaw;
%         optiGoYaw_T2 = optiGoYaw;
%         steamVRTime_T2 = steamVRGO_Time;
%         optiY_T2 = optiY;
%         optitrackTime_T2 = optitrackTime;
%         
%     elseif testCount == 3
%         steamVRYaw_T3 = steamVRYaw;
%         optiGoYaw_T3 = optiGoYaw;
%         steamVRTime_T3 = steamVRGO_Time;
%         optiY_T3 = optiY;
%         optitrackTime_T3 = optitrackTime;
%         
%     elseif testCount == 4
%         steamVRYaw_T4 = steamVRYaw;
%         optiGoYaw_T4 = optiGoYaw;
%         steamVRTime_T4 = steamVRGO_Time;
%         optiY_T4 = optiY;
%         optitrackTime_T4 = optitrackTime;
%         
%     elseif testCount == 5
%         steamVRYaw_T5 = steamVRYaw;
%         optiGoYaw_T5 = optiGoYaw;
%         steamVRTime_T5 = steamVRGO_Time;
%         optiY_T5 = optiY;
%         optitrackTime_T5 = optitrackTime;
%         
%     elseif testCount == 6
%         steamVRYaw_T6 = steamVRYaw;
%         steamVRTime_T6 = steamVRGO_Time;
%         
%     elseif testCount == 7
%         steamVRYaw_T7 = steamVRYaw;
%         steamVRTime_T7 = steamVRGO_Time;        
%     end
%     
    dirName = strcat('E:\Box Sync\Box Sync\System Testing\Tracking Tests\');
    dirName = char(dirName);
    cd(dirName);
    dataName = strcat(testID,'importedTracking.mat');
    save(dataName);

end

