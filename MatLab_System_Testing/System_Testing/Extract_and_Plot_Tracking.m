clear all;
close all;

testIDs = {'Test_1','Test_2','Test_3','Test_4','Test_5','Test_6','Test_7'};
%Excluded: none 
nTest = length(testIDs);

for test = 1:nTest
    
    %clear variables
    clearvars -except test testIDs cnTest;    
    
    testID = string(testIDs(test));
    
    
    
    %%%%%%%%%%%%% SteamVR Unity GameObject File Import %%%%%%%%%%%%%%
    
    % Find opti and trial files
    %dirName = strcat('D:\Conflict Detection\Tracking Test\',testID);
    dirName = strcat('E:\Box Sync\Box Sync\System Testing\Tracking Tests\',testID);
    dirName = char(dirName);
    cd(dirName);
    files_list = dir(dirName);
    
    % Search SteamVR Files
    steamVR_search_List = regexpi({files_list.name},'.*SteamVR.*\.txt', 'match');
    steamVR_Index_Number = find(~cellfun(@isempty,steamVR_search_List));
    steamVR_file_Name = char(steamVR_search_List{steamVR_Index_Number});
    
    %SteamVR Gameobject import
    [WorldTimestamp,RecordingTimestamp,SteamVRGameObjectRoll,SteamVRGameObjectPitch,SteamVRGameObjectYaw,SentTrajectoryYaw] = import_SteamVR_Gameobject(steamVR_file_Name);
    
    steamVRTime = WorldTimestamp;
    steamVRRecordingTime = RecordingTimestamp;
    sentVRYaw = SentTrajectoryYaw;              %This variable is currently unused
    
    for i = 1:size(SteamVRGameObjectYaw)
        SteamVRGameObjectYaw(i) = SteamVRGameObjectYaw(i) - SteamVRGameObjectYaw(1);
    end
    for i = 1:size(SteamVRGameObjectYaw)
        if SteamVRGameObjectYaw(i) > 180
            SteamVRGameObjectYaw(i) = SteamVRGameObjectYaw(i) - 360;
        end
    end
    
    %Convert SteamVR world timestamps to minutes/seconds
    Datestring = datestr(steamVRTime);
    steamVRTime_str = Datestring(1,:);
    expression3 = ':';
    expression4 = ':';
    expression5 = '.';
    
    steamVRTime_splitstr = regexp(steamVRTime_str,expression3,'split');
    steamVRTime_time_Minutes=steamVRTime_splitstr{1,2};
    steamVRTime_num_Minutes=str2num(steamVRTime_time_Minutes);
    
    %Convert to seconds
    if steamVRTime_num_Minutes ~= 0
        steamVRTime_num_Minutes=steamVRTime_num_Minutes*60;
    end
    
    
    steamVRTime_splitstr2 = regexp(steamVRTime_splitstr{1,3},expression4,'split');
    steamVRTime_time_Seconds=steamVRTime_splitstr2{1,1};
    steamVRTime_num_Seconds=str2num(steamVRTime_time_Seconds);
    
    unity_milliseconds=input('Unity Milliseconds?');
    unity_milliseconds = unity_milliseconds/1000;
    
    
    %Add times to get time recording start in seconds
    steamVRTime_start_time= steamVRTime_num_Minutes+ steamVRTime_num_Seconds + unity_milliseconds;
    
    % Calculate Root Mean Square (Jitter)
    steamVR_RMS = rms(SteamVRGameObjectYaw)
    
    
        
    
    %%%%%%%%%%%%%%%%%% OptiTrack and Opti GameObject Importing %%%%%%%%%%%%%%%%%%%%%%%%%%
    if testID == 'Test_1' || testID == 'Test_2' || testID == 'Test_3' || testID == 'Test_4' || testID == 'Test_5'
        
        % Search for SteamVR Files
        steamVR_search_List = regexpi({files_list.name},'.*SteamVR.*\.txt', 'match');
        steamVR_Index_Number = find(~cellfun(@isempty,steamVR_search_List));
        steamVR_file_Name = char(steamVR_search_List{steamVR_Index_Number});
        
        % Search for Optitrack Unity Gameobject file
        Optitrack_Gameobject_search_List = regexpi({files_list.name},'.*Optitrack_Object.*\.txt', 'match');
        Optitrack_Gameobject_Index_Number = find(~cellfun(@isempty,Optitrack_Gameobject_search_List));
        Optitrack_Gameobject_file_Name = char(Optitrack_Gameobject_search_List{Optitrack_Gameobject_Index_Number});
        
        %Optitrack Gameobject import
        [WorldTimestamp,RecordingTimestamp,OptitrackGameObjectRoll,OptitrackGameObjectPitch,OptitrackGameObjectYaw,SentTrajectoryYaw] = import_Optitrack_GameObject(Optitrack_Gameobject_file_Name);
        
        optitrackTime = WorldTimestamp;
        optitrackRecordingTime = RecordingTimestamp;
        optitrackSentYaw = SentTrajectoryYaw;              %This variable is currently unused
        
        for i = 1:size(OptitrackGameObjectYaw)
            OptitrackGameObjectYaw(i) = OptitrackGameObjectYaw(i) - OptitrackGameObjectYaw(1);
        end
        for i = 1:size(OptitrackGameObjectYaw)
            if OptitrackGameObjectYaw(i) > 180
                OptitrackGameObjectYaw(i) = OptitrackGameObjectYaw(i) - 360;
            end
        end        
        
        % Search for opti files
        opti_search_List = regexpi({files_list.name},'.*M.*\.csv', 'match');
        opti_Index_Number = find(~cellfun(@isempty,opti_search_List));
        opti_file_Name = char(opti_search_List{opti_Index_Number});
        
        % Optitrack Recording
        [TimeSeconds,X,Y,Z] = import_Optitrack_Rotational_Data(opti_file_Name);
        %Y = Y(~isnan(Y));
        
        %Convert Optitrack Recording start time to minutes/seconds
        opti_str = opti_file_Name;
        expression = '\.';
        expression2 = ' ';
        
        %split the filename based on the time in the filename
        opti_splitstr = regexp(opti_str,expression,'split');
        optitrack_time_Minutes=opti_splitstr{1,2};
        opti_num_Minutes=str2num(optitrack_time_Minutes);
        
        %Convert to seconds
        if opti_num_Minutes ~= 0
            opti_num_Minutes=opti_num_Minutes*60;
        end
        
        opti_splitstr2 = regexp(opti_splitstr{1,3},expression2,'split');
        optitrack_time_Seconds=opti_splitstr2{1,1};
        opti_num_Seconds=str2num(optitrack_time_Seconds);
        
        optitrack_milliseconds = input('Optitrack Milliseconds?');
        optitrack_milliseconds = optitrack_milliseconds/1000;
        
        %Add times to get time recording start in seconds
        optitrack_seconds=opti_num_Minutes+opti_num_Seconds;
        
        optitrack_start_time =optitrack_seconds + optitrack_milliseconds;
        
        %To align seperate recordings
        %Subtract seconds from each
        opti_vs_trial_time_difference= abs(optitrack_start_time - steamVRTime_start_time);
        
        %Set new time to match optitrack
        newOptitrackTimeSeconds=TimeSeconds+opti_vs_trial_time_difference;
        
        
        %Calculate RMS (jitter/precision)
        optiGO_RMS = rms(OptitrackGameObjectYaw)
        optiRB_RMS = rms(Y)
        
        
    end
    
    
    
    %%%%%%%%%%%%%%%%%%%%% Plotting %%%%%%%%%%%%%%%%%%%%%%%%%
    if testID == 'Test_1' || testID == 'Test_2' || testID == 'Test_3' || testID == 'Test_4' || testID == 'Test_5'
        
        tracking_Data = figure('Name','Individual Tracking Plots');
        axes
        hold on
        %Plot the steamVR gameobject
        plot(steamVRRecordingTime,abs(SteamVRGameObjectYaw),'color','r','linewidth',1);
        %plot the optitrack gameobject
        plot(steamVRRecordingTime,abs(OptitrackGameObjectYaw),'color','b','linewidth',1);
        %plot the optitrack recording
        plot(newOptitrackTimeSeconds,abs(Y),'color','k','linewidth',1);
        set(gca, 'fontsize',16);
        axis([0 60 -100 100]);
        legend('SteamVR GameObject','Optitrack GameObject','Optitrack Rigidbody');
        xlabel('Time');
        ylabel('Position');
        

        %The following is all latency compensating stuff
        steamVR_latency_milliseconds=input('Unity Latency?');   %Comment out this line if you want latency
        steamVR_latency_milliseconds = steamVR_latency_milliseconds/100;
        
        newSteamVRTime = steamVRRecordingTime - steamVR_latency_milliseconds;
        
        newtracking_Data = figure('Name','Latency Compensated Individual Tracking Plots');
        axes
        hold on
        %Plot the steamVR gameobject
        plot(newSteamVRTime,abs(SteamVRGameObjectYaw),'color','r','linewidth',1);
        %plot the optitrack gameobject
        plot(newSteamVRTime,abs(OptitrackGameObjectYaw),'color','b','linewidth',1);
        %plot the optitrack recording
        plot(newOptitrackTimeSeconds,abs(Y),'color','k','linewidth',1);
        set(gca, 'fontsize',16);
        axis([0 60 -50 100]);
        legend('SteamVR GameObject','Optitrack GameObject','Optitrack Rigidbody');
        xlabel('Time');
        ylabel('Position');
        
        
        %This line is for saving plots with latency
        %savefig(tracking_Data, 'Tracking Plot with latency');
        
        %This for saving plots with no latency - latency is compensated for
        savefig(newtracking_Data, 'Tracking Plot without latency');
        
        
    elseif testID == 'Test_6' || testID == 'Test_7'
        
        tracking_Data = figure('Name','Tracking Plots');
        axes
        hold on
        %Plot the steamVR gameobject
        plot(steamVRRecordingTime,abs(SteamVRGameObjectYaw),'color','r','linewidth',1);
        set(gca, 'fontsize',16);
        axis([0 60 -100 100]);
        legend('SteamVR GameObject');
        xlabel('Time');
        ylabel('Position');
        
        %Cannot compensate for latency here since we can't know what it is
        savefig(tracking_Data, 'Tracking Plot with latency');

        
    end
    
    
    
    
    
end




cd('D:\');
