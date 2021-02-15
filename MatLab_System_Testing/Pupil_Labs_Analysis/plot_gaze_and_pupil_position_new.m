clear all;
close all;


selpath = uigetdir;
cd(selpath);


filename1 = uigetfile ({'*.csv'},'Pupil Position Data');

% filename2 = uigetfile ({'*.csv'},'Gaze Position Data');


[world_timestamp,world_index,eye_id,confidence,circle_3d_center_x,circle_3d_center_y,circle_3d_center_z] = import_pupil_center_position(filename1);


nEyes = 2; %standard # of eyes per human
stampCntr = ones(1,nEyes); %keep track of how many timestamps we've gotten for each eye

% Parse left and right pupil data
for i = 1:size(world_timestamp)
    if eye_id (i)==1
        eyeInd = stampCntr(2);
        right_pupil_world_timestamp(eyeInd) = world_timestamp(i);
        right_pupil_world_index(eyeInd) = world_index(i);
        right_pupil_eye_id(eyeInd) = eye_id(i);
        right_pupil_confidence(eyeInd) = confidence(i);
        right_pupil_circle_3d_center_x(eyeInd) =circle_3d_center_x(i);
        right_pupil_circle_3d_center_y(eyeInd) =circle_3d_center_y(i);
        right_pupil_circle_3d_center_z(eyeInd) =circle_3d_center_z(i);

        stampCntr(2) = stampCntr(2) + 1;
        
    elseif eye_id(i) == 0
        eyeInd = stampCntr(1);
        left_pupil_world_timestamp(eyeInd) = world_timestamp(i);
        left_pupil_world_index(eyeInd) = world_index(i);
        left_pupil_eye_id(eyeInd) = eye_id(i);
        left_pupil_confidence(eyeInd) = confidence(i);
        left_pupil_circle_3d_center_x(eyeInd) =circle_3d_center_x(i);
        left_pupil_circle_3d_center_y(eyeInd) =circle_3d_center_y(i);
        left_pupil_circle_3d_center_z(eyeInd) =circle_3d_center_z(i);

        stampCntr(2) = stampCntr(1) + 1;
        
    end
    
end



% %
% [world_timestamp,world_index,eye_id,confidence,circle_3d_center_x,circle_3d_center_y,circle_3d_center_z] = import_All_Gaze_Data(filename2);
% 
% % Define Gaze Data
%         gaze_pupil_world_timestamp(eyeInd) = world_timestamp(i);
%         gaze_pupil_world_index(eyeInd) = world_index(i);
%         gaze_pupil_eye_id(eyeInd) = eye_id(i);
%         gaze_pupil_confidence(eyeInd) = confidence(i);
%         gaze_pupil_circle_3d_center_x(eyeInd) =circle_3d_center_x(i);
%         gaze_pupil_circle_3d_center_y(eyeInd) =circle_3d_center_y(i);
%         gaze_pupil_circle_3d_center_z(eyeInd) =circle_3d_center_z(i);
% 

% Convert right pupil data to azimuth and elevation
% [right_pupil_azimuth,right_pupil_elevation,right_pupil_r] = cart2sph(right_pupil_circle_3d_normal_x,right_pupil_circle_3d_normal_y,right_pupil_circle_3d_normal_z);
% 
% % Do the same for left and gaze
% [left_pupil_azimuth,left_pupil_elevation,left_pupil_r] = cart2sph(left_pupil_circle_3d_normal_x,left_pupil_circle_3d_normal_y,left_pupil_circle_3d_normal_z);
% 
% % [gaze_azimuth,gaze_elevation,gaze_r] = cart2sph(gaze_circle_3d_normal_x,gaze_circle_3d_normal_y,gaze_circle_3d_normal_z);


save('imported_azimuth_elevation.mat');


% Find average Confidence of each variable
average_Right_PupilConfidence=mean(right_pupil_confidence);
average_Left_PupilConfidence=mean(left_pupil_confidence);
% averageGazeConfidence=mean(gaze_confidence);



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



% gazeconfidenceData = figure('Name','GazeConfidence Level');
% axes
% hold on
% plot(gaze_world_timestamp,gaze_confidence,'color',[0 .7 0],'linewidth',1);
% set(gca, 'fontsize',16);
% axis([min(gaze_world_timestamp) max(gaze_world_timestamp) 0 1]);
% xlabel('Time');
% ylabel('Confidence');
% text(450,0.9,num2str(averageGazeConfidence));
% 
% 
% savefig(gazeconfidenceData,'Gaze Confidence');





Pupil_azimuth_Data = figure('Name','Pupil Azimuth Over Time');
axes
hold on
plot(right_pupil_world_timestamp,right_pupil_azimuth,'color','b','linewidth',1);
plot(left_pupil_world_timestamp,left_pupil_azimuth,'color','r','linewidth',1);
set(gca, 'fontsize',16);
axis([min(right_pupil_world_timestamp) max(right_pupil_world_timestamp) -10 10]);
xlabel('Time');
ylabel('Azimuth Position');


savefig(PupilxpositionData,'Pupil Azimuth');




% Gaze_azimuth_positionData = figure('Name','Gaze Azimuth Position Over Time');
% axes
% hold on
% plot(gaze_world_timestamp,gaze_azimuth,'color',[0 .7 0],'linewidth',1);
% set(gca, 'fontsize',16);
% axis([min(gaze_world_timestamp) max(gaze_world_timestamp) -100 100]);
% xlabel('Time');
% ylabel('Azimuth Position');
% 
% 
% savefig(Gaze_azimuth_positionData,'Gaze Azimuth');






PupilypositionData = figure('Name','Pupil Elevation Over Time');
axes
hold on
plot(right_pupil_world_timestamp,right_pupil_elevation,'color','b','linewidth',1);
plot(left_pupil_world_timestamp,left_pupil_elevation,'color','r','linewidth',1);
set(gca, 'fontsize',16);
axis([min(right_pupil_world_timestamp) max(right_pupil_world_timestamp) -10 10]);
xlabel('Time');
ylabel('Elevation Position');


savefig(PupilypositionData,'Pupil Elevation');




% GazeypositionData = figure('Name','Gaze Elevation Over Time');
% axes
% hold on
% axis([min(gaze_world_timestamp) max(gaze_world_timestamp) 0 100]);
% plot(gaze_world_timestamp,gaze_elevation,'color',[0 .7 0],'linewidth',1);
% set(gca, 'fontsize',16);
% axis([min(gaze_world_timestamp) max(gaze_world_timestamp) -100 100]);
% xlabel('Time');
% ylabel('Elevation Position');
% 
% 
% savefig(GazeypositionData,'Gaze Elevation Position');

cd('D:\Trials\MatLab Stuff');