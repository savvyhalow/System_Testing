clear all;
close all;


selpath = uigetdir;
cd(selpath);


filename1 = uigetfile ({'*.csv'},'Pupil Position Data');



[world_timestamp,eye_id,confidence,norm_pos_x,phi] = import_pupil_posit_confidence(filename1);



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
        %         right_pupil_diameter(eyeInd)=diameter_3d(i);
        stampCntr(2) = stampCntr(2) + 1;
        
    elseif eye_id(i) == 0
        eyeInd = stampCntr(1);
        left_pupil_world_timestamp(eyeInd)=world_timestamp(i);
        left_pupil_eye_id(eyeInd)=eye_id(i);
        left_pupil_confidence(eyeInd)=confidence(i);
        left_pupil_phi(eyeInd)=phi(i);
        %         left_pupil_diameter(eyeInd)=diameter_3d(i);
        stampCntr(1) = stampCntr(1) + 1;
        
    end
    
end

save('imported_pupil_confidence_data.mat');


% Find average Confidence of each variable
average_Right_PupilConfidence=mean(right_pupil_confidence);
average_Left_PupilConfidence=mean(left_pupil_confidence);

% convert azimuth to radians
left_pupil_degrees = radtodeg(left_pupil_phi);
left_pupil_degrees = abs(left_pupil_degrees);
right_pupil_degrees = radtodeg(right_pupil_phi);


%Set new time
new_right_pupil_Time=right_pupil_world_timestamp-min(right_pupil_world_timestamp);
new_left_pupil_Time=left_pupil_world_timestamp-min(left_pupil_world_timestamp);

% shift right pupil to zero point
avg_right_pupil_degrees = mean(right_pupil_degrees);
right_pupil_degrees = right_pupil_degrees-avg_right_pupil_degrees;

% shift left pupil to zero point
avg_left_pupil_degrees = mean(left_pupil_degrees);
left_pupil_degrees = left_pupil_degrees-avg_left_pupil_degrees;


% upscale confidence
right_pupil_confidence = right_pupil_confidence*100;
left_pupil_confidence = left_pupil_confidence*100;

figure('Name','Right Pupil Azimuth Over Time');
% axes
hold on
plot(new_right_pupil_Time,right_pupil_degrees,'color',[0, 0.4470, 0.7410],'linewidth',0.5);
plot(new_right_pupil_Time,right_pupil_confidence,'color',[0.4660, 0.6740, 0.1880],'linewidth',0.5);
set(gca, 'fontsize',16);
axis([min(new_right_pupil_Time) max(new_right_pupil_Time) -360 360]);
xlabel('Time');
ylabel('Confidence vs Degrees');
text(40,0.9,num2str(average_Right_PupilConfidence));


figure('Name','Left Pupil Azimuth Over Time');
% axes
hold on
plot(new_left_pupil_Time,left_pupil_degrees,'color',[0, 0.4470, 0.7410],'linewidth',0.5);
plot(new_left_pupil_Time,left_pupil_confidence,'color',[0.4660, 0.6740, 0.1880],'linewidth',0.5);

set(gca, 'fontsize',16);
axis([min(new_left_pupil_Time) max(new_left_pupil_Time) -360 360]);
xlabel('Time');
ylabel('Left Confidence vs Degrees');
text(40,50,num2str(average_Right_PupilConfidence));
text(50,100,num2str(average_Left_PupilConfidence));






cd('D:\MATLAB');