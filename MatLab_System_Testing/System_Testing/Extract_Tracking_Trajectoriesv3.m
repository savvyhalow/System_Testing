clear all;
close all;
testIDs = {'Test_1_1','Test_2_1','Test_3_1','Test_4_1','Test_5_1','Test_6_1','Test_7_1'};
%Excluded: none
nTest = length(testIDs);

% Find opti and trial files
dirName = strcat('D:\Savvy\Work\Conflict Detection\System Testing\Tracking Tests\Test_1_1');
dirName = char(dirName);
cd(dirName);
files_list = dir(dirName);
% Search SteamVR Files
steamVR_search_List = regexpi({files_list.name},'.*SteamVR.*\.txt', 'match');
steamVR_Index_Number = find(~cellfun(@isempty,steamVR_search_List));
steamVR_file_Name = char(steamVR_search_List{steamVR_Index_Number});

%SteamVR Gameobject import
[WorldTimestamp,RecordingTimestamp,SteamVRGameObjectRoll,SteamVRGameObjectPitch,SteamVRGameObjectYaw,SentTrajectoryYaw] = import_SteamVR_Gameobject(steamVR_file_Name);
steamVRGO_Time = RecordingTimestamp;

for i = 1:size(SteamVRGameObjectYaw)
    SteamVRGameObjectYaw(i) = SteamVRGameObjectYaw(i) - SteamVRGameObjectYaw(1);
end
for i = 1:size(SteamVRGameObjectYaw)
    if SteamVRGameObjectYaw(i) > 180
        SteamVRGameObjectYaw(i) = SteamVRGameObjectYaw(i) - 360;
    end
end

gameobject_compensation = steamVRGO_Time(1);
for i = 1:size(steamVRGO_Time)
    steamVRGO_Time(i) = steamVRGO_Time(i) - gameobject_compensation;
    %             steamVRTime(i) = steamVRTime(i) - steamVRTime(1);
end

% Search for Optitrack gameobject file
Optitrack_Gameobject_search_List = regexpi({files_list.name},'.*Optitrack_Object.*\.txt', 'match');
Optitrack_Gameobject_Index_Number = find(~cellfun(@isempty,Optitrack_Gameobject_search_List));
Optitrack_Gameobject_file_Name = char(Optitrack_Gameobject_search_List{Optitrack_Gameobject_Index_Number});

%Optitrack Gameobject import
[WorldTimestamp,RecordingTimestamp,OptitrackGameObjectRoll,OptitrackGameObjectPitch,OptitrackGameObjectYaw,SentTrajectoryYaw] = import_Optitrack_GameObject(Optitrack_Gameobject_file_Name);
optiGO_Time = RecordingTimestamp;
for i = 1:size(OptitrackGameObjectYaw)
    OptitrackGameObjectYaw(i) = OptitrackGameObjectYaw(i) - OptitrackGameObjectYaw(1);
end
for i = 1:size(OptitrackGameObjectYaw)
    if OptitrackGameObjectYaw(i) > 180
        OptitrackGameObjectYaw(i) = OptitrackGameObjectYaw(i) - 360;
    end
end


%The following is all latency compensating stuff
steamVRYaw = abs(SteamVRGameObjectYaw);
optiGoYaw = abs(OptitrackGameObjectYaw);

% Search for opti files
opti_search_List = regexpi({files_list.name},'.*M.*\.csv', 'match');
opti_Index_Number = find(~cellfun(@isempty,opti_search_List));
opti_file_Name = char(opti_search_List{opti_Index_Number});
[TimeSeconds,X,Y,Z] = import_opti_TimeCompensated(opti_file_Name);
optiY = abs(Y);
optitrackTime = TimeSeconds;

opti_compensation = optitrackTime(1);
for i = 1:size(optitrackTime)
    optitrackTime(i) = optitrackTime(i) - opti_compensation;
    %             optitrackTime(i) = optitrackTime(i) - optitrackTime(1);
end

steamVRYaw_T1 = steamVRYaw;
optiGoYaw_T1 = optiGoYaw;
steamVRTime_T1 = steamVRGO_Time;
optiY_T1 = optiY;
optitrackTime_T1 = optitrackTime;
save('importedTrackingTest1.mat');
clear all;
% load('importedTrackingTest1.mat');






% Find opti and trial files
dirName = strcat('D:\Savvy\Work\Conflict Detection\System Testing\Tracking Tests\Test_2_1');
dirName = char(dirName);
cd(dirName);
files_list = dir(dirName);
% Search SteamVR Files
steamVR_search_List = regexpi({files_list.name},'.*SteamVR.*\.txt', 'match');
steamVR_Index_Number = find(~cellfun(@isempty,steamVR_search_List));
steamVR_file_Name = char(steamVR_search_List{steamVR_Index_Number});

%SteamVR Gameobject import
[WorldTimestamp,RecordingTimestamp,SteamVRGameObjectRoll,SteamVRGameObjectPitch,SteamVRGameObjectYaw,SentTrajectoryYaw] = import_SteamVR_Gameobject(steamVR_file_Name);
steamVRGO_Time = RecordingTimestamp;

for i = 1:size(SteamVRGameObjectYaw)
    SteamVRGameObjectYaw(i) = SteamVRGameObjectYaw(i) - SteamVRGameObjectYaw(1);
end
for i = 1:size(SteamVRGameObjectYaw)
    if SteamVRGameObjectYaw(i) > 180
        SteamVRGameObjectYaw(i) = SteamVRGameObjectYaw(i) - 360;
    end
end

gameobject_compensation = steamVRGO_Time(1);
for i = 1:size(steamVRGO_Time)
    steamVRGO_Time(i) = steamVRGO_Time(i) - gameobject_compensation;
    %             steamVRTime(i) = steamVRTime(i) - steamVRTime(1);
end

% Search for Optitrack gameobject file
Optitrack_Gameobject_search_List = regexpi({files_list.name},'.*Optitrack_Object.*\.txt', 'match');
Optitrack_Gameobject_Index_Number = find(~cellfun(@isempty,Optitrack_Gameobject_search_List));
Optitrack_Gameobject_file_Name = char(Optitrack_Gameobject_search_List{Optitrack_Gameobject_Index_Number});

%Optitrack Gameobject import
[WorldTimestamp,RecordingTimestamp,OptitrackGameObjectRoll,OptitrackGameObjectPitch,OptitrackGameObjectYaw,SentTrajectoryYaw] = import_Optitrack_GameObject(Optitrack_Gameobject_file_Name);
optiGO_Time = RecordingTimestamp;
for i = 1:size(OptitrackGameObjectYaw)
    OptitrackGameObjectYaw(i) = OptitrackGameObjectYaw(i) - OptitrackGameObjectYaw(1);
end
for i = 1:size(OptitrackGameObjectYaw)
    if OptitrackGameObjectYaw(i) > 180
        OptitrackGameObjectYaw(i) = OptitrackGameObjectYaw(i) - 360;
    end
end


%The following is all latency compensating stuff
steamVRYaw = abs(SteamVRGameObjectYaw);
optiGoYaw = abs(OptitrackGameObjectYaw);

% Search for opti files
opti_search_List = regexpi({files_list.name},'.*M.*\.csv', 'match');
opti_Index_Number = find(~cellfun(@isempty,opti_search_List));
opti_file_Name = char(opti_search_List{opti_Index_Number});
[TimeSeconds,X,Y,Z] = import_opti_TimeCompensated(opti_file_Name);
optiY = abs(Y);
optitrackTime = TimeSeconds;

opti_compensation = optitrackTime(1);
for i = 1:size(optitrackTime)
    optitrackTime(i) = optitrackTime(i) - opti_compensation;
    %             optitrackTime(i) = optitrackTime(i) - optitrackTime(1);
end
steamVRYaw_T2 = steamVRYaw;
optiGoYaw_T2 = optiGoYaw;
steamVRTime_T2 = steamVRGO_Time;
optiY_T2 = optiY;
optitrackTime_T2 = optitrackTime;
save('importedTrackingTest2.mat');
% load('importedTrackingTest2.mat');
clear all;



%
% Find opti and trial files
dirName = strcat('D:\Savvy\Work\Conflict Detection\System Testing\Tracking Tests\Test_3_1');
dirName = char(dirName);
cd(dirName);
files_list = dir(dirName);
% Search SteamVR Files
steamVR_search_List = regexpi({files_list.name},'.*SteamVR.*\.txt', 'match');
steamVR_Index_Number = find(~cellfun(@isempty,steamVR_search_List));
steamVR_file_Name = char(steamVR_search_List{steamVR_Index_Number});

%SteamVR Gameobject import
[WorldTimestamp,RecordingTimestamp,SteamVRGameObjectRoll,SteamVRGameObjectPitch,SteamVRGameObjectYaw,SentTrajectoryYaw] = import_SteamVR_Gameobject(steamVR_file_Name);
steamVRGO_Time = RecordingTimestamp;

for i = 1:size(SteamVRGameObjectYaw)
    SteamVRGameObjectYaw(i) = SteamVRGameObjectYaw(i) - SteamVRGameObjectYaw(1);
end
for i = 1:size(SteamVRGameObjectYaw)
    if SteamVRGameObjectYaw(i) > 180
        SteamVRGameObjectYaw(i) = SteamVRGameObjectYaw(i) - 360;
    end
end

gameobject_compensation = steamVRGO_Time(1);
for i = 1:size(steamVRGO_Time)
    steamVRGO_Time(i) = steamVRGO_Time(i) - gameobject_compensation;
    %             steamVRTime(i) = steamVRTime(i) - steamVRTime(1);
end

% Search for Optitrack gameobject file
Optitrack_Gameobject_search_List = regexpi({files_list.name},'.*Optitrack_Object.*\.txt', 'match');
Optitrack_Gameobject_Index_Number = find(~cellfun(@isempty,Optitrack_Gameobject_search_List));
Optitrack_Gameobject_file_Name = char(Optitrack_Gameobject_search_List{Optitrack_Gameobject_Index_Number});

%Optitrack Gameobject import
[WorldTimestamp,RecordingTimestamp,OptitrackGameObjectRoll,OptitrackGameObjectPitch,OptitrackGameObjectYaw,SentTrajectoryYaw] = import_Optitrack_GameObject(Optitrack_Gameobject_file_Name);
optiGO_Time = RecordingTimestamp;
for i = 1:size(OptitrackGameObjectYaw)
    OptitrackGameObjectYaw(i) = OptitrackGameObjectYaw(i) - OptitrackGameObjectYaw(1);
end
for i = 1:size(OptitrackGameObjectYaw)
    if OptitrackGameObjectYaw(i) > 180
        OptitrackGameObjectYaw(i) = OptitrackGameObjectYaw(i) - 360;
    end
end


%The following is all latency compensating stuff
steamVRYaw = abs(SteamVRGameObjectYaw);
optiGoYaw = abs(OptitrackGameObjectYaw);

% Search for opti files
opti_search_List = regexpi({files_list.name},'.*M.*\.csv', 'match');
opti_Index_Number = find(~cellfun(@isempty,opti_search_List));
opti_file_Name = char(opti_search_List{opti_Index_Number});
[TimeSeconds,X,Y,Z] = import_opti_TimeCompensated(opti_file_Name);
optiY = abs(Y);
optitrackTime = TimeSeconds;

opti_compensation = optitrackTime(1);
for i = 1:size(optitrackTime)
    optitrackTime(i) = optitrackTime(i) - opti_compensation;
    %             optitrackTime(i) = optitrackTime(i) - optitrackTime(1);
end
steamVRYaw_T3 = steamVRYaw;
optiGoYaw_T3 = optiGoYaw;
steamVRTime_T3 = steamVRGO_Time;
optiY_T3 = optiY;
optitrackTime_T3 = optitrackTime;
save('importedTrackingTest3.mat');
% load('importedTrackingTest3.mat');
clear all;




% Find opti and trial files
dirName = strcat('D:\Savvy\Work\Conflict Detection\System Testing\Tracking Tests\Test_4_1');
dirName = char(dirName);
cd(dirName);
files_list = dir(dirName);
% Search SteamVR Files
steamVR_search_List = regexpi({files_list.name},'.*SteamVR.*\.txt', 'match');
steamVR_Index_Number = find(~cellfun(@isempty,steamVR_search_List));
steamVR_file_Name = char(steamVR_search_List{steamVR_Index_Number});

%SteamVR Gameobject import
[WorldTimestamp,RecordingTimestamp,SteamVRGameObjectRoll,SteamVRGameObjectPitch,SteamVRGameObjectYaw,SentTrajectoryYaw] = import_SteamVR_Gameobject(steamVR_file_Name);
steamVRGO_Time = RecordingTimestamp;

for i = 1:size(SteamVRGameObjectYaw)
    SteamVRGameObjectYaw(i) = SteamVRGameObjectYaw(i) - SteamVRGameObjectYaw(1);
end
for i = 1:size(SteamVRGameObjectYaw)
    if SteamVRGameObjectYaw(i) > 180
        SteamVRGameObjectYaw(i) = SteamVRGameObjectYaw(i) - 360;
    end
end

gameobject_compensation = steamVRGO_Time(1);
for i = 1:size(steamVRGO_Time)
    steamVRGO_Time(i) = steamVRGO_Time(i) - gameobject_compensation;
    %             steamVRTime(i) = steamVRTime(i) - steamVRTime(1);
end

% Search for Optitrack gameobject file
Optitrack_Gameobject_search_List = regexpi({files_list.name},'.*Optitrack_Object.*\.txt', 'match');
Optitrack_Gameobject_Index_Number = find(~cellfun(@isempty,Optitrack_Gameobject_search_List));
Optitrack_Gameobject_file_Name = char(Optitrack_Gameobject_search_List{Optitrack_Gameobject_Index_Number});

%Optitrack Gameobject import
[WorldTimestamp,RecordingTimestamp,OptitrackGameObjectRoll,OptitrackGameObjectPitch,OptitrackGameObjectYaw,SentTrajectoryYaw] = import_Optitrack_GameObject(Optitrack_Gameobject_file_Name);
optiGO_Time = RecordingTimestamp;
for i = 1:size(OptitrackGameObjectYaw)
    OptitrackGameObjectYaw(i) = OptitrackGameObjectYaw(i) - OptitrackGameObjectYaw(1);
end
for i = 1:size(OptitrackGameObjectYaw)
    if OptitrackGameObjectYaw(i) > 180
        OptitrackGameObjectYaw(i) = OptitrackGameObjectYaw(i) - 360;
    end
end


%The following is all latency compensating stuff
steamVRYaw = abs(SteamVRGameObjectYaw);
optiGoYaw = abs(OptitrackGameObjectYaw);

% Search for opti files
opti_search_List = regexpi({files_list.name},'.*M.*\.csv', 'match');
opti_Index_Number = find(~cellfun(@isempty,opti_search_List));
opti_file_Name = char(opti_search_List{opti_Index_Number});
[TimeSeconds,X,Y,Z] = import_opti_TimeCompensated(opti_file_Name);
optiY = abs(Y);
optitrackTime = TimeSeconds;

opti_compensation = optitrackTime(1);
for i = 1:size(optitrackTime)
    optitrackTime(i) = optitrackTime(i) - opti_compensation;
    %             optitrackTime(i) = optitrackTime(i) - optitrackTime(1);
end

steamVRYaw_T4 = steamVRYaw;
optiGoYaw_T4 = optiGoYaw;
steamVRTime_T4 = steamVRGO_Time;
optiY_T4 = optiY;
optitrackTime_T4 = optitrackTime;
save('importedTrackingTest4.mat');
% load('importedTrackingTest4.mat');
clear all;





% Find opti and trial files
dirName = strcat('D:\Savvy\Work\Conflict Detection\System Testing\Tracking Tests\Test_5_1');
dirName = char(dirName);
cd(dirName);
files_list = dir(dirName);
% Search SteamVR Files
steamVR_search_List = regexpi({files_list.name},'.*SteamVR.*\.txt', 'match');
steamVR_Index_Number = find(~cellfun(@isempty,steamVR_search_List));
steamVR_file_Name = char(steamVR_search_List{steamVR_Index_Number});

%SteamVR Gameobject import
[WorldTimestamp,RecordingTimestamp,SteamVRGameObjectRoll,SteamVRGameObjectPitch,SteamVRGameObjectYaw,SentTrajectoryYaw] = import_SteamVR_Gameobject(steamVR_file_Name);
steamVRGO_Time = RecordingTimestamp;

for i = 1:size(SteamVRGameObjectYaw)
    SteamVRGameObjectYaw(i) = SteamVRGameObjectYaw(i) - SteamVRGameObjectYaw(1);
end
for i = 1:size(SteamVRGameObjectYaw)
    if SteamVRGameObjectYaw(i) > 180
        SteamVRGameObjectYaw(i) = SteamVRGameObjectYaw(i) - 360;
    end
end

gameobject_compensation = steamVRGO_Time(1);
for i = 1:size(steamVRGO_Time)
    steamVRGO_Time(i) = steamVRGO_Time(i) - gameobject_compensation;
    %             steamVRTime(i) = steamVRTime(i) - steamVRTime(1);
end

% Search for Optitrack gameobject file
Optitrack_Gameobject_search_List = regexpi({files_list.name},'.*Optitrack_Object.*\.txt', 'match');
Optitrack_Gameobject_Index_Number = find(~cellfun(@isempty,Optitrack_Gameobject_search_List));
Optitrack_Gameobject_file_Name = char(Optitrack_Gameobject_search_List{Optitrack_Gameobject_Index_Number});

%Optitrack Gameobject import
[WorldTimestamp,RecordingTimestamp,OptitrackGameObjectRoll,OptitrackGameObjectPitch,OptitrackGameObjectYaw,SentTrajectoryYaw] = import_Optitrack_GameObject(Optitrack_Gameobject_file_Name);
optiGO_Time = RecordingTimestamp;
for i = 1:size(OptitrackGameObjectYaw)
    OptitrackGameObjectYaw(i) = OptitrackGameObjectYaw(i) - OptitrackGameObjectYaw(1);
end
for i = 1:size(OptitrackGameObjectYaw)
    if OptitrackGameObjectYaw(i) > 180
        OptitrackGameObjectYaw(i) = OptitrackGameObjectYaw(i) - 360;
    end
end


%The following is all latency compensating stuff
steamVRYaw = abs(SteamVRGameObjectYaw);
optiGoYaw = abs(OptitrackGameObjectYaw);

% Search for opti files
opti_search_List = regexpi({files_list.name},'.*M.*\.csv', 'match');
opti_Index_Number = find(~cellfun(@isempty,opti_search_List));
opti_file_Name = char(opti_search_List{opti_Index_Number});
[TimeSeconds,X,Y,Z] = import_opti_TimeCompensated(opti_file_Name);
optiY = abs(Y);
optitrackTime = TimeSeconds;

opti_compensation = optitrackTime(1);
for i = 1:size(optitrackTime)
    optitrackTime(i) = optitrackTime(i) - opti_compensation;
    %             optitrackTime(i) = optitrackTime(i) - optitrackTime(1);
end
steamVRYaw_T5 = steamVRYaw;
optiGoYaw_T5 = optiGoYaw;
steamVRTime_T5 = steamVRGO_Time;
optiY_T5 = optiY;
optitrackTime_T5 = optitrackTime;
save('importedTrackingTest5.mat');
clear all;




% Find opti and trial files
dirName = strcat('D:\Savvy\Work\Conflict Detection\System Testing\Tracking Tests\Test_6_1');
dirName = char(dirName);
cd(dirName);
files_list = dir(dirName);
% Search SteamVR Files
steamVR_search_List = regexpi({files_list.name},'.*SteamVR.*\.txt', 'match');
steamVR_Index_Number = find(~cellfun(@isempty,steamVR_search_List));
steamVR_file_Name = char(steamVR_search_List{steamVR_Index_Number});
%SteamVR Gameobject import
[WorldTimestamp,RecordingTimestamp,SteamVRGameObjectRoll,SteamVRGameObjectPitch,SteamVRGameObjectYaw,SentTrajectoryYaw] = import_SteamVR_Gameobject(steamVR_file_Name);
steamVRGO_Time = RecordingTimestamp;

for i = 1:size(SteamVRGameObjectYaw)
    SteamVRGameObjectYaw(i) = SteamVRGameObjectYaw(i) - SteamVRGameObjectYaw(1);
end
for i = 1:size(SteamVRGameObjectYaw)
    if SteamVRGameObjectYaw(i) > 180
        SteamVRGameObjectYaw(i) = SteamVRGameObjectYaw(i) - 360;
    end
end

%The following is all latency compensating stuff
steamVRYaw = SteamVRGameObjectYaw;
steamVRYaw = abs(steamVRYaw);
gameobject_compensation = steamVRGO_Time(1);
for i = 1:size(steamVRGO_Time)
    steamVRGO_Time(i) = steamVRGO_Time(i) - gameobject_compensation;
end
steamVRYaw_T6 = steamVRYaw;
steamVRTime_T6 = steamVRGO_Time;
save('importedTrackingTest6.mat');
% load('importedTrackingTest6.mat');
clear all;

% Find opti and trial files
dirName = strcat('D:\Savvy\Work\Conflict Detection\System Testing\Tracking Tests\Test_7_1');
dirName = char(dirName);
cd(dirName);
files_list = dir(dirName);
% Search SteamVR Files
steamVR_search_List = regexpi({files_list.name},'.*SteamVR.*\.txt', 'match');
steamVR_Index_Number = find(~cellfun(@isempty,steamVR_search_List));
steamVR_file_Name = char(steamVR_search_List{steamVR_Index_Number});
%SteamVR Gameobject import
[WorldTimestamp,RecordingTimestamp,SteamVRGameObjectRoll,SteamVRGameObjectPitch,SteamVRGameObjectYaw,SentTrajectoryYaw] = import_SteamVR_Gameobject(steamVR_file_Name);
steamVRGO_Time = RecordingTimestamp;

for i = 1:size(SteamVRGameObjectYaw)
    SteamVRGameObjectYaw(i) = SteamVRGameObjectYaw(i) - SteamVRGameObjectYaw(1);
end
for i = 1:size(SteamVRGameObjectYaw)
    if SteamVRGameObjectYaw(i) > 180
        SteamVRGameObjectYaw(i) = SteamVRGameObjectYaw(i) - 360;
    end
end

%The following is all latency compensating stuff
steamVRYaw = SteamVRGameObjectYaw;
steamVRYaw = abs(steamVRYaw);
gameobject_compensation = steamVRGO_Time(1);
for i = 1:size(steamVRGO_Time)
    steamVRGO_Time(i) = steamVRGO_Time(i) - gameobject_compensation;
end
steamVRYaw_T7 = steamVRYaw;
steamVRTime_T7 = steamVRGO_Time;
save('importedTrackingTest7.mat');
% load('importedTrackingTest7.mat');












cd('D:\');
