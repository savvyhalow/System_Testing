clear all;
close all;

%%%%%%%%%%%%%%%%%%%%%%
% dirList = {'\data\subj1','\data\subj2'}; %maybe this is the way to go, or...

subjIDs = {'1_Data','2_Data','3_Data','4_Data','5_Data','6_Data','7_Data','8_Data','10_Data','11_Data','12_Data','13_Data','14_Data','15_Data','16_Data','17_Data','18_Data','19_Data','20_Data'};
% Excluded:'9_Data'
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
            
            dirName = strcat('D:\Trials\CD_Data\',subjID,'\',condIDsearch,'\',actpass1ID);
            dirName = char(dirName);
            cd(dirName);
            
            
            [world_timestamp,eye_id,confidence,phi] = import_pupil_azimuth_file('pupil_positions.csv');
            
            confidence=confidence(~isnan(confidence));
            world_timestamp=world_timestamp(~isnan(world_timestamp));
            eye_id=eye_id(~isnan(eye_id));
            phi=phi(~isnan(phi));
            
            
            nEyes = 2; %standard # of eyes per human
            stampCntr = ones(1,nEyes); %keep track of how many timestamps we've gotten for each eye
            
            % Parse left and right pupil data
            for i = 1:size(world_timestamp)
                if eye_id (i)==1
                    eyeInd = stampCntr(2);
                    right_pupil_confidence(eyeInd)=confidence(i);
                    right_pupil_world_timestamp(eyeInd)=world_timestamp(i);
                    right_pupil_eye_id(eyeInd)=eye_id(i);
                    right_pupil_confidence(eyeInd)=confidence(i);
                    right_pupil_phi(eyeInd)=phi(i);
                    
                    
                    stampCntr(2) = stampCntr(2) + 1;
                    
                elseif eye_id(i) == 0
                    eyeInd = stampCntr(1);
                    left_pupil_confidence(eyeInd)=confidence(i);
                    left_pupil_world_timestamp(eyeInd)=world_timestamp(i);
                    left_pupil_eye_id(eyeInd)=eye_id(i);
                    left_pupil_phi(eyeInd)=phi(i);
                    
                    
                    stampCntr(1) = stampCntr(1) + 1;
                else
                    msg = 'Parse Error occurred.';
                    error(msg)
                    
                end
                
            end
            
            
            %************************* Open File 2 & Parse
            
            
            dirName = strcat('D:\Trials\CD_Data\',subjID,'\',condIDsearch,'\',actpass2ID);
            dirName = char(dirName);
            cd(dirName);
            
            
            [world_timestamp,eye_id,confidence,phi] = import_pupil_azimuth_file('pupil_positions.csv');
            
            confidence=confidence(~isnan(confidence));
            world_timestamp=world_timestamp(~isnan(world_timestamp));
            eye_id=eye_id(~isnan(eye_id));
            phi=phi(~isnan(phi));
            
            
            nEyes = 2; %standard # of eyes per human
            stampCntr = ones(1,nEyes); %keep track of how many timestamps we've gotten for each eye
            
            % Parse left and right pupil data
            for i = 1:size(world_timestamp)
                if eye_id (i)==1
                    
                    eyeInd = stampCntr(2);
                    tworight_pupil_confidence(eyeInd)=confidence(i);
                    tworight_pupil_world_timestamp(eyeInd)=world_timestamp(i);
                    tworight_pupil_eye_id(eyeInd)=eye_id(i);
                    tworight_pupil_confidence(eyeInd)=confidence(i);
                    tworight_pupil_phi(eyeInd)=phi(i);
                    
                    
                    
                    stampCntr(2) = stampCntr(2) + 1;
                    
                elseif eye_id(i) == 0
                    eyeInd = stampCntr(1);
                    twoleft_pupil_confidence(eyeInd)=confidence(i);
                    twoleft_pupil_world_timestamp(eyeInd)=world_timestamp(i);
                    twoleft_pupil_eye_id(eyeInd)=eye_id(i);
                    twoleft_pupil_phi(eyeInd)=phi(i);
                    
                    
                    stampCntr(1) = stampCntr(1) + 1;
                else
                    msg = 'Parse 2 Error occurred.';
                    error(msg)
                    
                end
                
            end
            
            
            
            %************************ Establish best confidence
            
            % File 1
            avg_left_pupil_Confidence = mean(left_pupil_confidence);
            avg_right_pupil_Confidence = mean(right_pupil_confidence);
            avg_eye_one_confidence =(avg_left_pupil_Confidence + avg_right_pupil_Confidence)/2;
            
            
            % File 2
            avg_two_left_pupil_Confidence = mean(twoleft_pupil_confidence);
            avg_two_right_pupil_Confidence = mean(tworight_pupil_confidence);
            avg_eye_two_confidence =(avg_two_left_pupil_Confidence + avg_two_right_pupil_Confidence)/2;
            
            
            %*********************** Active file parsing
            
            
            if actpassID == 'Active'
                
                
                %find best average confidence
                
                %If eye one is better
                if avg_eye_one_confidence > avg_eye_two_confidence
                    
                    avg_left_pupil_Confidence = mean(left_pupil_confidence);
                    avg_right_pupil_Confidence = mean(right_pupil_confidence);
                    
                    if avg_right_pupil_Confidence > avg_left_pupil_Confidence
                        pupil_timestamp=right_pupil_world_timestamp';
                        pupil_ID=right_pupil_eye_id;
                        pupil_confidence=right_pupil_confidence;
                        pupil_phi=right_pupil_phi;
                    elseif avg_left_pupil_Confidence > avg_right_pupil_Confidence
                        pupil_timestamp=left_pupil_world_timestamp';
                        pupil_ID=left_pupil_eye_id;
                        pupil_confidence=left_pupil_confidence;
                        pupil_phi=left_pupil_phi;
                    else
                        msg = 'Active Parse Error occurred.';
                        error(msg)
                        
                    end
                    save('importedpupil.mat','pupil_timestamp','pupil_ID','pupil_confidence','pupil_phi');
                    
                    %If eye two is better
                elseif avg_eye_one_confidence < avg_eye_two_confidence
                    
                    avg_left_pupil_Confidence = mean(twoleft_pupil_confidence);
                    avg_right_pupil_Confidence = mean(tworight_pupil_confidence);
                    
                    if avg_right_pupil_Confidence > avg_left_pupil_Confidence
                        pupil_timestamp=tworight_pupil_world_timestamp';
                        pupil_ID=tworight_pupil_eye_id;
                        pupil_confidence=tworight_pupil_confidence;
                        pupil_phi=tworight_pupil_phi;
                    elseif avg_left_pupil_Confidence > avg_right_pupil_Confidence
                        pupil_timestamp=twoleft_pupil_world_timestamp';
                        pupil_ID=twoleft_pupil_eye_id;
                        pupil_confidence=twoleft_pupil_confidence;
                        pupil_phi=twoleft_pupil_phi;
                    else
                        msg = 'Active Parse 2 Error occurred.';
                        error(msg)
                        
                    end
                    save('importedpupil.mat','pupil_timestamp','pupil_ID','pupil_confidence','pupil_phi');
                end
                %save('importedpupil.mat','pupil_timestamp','pupil_ID','pupil_confidence','pupil_phi');
            end
            
            
            
            
            %*********************** Passive file parsing
            
            
            
            if actpassID == 'Passive'
                %find best average confidence
                
                %If eye one is better
                if avg_eye_one_confidence > avg_eye_two_confidence
                    
                    avg_left_pupil_Confidence = mean(left_pupil_confidence);
                    avg_right_pupil_Confidence = mean(right_pupil_confidence);
                    
                    if avg_right_pupil_Confidence > avg_left_pupil_Confidence
                        pupil_timestamp=right_pupil_world_timestamp';
                        pupil_ID=right_pupil_eye_id;
                        pupil_confidence=right_pupil_confidence;
                        pupil_phi=right_pupil_phi;
                    elseif avg_left_pupil_Confidence > avg_right_pupil_Confidence
                        pupil_timestamp=left_pupil_world_timestamp';
                        pupil_ID=left_pupil_eye_id;
                        pupil_confidence=left_pupil_confidence;
                        pupil_phi=left_pupil_phi;
                    else
                        msg = 'Passive Parse Error occurred.';
                        error(msg)
                        
                        
                    end
                    save('importedpupil.mat','pupil_timestamp','pupil_ID','pupil_confidence','pupil_phi');
                    
                    %If eye two is better
                elseif avg_eye_one_confidence < avg_eye_two_confidence
                    
                    avg_left_pupil_Confidence = mean(twoleft_pupil_confidence);
                    avg_right_pupil_Confidence = mean(tworight_pupil_confidence);
                    
                    if avg_right_pupil_Confidence > avg_left_pupil_Confidence
                        pupil_timestamp=tworight_pupil_world_timestamp';
                        pupil_ID=tworight_pupil_eye_id;
                        pupil_confidence=tworight_pupil_confidence;
                        pupil_phi=tworight_pupil_phi;
                    elseif avg_left_pupil_Confidence > avg_right_pupil_Confidence
                        pupil_timestamp=twoleft_pupil_world_timestamp';
                        pupil_ID=twoleft_pupil_eye_id;
                        pupil_confidence=twoleft_pupil_confidence;
                        pupil_phi=twoleft_pupil_phi;
                    else
                        msg = 'Passive 2 Parse Error occurred.';
                        error(msg)
                    end
                    save('importedpupil.mat','pupil_timestamp','pupil_ID','pupil_confidence','pupil_phi');
                end
                %save('importedpupil.mat','pupil_timestamp','pupil_ID','pupil_confidence','pupil_phi');
            end
            
        end
        
        %save('importedpupil.mat','pupil_timestamp','pupil_ID','pupil_confidence','pupil_phi');
        
    end
end



cd('D:\MATLAB');