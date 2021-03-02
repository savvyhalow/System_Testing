clear all;
close all;

%%%%%%%%%%%%%%%%%%%%%%
subjIDs = {'14_Data','15_Data','16_Data','17_Data','18_Data','19_Data','20_Data'};
% Excluded:'9_Data'
% Complete: '1_Data','2_Data','3_Data','4_Data','5_Data','6_Data','7_Data','8_Data','10_Data','11_Data','12_Data','13_Data',
nSubj = length(subjIDs);
condIDs = {'Head-Fixed','Scene-Fixed'};
nCond = length(condIDs);
actpassIDs = {'Active','Passive'};
nActpass = length(actpassIDs);
nTotalTrials = nActpass*nCond*nSubj;

for subj = 1:nSubj
    for cond = 1:nCond
        for actpass = 1:nActpass
            clearvars -except subj cond actpass subjIDs condIDs actpassIDs nSubj nCond nActpass nTotalTrials plotct pupil_timestamp pupil_ID pupil_confidence pupil_phi;
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
            dirName = strcat('E:\Box Sync\Box Sync\SelfMotion Lab\Projects\Conf_Detect_Head_Eye\Conf_Detect_Head_Eye_ResponseOnly\Data_Collection\',subjID,'\',condIDsearch,'\',actpass1ID);
            dirName = char(dirName);
            cd(dirName);
            
            [world_timestamp,eye_id,confidence,phi] = import_pupil_azimuth_file('pupil_positions.csv');
            [world_timestamp,world_index,eye_id,confidence,circle_3d_center_x,circle_3d_center_y,circle_3d_center_z] = import_pupil_center_position('pupil_positions.csv');
            %https://docs.pupil-labs.com/#detailed-data-format
            %circle_3d_center_x - x center of the pupil as 3d circle in eye pinhole camera 3d space units are mm.
            %circle_3d_center_y - y center of the pupil as 3d circle
            %circle_3d_center_z - z center of the pupil as 3d circle
            
            confidence=confidence(~isnan(confidence));
            world_timestamp=world_timestamp(~isnan(world_timestamp));
            eye_id=eye_id(~isnan(eye_id));
            phi=phi(~isnan(phi));
            
            % Parse left and right pupil data - truncate recording to only
            % be as long as the shortest number of data points
            
            
            nEyes = 2; %standard # of eyes per human
            stampCntr = ones(1,nEyes); %keep track of how many timestamps we've gotten for each eye
            for i = 1:size(world_timestamp)
                if eye_id (i)==1
                    eyeInd = stampCntr(2);
                    right_pupil_confidence(eyeInd)=confidence(i);
                    right_pupil_world_timestamp(eyeInd)=world_timestamp(i);
                    right_pupil_eye_id(eyeInd)=eye_id(i);
                    right_pupil_confidence(eyeInd)=confidence(i);
                    right_pupil_phi(eyeInd)=phi(i);
                    right_pupil_circle_3d_center_x(eyeInd) =circle_3d_center_x(i);
                    right_pupil_circle_3d_center_y(eyeInd) =circle_3d_center_y(i);
                    right_pupil_circle_3d_center_z(eyeInd) =circle_3d_center_z(i);
                    stampCntr(2) = stampCntr(2) + 1;
                elseif eye_id(i) == 0
                    eyeInd = stampCntr(1);
                    left_pupil_confidence(eyeInd)=confidence(i);
                    left_pupil_world_timestamp(eyeInd)=world_timestamp(i);
                    left_pupil_eye_id(eyeInd)=eye_id(i);
                    left_pupil_phi(eyeInd)=phi(i);
                    left_pupil_circle_3d_center_x(eyeInd) =circle_3d_center_x(i);
                    left_pupil_circle_3d_center_y(eyeInd) =circle_3d_center_y(i);
                    left_pupil_circle_3d_center_z(eyeInd) =circle_3d_center_z(i);
                    stampCntr(1) = stampCntr(1) + 1;
                else
                    msg = 'Parse Error occurred.';
                    error(msg)
                end
            end
            
            
            % Pad arrays to match sizes
%                if length(right_pupil_eye_id) < length(left_pupil_eye_id)
%                     
%                     right_pupil_eye_id = padarray(right_pupil_eye_id,length(left_pupil_eye_id),'pre');
%                     right_pupil_world_timestamp = padarray(right_pupil_world_timestamp,length(left_pupil_eye_id),'pre');
%                     right_pupil_confidence = padarray(right_pupil_confidence,length(left_pupil_eye_id),'pre');                
%                     right_pupil_circle_3d_center_x = padarray(right_pupil_circle_3d_center_x,length(left_pupil_eye_id),'pre');                    
%                     right_pupil_circle_3d_center_y = padarray(right_pupil_circle_3d_center_y,length(left_pupil_eye_id),'pre');                    
%                     right_pupil_circle_3d_center_z = padarray(right_pupil_phi,length(left_pupil_eye_id),'pre');                    
%                     right_pupil_phi = padarray(right_pupil_confidence,length(left_pupil_eye_id),'pre');
% 
%                 elseif length(right_pupil_eye_id) > length(left_pupil_eye_id)
%                     
%                     left_pupil_eye_id = padarray(left_pupil_eye_id,length(right_pupil_eye_id),'pre');
%                     left_pupil_world_timestamp = padarray(left_pupil_world_timestamp,length(right_pupil_eye_id),'pre');
%                     left_pupil_confidence = padarray(left_pupil_confidence,length(right_pupil_eye_id),'pre');
%                     left_pupil_circle_3d_center_x = padarray(left_pupil_circle_3d_center_x,length(right_pupil_eye_id),'pre');
%                     left_pupil_circle_3d_center_y = padarray(left_pupil_circle_3d_center_y,length(right_pupil_eye_id),'pre');
%                     left_pupil_circle_3d_center_z = padarray(left_pupil_circle_3d_center_z,length(right_pupil_eye_id),'pre');
%                     left_pupil_phi = padarray(left_pupil_phi,length(right_pupil_eye_id),'pre');
%                     
%                 end
%             
            
            
%             % Gaze Data
%             [world_timestamp,world_index,eye_id,confidence,circle_3d_center_x,circle_3d_center_y,circle_3d_center_z] = import_All_Gaze_Data(gaze_file);
%             gaze_pupil_world_timestamp(eyeInd) = world_timestamp(i);
%             gaze_pupil_world_index(eyeInd) = world_index(i);
%             gaze_pupil_eye_id(eyeInd) = eye_id(i);
%             gaze_pupil_confidence(eyeInd) = confidence(i);
%             gaze_pupil_circle_3d_center_x(eyeInd) =circle_3d_center_x(i);
%             gaze_pupil_circle_3d_center_y(eyeInd) =circle_3d_center_y(i);
%             gaze_pupil_circle_3d_center_z(eyeInd) =circle_3d_center_z(i);
            

            avg_left_pupil_Confidence = mean(left_pupil_confidence);
            avg_right_pupil_Confidence = mean(right_pupil_confidence);
            avg_total_confidence =(avg_left_pupil_Confidence + avg_right_pupil_Confidence)/2;
            
            for i = 1:size(world_timestamp)
                adjusted_time2(:) = world_timestamp(:) - world_timestamp(1);            
            end
            recording_length = adjusted_time2(end);
            avg_fps = length(world_timestamp)/recording_length;

            dirName = strcat('E:\Box Sync\Box Sync\SelfMotion Lab\Projects\Conf_Detect_Head_Eye\EyeData_Only');
            dirName = char(dirName);
            cd(dirName);
            
            fileName = strcat(subjID,'_', condID,'_', actpass1ID,'_', 'imported_pupil.mat');
            save(fileName);
            
            fileName2 = strcat(subjID,'_', condID,'_', actpass1ID,'_', 'pupil_stats.xlsx');
            eye_conf_Data = table(recording_length,avg_total_confidence,avg_right_pupil_Confidence,avg_left_pupil_Confidence,avg_fps);
            writetable(eye_conf_Data,fileName2,'Sheet',1); 

            
            
            %************************* Open File 2 & Parse
            dirName = strcat('E:\Box Sync\Box Sync\SelfMotion Lab\Projects\Conf_Detect_Head_Eye\Conf_Detect_Head_Eye_ResponseOnly\Data_Collection\',subjID,'\',condIDsearch,'\',actpass2ID);
            dirName = char(dirName);
            cd(dirName);
            
            [world_timestamp,eye_id,confidence,phi] = import_pupil_azimuth_file('pupil_positions.csv');
            [world_timestamp,world_index,eye_id,confidence,circle_3d_center_x,circle_3d_center_y,circle_3d_center_z] = import_pupil_center_position('pupil_positions.csv');
            %https://docs.pupil-labs.com/#detailed-data-format
            %circle_3d_center_x - x center of the pupil as 3d circle in eye pinhole camera 3d space units are mm.
            %circle_3d_center_y - y center of the pupil as 3d circle
            %circle_3d_center_z - z center of the pupil as 3d circle
            
            confidence=confidence(~isnan(confidence));
            world_timestamp=world_timestamp(~isnan(world_timestamp));
            eye_id=eye_id(~isnan(eye_id));
            phi=phi(~isnan(phi));
            
            % Parse left and right pupil data
            nEyes = 2; %standard # of eyes per human
            stampCntr = ones(1,nEyes); %keep track of how many timestamps we've gotten for each eye
            for i = 1:size(world_timestamp)
                if eye_id (i)==1
                    eyeInd = stampCntr(2);
                    right_pupil_confidence(eyeInd)=confidence(i);
                    right_pupil_world_timestamp(eyeInd)=world_timestamp(i);
                    right_pupil_eye_id(eyeInd)=eye_id(i);
                    right_pupil_confidence(eyeInd)=confidence(i);
                    right_pupil_phi(eyeInd)=phi(i);
                    right_pupil_circle_3d_center_x(eyeInd) =circle_3d_center_x(i);
                    right_pupil_circle_3d_center_y(eyeInd) =circle_3d_center_y(i);
                    right_pupil_circle_3d_center_z(eyeInd) =circle_3d_center_z(i);
                    stampCntr(2) = stampCntr(2) + 1;
                elseif eye_id(i) == 0
                    eyeInd = stampCntr(1);
                    left_pupil_confidence(eyeInd)=confidence(i);
                    left_pupil_world_timestamp(eyeInd)=world_timestamp(i);
                    left_pupil_eye_id(eyeInd)=eye_id(i);
                    left_pupil_phi(eyeInd)=phi(i);
                    left_pupil_circle_3d_center_x(eyeInd) =circle_3d_center_x(i);
                    left_pupil_circle_3d_center_y(eyeInd) =circle_3d_center_y(i);
                    stampCntr(1) = stampCntr(1) + 1;
                else
                    msg = 'Parse 2 Error occurred.';
                    error(msg)
                end
            end
            
%             % Gaze Data
%             [world_timestamp,world_index,eye_id,confidence,circle_3d_center_x,circle_3d_center_y,circle_3d_center_z] = import_All_Gaze_Data(gaze_file);
%             gaze_pupil_world_timestamp(eyeInd) = world_timestamp(i);
%             gaze_pupil_world_index(eyeInd) = world_index(i);
%             gaze_pupil_eye_id(eyeInd) = eye_id(i);
%             gaze_pupil_confidence(eyeInd) = confidence(i);
%             gaze_pupil_circle_3d_center_x(eyeInd) =circle_3d_center_x(i);
%             gaze_pupil_circle_3d_center_y(eyeInd) =circle_3d_center_y(i);
%             gaze_pupil_circle_3d_center_z(eyeInd) =circle_3d_center_z(i);
            
            avg_left_pupil_Confidence = mean(left_pupil_confidence);
            avg_right_pupil_Confidence = mean(right_pupil_confidence);
            avg_total_confidence =(avg_left_pupil_Confidence + avg_right_pupil_Confidence)/2;
            
            for i = 1:size(world_timestamp)
                adjusted_time(:) = world_timestamp(:) - world_timestamp(1);            
            end
            recording_length = adjusted_time(end);
            avg_fps = size(world_timestamp)/recording_length;

            dirName = strcat('E:\Box Sync\Box Sync\SelfMotion Lab\Projects\Conf_Detect_Head_Eye\EyeData_Only');
            dirName = char(dirName);
            cd(dirName);
            
            fileName3 = strcat(subjID,'_', condID,'_', actpass2ID,'_', 'imported_pupil.mat');
            save(fileName3);
            
            fileName4 = strcat(subjID,'_', condID,'_', actpass2ID,'_', 'pupil_stats.xlsx');
            eye_conf_Data = table(recording_length,avg_total_confidence,avg_right_pupil_Confidence,avg_left_pupil_Confidence,avg_fps);
            writetable(eye_conf_Data,fileName4,'Sheet',1); 

            
            
            %************************ Establish best confidence
            %             % File 1
            %             avg_left_pupil_Confidence = mean(left_pupil_confidence);
            %             avg_right_pupil_Confidence = mean(right_pupil_confidence);
            %             avg_eye_one_confidence =(avg_left_pupil_Confidence + avg_right_pupil_Confidence)/2;
            %
            %
            %             % File 2
            %             avg_two_left_pupil_Confidence = mean(twoleft_pupil_confidence);
            %             avg_two_right_pupil_Confidence = mean(tworight_pupil_confidence);
            %             avg_eye_two_confidence =(avg_two_left_pupil_Confidence + avg_two_right_pupil_Confidence)/2;
            %
            %
            %             %*********************** Active file parsing
            %             if actpassID == 'Active'
            %                 %find best average confidence
            %                 %If eye one is better
            %                 if avg_eye_one_confidence > avg_eye_two_confidence
            %                     avg_left_pupil_Confidence = mean(left_pupil_confidence);
            %                     avg_right_pupil_Confidence = mean(right_pupil_confidence);
            %                     if avg_right_pupil_Confidence > avg_left_pupil_Confidence
            %                         pupil_timestamp=right_pupil_world_timestamp';
            %                         pupil_ID=right_pupil_eye_id;
            %                         pupil_confidence=right_pupil_confidence;
            %                         pupil_phi=right_pupil_phi;
            %                     elseif avg_left_pupil_Confidence > avg_right_pupil_Confidence
            %                         pupil_timestamp=left_pupil_world_timestamp';
            %                         pupil_ID=left_pupil_eye_id;
            %                         pupil_confidence=left_pupil_confidence;
            %                         pupil_phi=left_pupil_phi;
            %                     else
            %                         msg = 'Active Parse Error occurred.';
            %                         error(msg)
            %                     end
            %                     save('importedpupil.mat','pupil_timestamp','pupil_ID','pupil_confidence','pupil_phi');
            %                     %If eye two is better
            %                 elseif avg_eye_one_confidence < avg_eye_two_confidence
            %                     avg_left_pupil_Confidence = mean(twoleft_pupil_confidence);
            %                     avg_right_pupil_Confidence = mean(tworight_pupil_confidence);
            %                     if avg_right_pupil_Confidence > avg_left_pupil_Confidence
            %                         pupil_timestamp=tworight_pupil_world_timestamp';
            %                         pupil_ID=tworight_pupil_eye_id;
            %                         pupil_confidence=tworight_pupil_confidence;
            %                         pupil_phi=tworight_pupil_phi;
            %                     elseif avg_left_pupil_Confidence > avg_right_pupil_Confidence
            %                         pupil_timestamp=twoleft_pupil_world_timestamp';
            %                         pupil_ID=twoleft_pupil_eye_id;
            %                         pupil_confidence=twoleft_pupil_confidence;
            %                         pupil_phi=twoleft_pupil_phi;
            %                     else
            %                         msg = 'Active Parse 2 Error occurred.';
            %                         error(msg)
            %                     end
            %                     save('importedpupil.mat','pupil_timestamp','pupil_ID','pupil_confidence','pupil_phi');
            %                 end
            %                 %save('importedpupil.mat','pupil_timestamp','pupil_ID','pupil_confidence','pupil_phi');
            %             end
            %
            %             %*********************** Passive file parsing
            %             if actpassID == 'Passive'
            %                 %find best average confidence
            %                 %If eye one is better
            %                 if avg_eye_one_confidence > avg_eye_two_confidence
            %                     avg_left_pupil_Confidence = mean(left_pupil_confidence);
            %                     avg_right_pupil_Confidence = mean(right_pupil_confidence);
            %                     if avg_right_pupil_Confidence > avg_left_pupil_Confidence
            %                         pupil_timestamp=right_pupil_world_timestamp';
            %                         pupil_ID=right_pupil_eye_id;
            %                         pupil_confidence=right_pupil_confidence;
            %                         pupil_phi=right_pupil_phi;
            %                     elseif avg_left_pupil_Confidence > avg_right_pupil_Confidence
            %                         pupil_timestamp=left_pupil_world_timestamp';
            %                         pupil_ID=left_pupil_eye_id;
            %                         pupil_confidence=left_pupil_confidence;
            %                         pupil_phi=left_pupil_phi;
            %                     else
            %                         msg = 'Passive Parse Error occurred.';
            %                         error(msg)
            %                     end
            %                     save('importedpupil.mat','pupil_timestamp','pupil_ID','pupil_confidence','pupil_phi');
            %                     %If eye two is better
            %                 elseif avg_eye_one_confidence < avg_eye_two_confidence
            %                     avg_left_pupil_Confidence = mean(twoleft_pupil_confidence);
            %                     avg_right_pupil_Confidence = mean(tworight_pupil_confidence);
            %                     if avg_right_pupil_Confidence > avg_left_pupil_Confidence
            %                         pupil_timestamp=tworight_pupil_world_timestamp';
            %                         pupil_ID=tworight_pupil_eye_id;
            %                         pupil_confidence=tworight_pupil_confidence;
            %                         pupil_phi=tworight_pupil_phi;
            %                     elseif avg_left_pupil_Confidence > avg_right_pupil_Confidence
            %                         pupil_timestamp=twoleft_pupil_world_timestamp';
            %                         pupil_ID=twoleft_pupil_eye_id;
            %                         pupil_confidence=twoleft_pupil_confidence;
            %                         pupil_phi=twoleft_pupil_phi;
            %                     else
            %                         msg = 'Passive 2 Parse Error occurred.';
            %                         error(msg)
            %                     end
            %                     save('importedpupil.mat','pupil_timestamp','pupil_ID','pupil_confidence','pupil_phi');
            %                 end
            %                 %save('importedpupil.mat','pupil_timestamp','pupil_ID','pupil_confidence','pupil_phi');
            %             end
            
        end
        %         %save('importedpupil.mat','pupil_timestamp','pupil_ID','pupil_confidence','pupil_phi');
    end
end



% cd('D:\MATLAB');