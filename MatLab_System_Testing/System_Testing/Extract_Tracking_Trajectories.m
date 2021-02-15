clear all;
close all;
testIDs = {'Test_1','Test_2','Test_3','Test_4','Test_5','Test_6','Test_7'};
%Excluded: none
nTest = length(testIDs);

% Find opti and trial files
dirName = strcat('D:\Savvy\Work\Conflict Detection\System Testing\Tracking Tests\Test_1');
dirName = char(dirName);
cd(dirName);
files_list = dir(dirName);
% voltages_search_List = regexpi({files_list.name},'.*Voltages_File.*\.txt', 'match');
% voltages_Index_Number = find(~cellfun(@isempty,voltages_search_List));
% voltages_file_Name = char(voltages_search_List{voltages_Index_Number});
% [RecordingTimestamp1,SentVoltage,Velocity] = import_voltage_tracking(voltages_file_Name);
% for i = 1:size(RecordingTimestamp1)-1
%     Seconds(i) = RecordingTimestamp1(i+1) - RecordingTimestamp1(1);
% end
% Velocity = Velocity(~isnan(Velocity));
% Seconds = Seconds';
% voltage_position = Velocity.* Seconds;
% voltage_Time = RecordingTimestamp1;
% voltage_Time(end)=[];
% voltage_Time = voltage_Time(~isnan(voltage_Time));
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
unity_milliseconds=141;
unity_milliseconds = unity_milliseconds/1000;
%Add times to get time recording start in seconds
steamVRTime_start_time= steamVRTime_num_Minutes+ steamVRTime_num_Seconds + unity_milliseconds;
% Search SteamVR Files
steamVR_search_List = regexpi({files_list.name},'.*SteamVR.*\.txt', 'match');
steamVR_Index_Number = find(~cellfun(@isempty,steamVR_search_List));
steamVR_file_Name = char(steamVR_search_List{steamVR_Index_Number});
% Search for Optitrack gameobject file
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
[TimeSeconds,X,Y,Z] = import_Optitrack_Rotational_Data(opti_file_Name);
opti_str = opti_file_Name;
expression = '\.';
expression2 = ' ';
opti_splitstr = regexp(opti_str,expression,'split');
optitrack_time_Minutes=opti_splitstr{1,2};
opti_num_Minutes=str2num(optitrack_time_Minutes);
if opti_num_Minutes ~= 0
    opti_num_Minutes=opti_num_Minutes*60;
end
opti_splitstr2 = regexp(opti_splitstr{1,3},expression2,'split');
optitrack_time_Seconds=opti_splitstr2{1,1};
opti_num_Seconds=str2num(optitrack_time_Seconds);
optitrack_milliseconds = 198;
optitrack_milliseconds = optitrack_milliseconds/1000;
optitrack_seconds=opti_num_Minutes+opti_num_Seconds;
optitrack_start_time =optitrack_seconds + optitrack_milliseconds;
opti_vs_trial_time_difference= abs(optitrack_start_time - steamVRTime_start_time);
newOptitrackTimeSeconds=TimeSeconds+opti_vs_trial_time_difference;
%The following is all latency compensating stuff
steamVR_latency_milliseconds=12;
steamVR_latency_milliseconds = steamVR_latency_milliseconds/100;
newSteamVRTime = steamVRRecordingTime - steamVR_latency_milliseconds;
steamVRYaw_T1 = SteamVRGameObjectYaw;
steamVRYaw_T1 = abs(steamVRYaw_T1);
steamVRTime_T1 = newSteamVRTime;
optiGoYaw_T1 = OptitrackGameObjectYaw;
optiGoYaw_T1 = abs(optiGoYaw_T1);
optiY_T1 = Y;
optiY_T1 = abs(optiY_T1);
optitrackTime_T1 = newOptitrackTimeSeconds;
for i = 1:size(steamVRTime_T1)
    steamVRTime_T1(i) = steamVRTime_T1(i) - 5.3;
end
for i = 1:size(optitrackTime_T1)
    optitrackTime_T1(i) = optitrackTime_T1(i) - 5.3;
end


% Specify where the window begins
% startIndex = index - windowWidth;
startIndex = -0.1;
% Find max
[minValue, indexOfMin] = min(steamVRYaw_T1(startIndex:indexOfMin))
% Add offset to index
indexOfMin = indexOfMin + startIndex - 1;




save('importedTrackingTest1.mat');
clear all;
% load('importedTrackingTest1.mat');


% Find opti and trial files
dirName = strcat('D:\Savvy\Work\Conflict Detection\System Testing\Tracking Tests\Test_2');
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
unity_milliseconds=263;
unity_milliseconds = unity_milliseconds/1000;
%Add times to get time recording start in seconds
steamVRTime_start_time= steamVRTime_num_Minutes+ steamVRTime_num_Seconds + unity_milliseconds;
% Search SteamVR Files
steamVR_search_List = regexpi({files_list.name},'.*SteamVR.*\.txt', 'match');
steamVR_Index_Number = find(~cellfun(@isempty,steamVR_search_List));
steamVR_file_Name = char(steamVR_search_List{steamVR_Index_Number});
% Search for Optitrack gameobject file
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
[TimeSeconds,X,Y,Z] = import_Optitrack_Rotational_Data(opti_file_Name);
opti_str = opti_file_Name;
expression = '\.';
expression2 = ' ';
opti_splitstr = regexp(opti_str,expression,'split');
optitrack_time_Minutes=opti_splitstr{1,2};
opti_num_Minutes=str2num(optitrack_time_Minutes);
if opti_num_Minutes ~= 0
    opti_num_Minutes=opti_num_Minutes*60;
end
opti_splitstr2 = regexp(opti_splitstr{1,3},expression2,'split');
optitrack_time_Seconds=opti_splitstr2{1,1};
opti_num_Seconds=str2num(optitrack_time_Seconds);
optitrack_milliseconds = 7;
optitrack_milliseconds = optitrack_milliseconds/1000;
optitrack_seconds=opti_num_Minutes+opti_num_Seconds;
optitrack_start_time =optitrack_seconds + optitrack_milliseconds;
opti_vs_trial_time_difference= abs(optitrack_start_time - steamVRTime_start_time);
newOptitrackTimeSeconds=TimeSeconds+opti_vs_trial_time_difference;
%The following is all latency compensating stuff
steamVR_latency_milliseconds=60;
steamVR_latency_milliseconds = steamVR_latency_milliseconds/100;
newSteamVRTime = steamVRRecordingTime - steamVR_latency_milliseconds;
steamVRYaw_T2 = SteamVRGameObjectYaw;
steamVRYaw_T2 = abs(steamVRYaw_T2);
steamVRTime_T2 = newSteamVRTime;
optiGoYaw_T2 = OptitrackGameObjectYaw;
optiGoYaw_T2 = abs(optiGoYaw_T2);
optiY_T2 = Y;
optiY_T2 = abs(optiY_T2);
optitrackTime_T2 = newOptitrackTimeSeconds;
%Yaw offset
for i = 1:size(steamVRYaw_T2)
    steamVRYaw_T2(i) = steamVRYaw_T2(i) - 2.646;
end
for i = 1:size(optiGoYaw_T2)
    optiGoYaw_T2(i) = optiGoYaw_T2(i) - 2.646;
end
for i = 1:size(optiY_T2)
    optiY_T2(i) = optiY_T2(i) - 2.646;
end
for i = 1:size(steamVRTime_T2)
    steamVRTime_T2(i) = steamVRTime_T2(i) - 3.9467; %3.77
end
for i = 1:size(optitrackTime_T2)
    optitrackTime_T2(i) = optitrackTime_T2(i) - 3.9407; %3.77
end
save('importedTrackingTest2.mat');
% load('importedTrackingTest2.mat');
clear all;
% 
% Find opti and trial files
dirName = strcat('D:\Savvy\Work\Conflict Detection\System Testing\Tracking Tests\Test_3');
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
unity_milliseconds=678;
unity_milliseconds = unity_milliseconds/1000;
%Add times to get time recording start in seconds
steamVRTime_start_time= steamVRTime_num_Minutes+ steamVRTime_num_Seconds + unity_milliseconds;
% Search SteamVR Files
steamVR_search_List = regexpi({files_list.name},'.*SteamVR.*\.txt', 'match');
steamVR_Index_Number = find(~cellfun(@isempty,steamVR_search_List));
steamVR_file_Name = char(steamVR_search_List{steamVR_Index_Number});
% Search for Optitrack gameobject file
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
[TimeSeconds,X,Y,Z] = import_Optitrack_Rotational_Data(opti_file_Name);
opti_str = opti_file_Name;
expression = '\.';
expression2 = ' ';
opti_splitstr = regexp(opti_str,expression,'split');
optitrack_time_Minutes=opti_splitstr{1,2};
opti_num_Minutes=str2num(optitrack_time_Minutes);
if opti_num_Minutes ~= 0
    opti_num_Minutes=opti_num_Minutes*60;
end
opti_splitstr2 = regexp(opti_splitstr{1,3},expression2,'split');
optitrack_time_Seconds=opti_splitstr2{1,1};
opti_num_Seconds=str2num(optitrack_time_Seconds);
optitrack_milliseconds = 514;
optitrack_milliseconds = optitrack_milliseconds/1000;
optitrack_seconds=opti_num_Minutes+opti_num_Seconds;
optitrack_start_time =optitrack_seconds + optitrack_milliseconds;
opti_vs_trial_time_difference= abs(optitrack_start_time - steamVRTime_start_time);
newOptitrackTimeSeconds=TimeSeconds+opti_vs_trial_time_difference;
%The following is all latency compensating stuff
steamVR_latency_milliseconds=9;
steamVR_latency_milliseconds = steamVR_latency_milliseconds/100;
newSteamVRTime = steamVRRecordingTime - steamVR_latency_milliseconds;
steamVRYaw_T3 = SteamVRGameObjectYaw;
steamVRYaw_T3 = abs(steamVRYaw_T3);
steamVRTime_T3 = newSteamVRTime;
optiGoYaw_T3 = OptitrackGameObjectYaw;
optiGoYaw_T3 = abs(optiGoYaw_T3);
optiY_T3 = Y;
optiY_T3 = abs(optiY_T3);
optitrackTime_T3 = newOptitrackTimeSeconds;
%Yaw offset
for i = 1:size(steamVRYaw_T3)
    steamVRYaw_T3(i) = steamVRYaw_T3(i) - 1.373;
end
for i = 1:size(optiGoYaw_T3)
    optiGoYaw_T3(i) = optiGoYaw_T3(i) - 1.373;
end
for i = 1:size(optiY_T3)
    optiY_T3(i) = optiY_T3(i) - 1.373;
end
%Yaw offset
for i = 1:size(steamVRYaw_T3)
    steamVRYaw_T3(i) = steamVRYaw_T3(i) + 0.793;
end
for i = 1:size(optiGoYaw_T3)
    optiGoYaw_T3(i) = optiGoYaw_T3(i) + 0.793;
end
for i = 1:size(optiY_T3)
    optiY_T3(i) = optiY_T3(i) + 0.793;
end
%time offset
for i = 1:size(steamVRTime_T3)
    steamVRTime_T3(i) = steamVRTime_T3(i) - 4.81;
end
for i = 1:size(optitrackTime_T3)
    optitrackTime_T3(i) = optitrackTime_T3(i) - 4.81;
end
save('importedTrackingTest3.mat');
% load('importedTrackingTest3.mat');
clear all;

% Find opti and trial files
dirName = strcat('D:\Savvy\Work\Conflict Detection\System Testing\Tracking Tests\Test_4');
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
unity_milliseconds=449;
unity_milliseconds = unity_milliseconds/1000;
%Add times to get time recording start in seconds
steamVRTime_start_time= steamVRTime_num_Minutes+ steamVRTime_num_Seconds + unity_milliseconds;
% Search SteamVR Files
steamVR_search_List = regexpi({files_list.name},'.*SteamVR.*\.txt', 'match');
steamVR_Index_Number = find(~cellfun(@isempty,steamVR_search_List));
steamVR_file_Name = char(steamVR_search_List{steamVR_Index_Number});
% Search for Optitrack gameobject file
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
[TimeSeconds,X,Y,Z] = import_Optitrack_Rotational_Data(opti_file_Name);
opti_str = opti_file_Name;
expression = '\.';
expression2 = ' ';
opti_splitstr = regexp(opti_str,expression,'split');
optitrack_time_Minutes=opti_splitstr{1,2};
opti_num_Minutes=str2num(optitrack_time_Minutes);
if opti_num_Minutes ~= 0
    opti_num_Minutes=opti_num_Minutes*60;
end
opti_splitstr2 = regexp(opti_splitstr{1,3},expression2,'split');
optitrack_time_Seconds=opti_splitstr2{1,1};
opti_num_Seconds=str2num(optitrack_time_Seconds);
optitrack_milliseconds = 24;
optitrack_milliseconds = optitrack_milliseconds/1000;
optitrack_seconds=opti_num_Minutes+opti_num_Seconds;
optitrack_start_time =optitrack_seconds + optitrack_milliseconds;
opti_vs_trial_time_difference= abs(optitrack_start_time - steamVRTime_start_time);
newOptitrackTimeSeconds=TimeSeconds+opti_vs_trial_time_difference;
%The following is all latency compensating stuff
steamVR_latency_milliseconds=26;
steamVR_latency_milliseconds = steamVR_latency_milliseconds/100;
newSteamVRTime = steamVRRecordingTime - steamVR_latency_milliseconds;
steamVRYaw_T4 = abs(SteamVRGameObjectYaw);
steamVRTime_T4 = newSteamVRTime;
optiGoYaw_T4 = abs(OptitrackGameObjectYaw); 
optiY_T4 = Y;
optiY_T4 = abs(optiY_T4);
optitrackTime_T4 = newOptitrackTimeSeconds;
%Yaw offset
% for i = 1:size(steamVRYaw_T4)
%     steamVRYaw_T4(i) = steamVRYaw_T4(i) - 5.677;
% end
% for i = 1:size(optiGoYaw_T4)
%     optiGoYaw_T4(i) = optiGoYaw_T4(i) - 5.677;
% end
% for i = 1:size(optiY_T4)
%     optiY_T4(i) = optiY_T4(i) - 5.677;
% end
for i = 1:size(steamVRYaw_T4)
    steamVRYaw_T4(i) = steamVRYaw_T4(i) + 0.793;
end
for i = 1:size(optiGoYaw_T4)
    optiGoYaw_T4(i) = optiGoYaw_T4(i) + 0.793;
end
for i = 1:size(optiY_T4)
    optiY_T4(i) = optiY_T4(i) + 0.793;
end
for i = 1:size(steamVRTime_T4)
    steamVRTime_T4(i) = steamVRTime_T4(i) - 4.199; %3.97
end
for i = 1:size(optitrackTime_T4)
    optitrackTime_T4(i) = optitrackTime_T4(i) - 4.2087; %3.97
end 
save('importedTrackingTest4.mat');
% load('importedTrackingTest4.mat');
clear all;

% Find opti and trial files
dirName = strcat('D:\Savvy\Work\Conflict Detection\System Testing\Tracking Tests\Test_5');
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
unity_milliseconds=516;
unity_milliseconds = unity_milliseconds/1000;
%Add times to get time recording start in seconds
steamVRTime_start_time= steamVRTime_num_Minutes+ steamVRTime_num_Seconds + unity_milliseconds;
% Search SteamVR Files
steamVR_search_List = regexpi({files_list.name},'.*SteamVR.*\.txt', 'match');
steamVR_Index_Number = find(~cellfun(@isempty,steamVR_search_List));
steamVR_file_Name = char(steamVR_search_List{steamVR_Index_Number});
% Search for Optitrack gameobject file
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
[TimeSeconds,X,Y,Z] = import_Optitrack_Rotational_Data(opti_file_Name);
opti_str = opti_file_Name;
expression = '\.';
expression2 = ' ';
opti_splitstr = regexp(opti_str,expression,'split');
optitrack_time_Minutes=opti_splitstr{1,2};
opti_num_Minutes=str2num(optitrack_time_Minutes);
if opti_num_Minutes ~= 0
    opti_num_Minutes=opti_num_Minutes*60;
end
opti_splitstr2 = regexp(opti_splitstr{1,3},expression2,'split');
optitrack_time_Seconds=opti_splitstr2{1,1};
opti_num_Seconds=str2num(optitrack_time_Seconds);
optitrack_milliseconds = 203;
optitrack_milliseconds = optitrack_milliseconds/1000;
optitrack_seconds=opti_num_Minutes+opti_num_Seconds;
optitrack_start_time =optitrack_seconds + optitrack_milliseconds;
opti_vs_trial_time_difference= abs(optitrack_start_time - steamVRTime_start_time);
newOptitrackTimeSeconds=TimeSeconds+opti_vs_trial_time_difference;
%The following is all latency compensating stuff
steamVR_latency_milliseconds=11;
steamVR_latency_milliseconds = steamVR_latency_milliseconds/100;
newSteamVRTime = steamVRRecordingTime - steamVR_latency_milliseconds;
steamVRYaw_T5 = abs(SteamVRGameObjectYaw);
steamVRTime_T5 = newSteamVRTime;
optiGoYaw_T5 = abs(OptitrackGameObjectYaw);
optiY_T5 = abs(Y);
optitrackTime_T5 = newOptitrackTimeSeconds;
%Yaw offset
% for i = 1:size(steamVRYaw_T5)
%     steamVRYaw_T5(i) = steamVRYaw_T5(i) - 9.993;
% end
% for i = 1:size(optiGoYaw_T5)
%     optiGoYaw_T5(i) = optiGoYaw_T5(i) - 9.993;
% end
% for i = 1:size(optiY_T5)
%     optiY_T5(i) = optiY_T5(i) - 9.993;
% end
for i = 1:size(steamVRYaw_T5)
    steamVRYaw_T5(i) = steamVRYaw_T5(i) + 0.7168;
end
for i = 1:size(optiGoYaw_T5)
    optiGoYaw_T5(i) = optiGoYaw_T5(i) + 0.7168;
end
for i = 1:size(optiY_T5)
    optiY_T5(i) = optiY_T5(i) + 0.7168;
end
for i = 1:size(steamVRTime_T5)
    steamVRTime_T5(i) = steamVRTime_T5(i) - 5.0152; %4.84
end
for i = 1:size(optitrackTime_T5)
    optitrackTime_T5(i) = optitrackTime_T5(i) - 5.0217; %4.84
end
save('importedTrackingTest5.mat');
clear all;

% Find opti and trial files
dirName = strcat('D:\Savvy\Work\Conflict Detection\System Testing\Tracking Tests\Test_6');
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
steamVRYaw_T6 = abs(SteamVRGameObjectYaw);
steamVRTime_T6 = steamVRRecordingTime;
for i = 1:size(steamVRYaw_T6)
    steamVRYaw_T6(i) = steamVRYaw_T6(i) - 56.28104; %56.94
end
steamVRYaw_T6 = abs(steamVRYaw_T6);
for i = 1:size(steamVRTime_T6)
    steamVRTime_T6(i) = steamVRTime_T6(i) - 7.956;
end
save('importedTrackingTest6.mat');
% load('importedTrackingTest6.mat');
clear all;
 
% Find opti and trial files
dirName = strcat('D:\Savvy\Work\Conflict Detection\System Testing\Tracking Tests\Test_7');
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
% for i = 1:size(SteamVRGameObjectYaw)
%     SteamVRGameObjectYaw(i) = SteamVRGameObjectYaw(i) - SteamVRGameObjectYaw(1);
% end
for i = 1:size(SteamVRGameObjectYaw)
    if SteamVRGameObjectYaw(i) > 180
        SteamVRGameObjectYaw(i) = SteamVRGameObjectYaw(i) - 360;
    end
end 
steamVRYaw_T7 = abs(SteamVRGameObjectYaw);
steamVRTime_T7 = steamVRRecordingTime;% 
for i = 1:size(steamVRYaw_T7)
    steamVRYaw_T7(i) = steamVRYaw_T7(i) - 51.1489; %51.89
end
steamVRYaw_T7 = abs(steamVRYaw_T7);
for i = 1:size(steamVRTime_T7)
    steamVRTime_T7(i) = steamVRTime_T7(i) - 3.529;
end
save('importedTrackingTest7.mat');
% load('importedTrackingTest7.mat');












cd('D:\');
