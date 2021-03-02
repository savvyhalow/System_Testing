clear all;
close all;

%%%%%%%%%%%%%%%%%%%%%%
subjIDs = {'1_Data','2_Data','3_Data','4_Data','5_Data','6_Data','7_Data','8_Data','10_Data','11_Data','12_Data','13_Data','14_Data','15_Data','16_Data','17_Data','18_Data','19_Data','20_Data'};
% Excluded:'9_Data'
nSubj = length(subjIDs);
condIDs = {'Head-Fixed','Scene-Fixed'};
nCond = length(condIDs);
actpassIDs = {'Active','Passive'};
nActpass = length(actpassIDs);
row = 1;

% all_total_confidence = NaN(1,nSubj);
% all_right_confidence = NaN(1,nSubj);
% all_left_confidence = NaN(1,nSubj);
% all_avg_right_fps = NaN(1,nSubj);
% all_avg_left_fps = NaN(1,nSubj);
% 
% all_total_confidence = array2table(all_total_confidence);
% all_right_confidence = array2table(all_right_confidence);
% all_left_confidence = array2table(all_left_confidence);
% all_avg_right_fps = array2table(all_avg_right_fps);
% all_avg_left_fps = array2table(all_avg_left_fps);

for subj = 1:nSubj
    for cond = 1:nCond
        for actpass = 1:nActpass

            
            clearvars -except row all_recording_length all_avg_fps all_left_confidence all_right_confidence all_total_confidence subj cond actpass subjIDs condIDs actpassIDs nSubj nCond nActpass nTotalTrials plotct pupil_timestamp pupil_ID pupil_confidence pupil_phi;
            subjID = string(subjIDs(subj));
            condID = string(condIDs(cond));
            actpassID = string(actpassIDs(actpass));
            if condID == 'Head-Fixed'
                condIDsearch = 'Head-Fixed';
            else
                condIDsearch = 'Scene-Fixed';
            end
            if actpassID == 'Active'
                actpass1ID = 'Active 1';
                actpass2ID = 'Active 2';
            end
            if actpassID == 'Passive'
                actpass1ID = 'Passive 1';
                actpass2ID = 'Passive 2';
            end
            
            
            %************************* Open File 1  & Parse
            dirName = strcat('E:\Box Sync\Box Sync\SelfMotion Lab\Projects\Conf_Detect_Head_Eye\EyeData_Only');
            dirName = char(dirName);
            cd(dirName);
                        
            fileName = strcat(subjID,'_', condID,'_', actpass1ID,'_', 'pupil_stats.xlsx');
            eye_data = readtable(fileName);
            
            % Add data to the list for calculation
            all_recording_length(row,:) = eye_data(1,1);
            all_total_confidence(row,:) = eye_data(1,2);
            all_right_confidence(row,:) = eye_data(1,3);
            all_left_confidence(row,:) = eye_data(1,4);
            all_avg_fps(row,:) = eye_data(1,5);
            
            row = row + 1;
            
            fileName = strcat(subjID,'_', condID,'_', actpass2ID,'_', 'pupil_stats.xlsx');
            eye_data = readtable(fileName);

            all_recording_length(row,:) = eye_data(1,1);
            all_total_confidence(row,:) = eye_data(1,2);
            all_right_confidence(row,:) = eye_data(1,3);
            all_left_confidence(row,:) = eye_data(1,4);
            all_avg_fps(row,:) = eye_data(1,5);
            
            row = row + 1;
            
        end
        %         %save('importedpupil.mat','pupil_timestamp','pupil_ID','pupil_confidence','pupil_phi');
    end
end
all_recording_length = table2array(all_recording_length);
all_total_confidence = table2array(all_total_confidence);
all_right_confidence = table2array(all_right_confidence);
all_left_confidence = table2array(all_left_confidence);
all_avg_fps = table2array(all_avg_fps);

avg_length = nanmean(all_recording_length)
avg_total_confidence = nanmean(all_total_confidence)
avg_right_confidence = nanmean(all_right_confidence)
avg_left_confidence = nanmean(all_left_confidence)
avg__fps = nanmean(all_avg_fps)


% cd('D:\MATLAB');