clear all;
close all;

%%%%%%%%%%%%%%%%%%%%%%


subjIDs = {'1_Data','2_Data','3_Data','4_Data','5_Data','6_Data','7_Data','8_Data','9_Data','10_Data','11_Data','12_Data','13_Data','14_Data','15_Data','16_Data','17_Data','18_Data','19_Data','20_Data'};
% Excluded:
% Not done: 
% Done:'1_Data','2_Data','3_Data','4_Data','5_Data','6_Data','7_Data','8_Data','10_Data','11_Data','12_Data','13_Data','14_Data','15_Data','16_Data','17_Data','18_Data','19_Data','20_Data'
%
nSubj = length(subjIDs);
%
condIDs = {'Head-Fixed','Scene-Fixed'};
nCond = length(condIDs);
%
actpassIDs = {'Active','Passive'};
nActpass = length(actpassIDs);

nTotalTrials = nActpass*nCond*nSubj;

%
% m = zeros(nSubj*nCond*nActpass,3);




row=1;


for subj = 1:nSubj
    plotct=1;
    for cond = 1:nCond
        for actpass = 1:nActpass
            close all;
            
            clearvars -except subj cond actpass subjIDs condIDs actpassIDs nSubj nCond nActpass nTotalTrials plotct row;
            
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
            
            
            
            
            
            %********** Search for graphing data
            
            dirName = strcat('D:\Trials\CD_Data\',subjID,'\',condIDsearch,'\',actpass1ID);
            dirName = char(dirName);
            cd(dirName);
            
            
            % Search for eye position files
            if strcmp(actpass1ID, 'Active 1')
                if ~isempty(dir('*eye_position.txt'))
                    actpass_ID = 'Active 1';
                else
                    actpass_ID = 'Active 2';
                end
                
            elseif strcmp(actpass1ID,'Passive 1')
                
                if ~isempty(dir('*eye_position.txt'))
                    actpass_ID = 'Passive 1';
                else
                    actpass_ID = 'Passive 2';
                end
            end
            
            
            
            dirName = strcat('D:\Trials\CD_Data\',subjID,'\',condIDsearch,'\',actpass_ID);
            dirName = char(dirName);
            cd(dirName);
            
            % Search for Optitrack files
            files_list = dir(dirName);            
            head_search_List = regexpi({files_list.name},'.*head_position.*\.txt', 'match');
            head_Index_Number = find(~cellfun(@isempty,head_search_List));
            head_file_Name = char(head_search_List{head_Index_Number});
            
%             head_search_List2 = regexpi({files_list.name},'.*head_velocity.*\.txt', 'match');
%             head_Index_Number2 = find(~cellfun(@isempty,head_search_List2));
%             head_file_Name2 = char(head_search_List{head_Index_Number2});
%             
%             
            % Search for position trials
            eye_search_List = regexpi({files_list.name},'.*eye_position\.txt', 'match');            
            eye_Index_Number = find(~cellfun(@isempty,eye_search_List));            
            eye_file_Name = char(eye_search_List{eye_Index_Number});
            
%             % Search for velocity trials
%             eye_search_List2 = regexpi({files_list.name},'.*eye_velocity\.txt', 'match');            
%             eye_Index_Number2 = find(~cellfun(@isempty,eye_search_List2));            
%             eye_file_Name2 = char(eye_search_List2{eye_Index_Number2});
%             
%             
            
            Head_Position_Data = import_head_position2(head_file_Name);
            %Head_Velocity_Data = import_head_velocity(head_file_Name2);
            
            Eye_Position_Data = import_eye_position2(eye_file_Name);
            %Eye_Velocity_Data = import_eye_velocity(eye_file_Name2);
            

            J = fillmissing(Head_Position_Data,'movmean',3);
            %K = fillmissing(Head_Velocity_Data,'movmean',3);
            
            
            Eye_Position_Data = fillmissing(Eye_Position_Data,'linear');
            %Eye_Velocity_Data = fillmissing(Eye_Velocity_Data,'linear');
            
            
            head_Position = (Head_Position_Data);            
            %head_velocity = (Head_Velocity_Data);
            
            
            eye_Position = (Eye_Position_Data);            
            %eye_velocity = (Eye_Velocity_Data);
            
            % number of times to smooth
            nSmoothing = 4;
            
        for smoothing = 1:nSmoothing
            for i=1:length(eye_Position)
                eye_Position(i,:)=fastsmooth(eye_Position(i,:),3,1,1);
            end
                               
%             for i=1:length(eye_velocity)
%                 eye_velocity(i,:)=fastsmooth(eye_velocity(i,:),3,1,1);
%             end
            
            for i=1:length(head_Position)
                head_Position(i,:)=fastsmooth(head_Position(i,:),3,1,1);
            end
        end   

            

            
            %eye_velocity_filename = strcat(subjID,'_',condIDsearch,'_',actpass_ID,'_','eye_velocity_smoothed.txt');
            eye_position_filename = strcat(subjID,'_',condIDsearch,'_',actpass_ID,'_','eye_position_smoothed.txt');
            
            %dlmwrite(eye_velocity_filename,eye_velocity,'delimiter','\t','precision',32);
            dlmwrite(eye_position_filename,eye_Position','delimiter','\t','precision',32);
            
            
            
            %head_velocity_filename = strcat(subjID,'_',condIDsearch,'_',actpass_ID,'_','head_velocity_smoothed.txt');
            head_position_filename = strcat(subjID,'_',condIDsearch,'_',actpass_ID,'_','head_position_smoothed.txt');
            
            %dlmwrite(head_velocity_filename,head_velocity','delimiter','\t','precision',32);
            dlmwrite(head_position_filename,head_Position','delimiter','\t','precision',32);
            
            
            
            
            
        end
        
    end
end


%%%%%%%%%%%%%%%%%%%%%%



cd('D:\Trials');