clear all;
close all;

testIDs = {'Test_1','Test_2','Test_3','Test_4','Test_5','Test_6','Test_7'};
%Excluded: none
nTest = length(testIDs);

row1=1;
row2=1;
row3=1;
row4=1;
row5=1;
plotct=1;
                %Determine lower right location of matrix
                row_Steam2 = 1;
                row_Steam =1;
                rows_steamVR_gameobject_All_index =1;
                col_Steam2 = 1;
                col_Steam =1;
                col_steamVR_gameobject_All_index = 1;
                

%grab all of the steamVR
steamVR_gameobject_All_index = zeros(15000,8);
steamVR_GO_All_Yaw = zeros(15000,8);
SteamVR_All_Time_index = zeros(15000,8);
SteamVR_All_Time = zeros(15000,8);

optitrack_GO_All_Yaw_index = zeros(15000,8);
optitrack_GO_All_Yaw = zeros(15000,8);
optitrack_GO_index = zeros(15000,8);
optitrack_GO_All_Time = zeros(15000,8);

optitrack_Y_All_Yaw_index = zeros(15000,8);
optitrack_Y_All_Yaw = zeros(15000,8);
optitrack_All_Time_index = zeros(15000,8);
optitrack_All_Time = zeros(15000,8);


for test = 1:nTest
    
    %clear variables
    % clearvars -except test testIDs cnTest;
    
    testID = string(testIDs(test));
    % Find opti and trial files
    dirName = strcat('D:\Conflict Detection\Tracking Test\',testID);
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
    %split the string to get the time
    steamVRTime_splitstr2 = regexp(steamVRTime_splitstr{1,3},expression4,'split');
    steamVRTime_time_Seconds=steamVRTime_splitstr2{1,1};
    steamVRTime_num_Seconds=str2num(steamVRTime_time_Seconds);
    %manually enter in the milliseconds for unity
    unity_milliseconds=input('Unity Milliseconds?');
    unity_milliseconds = unity_milliseconds/1000;
    %Add times to get time recording start in seconds
    steamVRTime_start_time= steamVRTime_num_Minutes+ steamVRTime_num_Seconds + unity_milliseconds;
    
    
    
    %Grab optitrack if it's test 1-5
    if testID == 'Test_1' || testID == 'Test_2' || testID == 'Test_3' || testID == 'Test_4' || testID == 'Test_5'
        
        % Search for Optitrack gameobject file
        Optitrack_Gameobject_search_List = regexpi({files_list.name},'.*Optitrack_Object.*\.txt', 'match');
        Optitrack_Gameobject_Index_Number = find(~cellfun(@isempty,Optitrack_Gameobject_search_List));
        Optitrack_Gameobject_file_Name = char(Optitrack_Gameobject_search_List{Optitrack_Gameobject_Index_Number});
        %Optitrack Gameobject import
        [WorldTimestamp,RecordingTimestamp,OptitrackGameObjectRoll,OptitrackGameObjectPitch,OptitrackGameObjectYaw,SentTrajectoryYaw] = import_Optitrack_GameObject(Optitrack_Gameobject_file_Name);
        %convert to new variable name to avoid override
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
        
    end
    
    
    % set names of the variables to add to a matrix
    if testID == 'Test_1'
        
        %SteamVR gameobject
        steamVR_gameobject_All_index = SteamVRGameObjectYaw;
                                % Get sizes
                [rows_steamVR_GO_All_Yaw, columns_steamVR_GO_All_Yaw_ALL] = size(steamVR_GO_All_Yaw);
                %[rowshead_data_index, columnshead_data_index] = size(head_data_index);
                
                %Determine lower right location of matrix
                row_Steam2 = row_Steam + rows_steamVR_gameobject_All_index - 1;
                col_Steam2 = col_Steam + col_steamVR_gameobject_All_index - 1;
                
                if row_Steam2 <= rows_steamVR_GO_All_Yaw
                    %Grab current position data
                    % Add to total position data
                    steamVR_GO_All_Yaw(row_Steam:row_Steam2, col_Steam:col_Steam2) = steamVR_gameobject_All_index;
                    
                else
                    % It won't fit
                    warningMessage = sprintf('That will not fit.\nThe lower right coordinate would be at row %d, column %d.',...
                        row_Steam2, col_act2);
                    uiwait(warndlg(warningMessage));
                end
                
        %steamVR_gameobject_All_index(:,row1)=steamVR_GO_All_Yaw;
        
        
        SteamVR_All_Time = steamVRRecordingTime;
        SteamVR_All_Time_index(:,row1)=SteamVR_All_Time;
        
        
        %optitrack gameobject
        optitrack_GO_All_Yaw = OptitrackGameObjectYaw;
        optitrack_GO_All_Yaw_index(:,row1)=optitrack_GO_All_Yaw;
        
        
        optitrack_GO_All_Time = optitrackTime;
        optitrack_GO_index(:,row1)=optitrack_GO_All_Time;
        
        
        %optitrack recording
        optitrack_Y_All_Yaw = Y;
        optitrack_Y_All_Yaw_index(:,row1)=optitrack_Y_All_Yaw;
        
        optitrack_All_Time = newOptitrackTimeSeconds;
        optitrack_All_Time_index(:,row1)=optitrack_All_Time;
        
        row1=row1+1;
        
    elseif testID == 'Test_2' || testID == 'Test_3' || testID == 'Test_4' || testID == 'Test_5'
        
        %grab all of the steamVR
%         steamVR_gameobject_All_index(:,row1)=[steamVR_GO_All_Yaw;SteamVRGameObjectYaw];
%         SteamVR_All_Time_index(:,row1)=[SteamVR_All_Time;steamVRRecordingTime];        
%         
                        % Get sizes
                [rows_steamVR_GO_All_Yaw, columns_steamVR_GO_All_Yaw_ALL] = size(steamVR_GO_All_Yaw);
                %[rowshead_data_index, columnshead_data_index] = size(head_data_index);
                
                %Determine lower right location of matrix
                row_Steam2 = row_Steam + rows_steamVR_gameobject_All_index - 1;
                col_Steam2 = col_Steam + col_steamVR_gameobject_All_index - 1;
                
                if row_Steam2 <= rows_steamVR_GO_All_Yaw
                    %Grab current position data
                    % Add to total position data
                    rows_steamVR_GO_All_Yaw(row_Steam:row_Steam2, col_Steam:col_Steam2) = steamVR_gameobject_All_index;
                    
                else
                    % It won't fit
                    warningMessage = sprintf('That will not fit.\nThe lower right coordinate would be at row %d, column %d.',...
                        row_Steam2, col_act2);
                    uiwait(warndlg(warningMessage));
                end
                
        optitrack_GO_All_Yaw_index(:,row1)=[optitrack_GO_All_Yaw;OptitrackGameObjectYaw];
        optitrack_GO_index(:,row1)=[optitrack_GO_All_Time;optitrackTime];
        
        optitrack_Y_All_Yaw_index(:,row1)=[optitrack_Y_All_Yaw;Y];
        optitrack_All_Time_index(:,row1)=[optitrack_All_Time;newOptitrackTimeSeconds];
        
        row1=row1+1;       
        
    elseif testID == 'Test_6' || testID == 'Test_7'
                %grab all of the steamVR
        steamVR_gameobject_All_index(:,row1)=[steamVR_GO_All_Yaw;SteamVRGameObjectYaw];
        SteamVR_All_Time_index(:,row1)=[SteamVR_All_Time;steamVRRecordingTime];        
        row1=row1+1;
    end
    
        %grab all of the steamVR
        steamVR_GO_All_Yaw = steamVR_gameobject_All_index;
        SteamVR_All_Time = SteamVR_All_Time_index;        
        
        optitrack_GO_All_Yaw = optitrack_GO_All_Yaw_index;
        optitrack_GO_All_Time = optitrack_GO_index;
        
        optitrack_Y_All_Yaw = optitrack_Y_All_Yaw_index;
        optitrack_All_Time = optitrack_All_Time_index;
        
    
    
    
    
end

for test = 1:nTest
    
    
 %  clearvars -except t Scene_Passive_AllNumPos Scene_Active_AllNumPos Head_Passive_AllNumPos Head_Active_AllNumPos Scene_Passive_AllStimLevels Scene_Active_AllStimLevels Head_Passive_AllStimLevels Head_Active_AllStimLevels  subj cond actpass subjIDs condIDs actpassIDs nSubj nCond nActpass nTotalTrials row row1 row2 row3 row4 row5 m n h p s c o B mu sigmau sigmal plotct Dev pDev DevSim converged;
        
            
    tracking_Data = figure('Name','Combined Tracking Plots');
    axes
    hold on
    %Plot the steamVR gameobject
    plot(SteamVR_All_Time,abs(steamVR_GO_All_Yaw),'color','r','linewidth',1);
    %plot the optitrack gameobject
    plot(optitrack_GO_All_Time,abs(optitrack_GO_All_Yaw),'color','b','linewidth',1);
    %plot the optitrack recording
    plot(optitrack_All_Time,abs(optitrack_Y_All_Yaw),'color','k','linewidth',1);
    set(gca, 'fontsize',16);
    axis([0 60 -100 100]);
    legend('SteamVR GameObject','Optitrack GameObject','Optitrack Rigidbody');
    xlabel('Time');
    ylabel('Position');
    
    
    %savefig(tracking_Data, 'Combined Tracking Plots');
    
    
    
    
    
end




cd('D:\');
