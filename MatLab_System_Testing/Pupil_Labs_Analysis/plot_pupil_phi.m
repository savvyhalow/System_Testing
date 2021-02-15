clear all;
close all;


selpath = uigetdir;
cd(selpath);


filename1 = uigetfile ({'*.csv'},'Pupil Position Data');

[world_timestamp,eye_id,confidence,phi] = import_pupil_Data(filename1);


nEyes = 2; %standard # of eyes per human
stampCntr = ones(1,nEyes); %keep track of how many timestamps we've gotten for each eye

% Parse left and right pupil data
for i = 1:size(world_timestamp)
    if eye_id (i)==1
        eyeInd = stampCntr(2);
        right_pupil_world_timestamp(eyeInd)=world_timestamp(i);      
        right_pupil_eye_id(eyeInd)=eye_id(i);
        right_pupil_confidence(eyeInd)=confidence(i);
        right_pupil_phi(eyeInd)=phi(i);
        stampCntr(2) = stampCntr(2) + 1;
        
    elseif eye_id(i) == 0
        eyeInd = stampCntr(1);
        left_pupil_world_timestamp(eyeInd)=world_timestamp(i);    
        left_pupil_eye_id(eyeInd)=eye_id(i);
        left_pupil_confidence(eyeInd)=confidence(i);
        left_pupil_phi(eyeInd)=phi(i);
        stampCntr(1) = stampCntr(1) + 1;
        
    end
    
end

save('imported_azimuth.mat');


% Find average Confidence of each variable
average_Right_PupilConfidence=mean(right_pupil_confidence);
average_Left_PupilConfidence=mean(left_pupil_confidence);




pupilconfidenceData = figure('Name','Pupil Confidence Level');
axes
hold on
plot(right_pupil_world_timestamp,right_pupil_confidence,'color','b','linewidth',1);
plot(left_pupil_world_timestamp,left_pupil_confidence,'color','r','linewidth',1);
set(gca, 'fontsize',16);
axis([min(right_pupil_world_timestamp) max(right_pupil_world_timestamp) 0 1]);
xlabel('Time');
ylabel('Confidence');
text(450,0.9,num2str(average_Right_PupilConfidence));
text(450,0.8,num2str(average_Left_PupilConfidence));

savefig(pupilconfidenceData,'Pupil Confidence');



Pupil_azimuth_Data = figure('Name','Pupil Azimuth Over Time');
axes
hold on
plot(right_pupil_world_timestamp,right_pupil_phi,'color','b','linewidth',1);
plot(left_pupil_world_timestamp,left_pupil_phi,'color','r','linewidth',1);
set(gca, 'fontsize',16);
axis([min(right_pupil_world_timestamp) max(right_pupil_world_timestamp) -10 10]);
xlabel('Time');
ylabel('Azimuth Position');


savefig(Pupil_azimuth_Data,'Pupil Azimuth');


cd('D:\Trials\MatLab Stuff');