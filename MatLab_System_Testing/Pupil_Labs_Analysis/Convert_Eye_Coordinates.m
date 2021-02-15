function Convert_Eye_Coordinates

selpath = uigetdir;
cd(selpath);

% pupil data file
filename1 = uigetfile ({'*.csv'},'Pupil Data File');

% gaze data file
filename2 = uigetfile ({'*.csv'},'Gaze Data File');

[world_timestamp,world_index,eye_id,confidence,norm_pos_x,norm_pos_y,diameter,method,ellipse_center_x,ellipse_center_y,ellipse_axis_a,ellipse_axis_b,ellipse_angle,diameter_3d,model_confidence,model_id,sphere_center_x,sphere_center_y,sphere_center_z,sphere_radius,circle_3d_center_x,circle_3d_center_y,circle_3d_center_z,circle_3d_normal_x,circle_3d_normal_y,circle_3d_normal_z,circle_3d_radius,theta,phi,projected_sphere_center_x,projected_sphere_center_y,projected_sphere_axis_a,projected_sphere_axis_b,projected_sphere_angle] = import_All_Pupil_Data(filename1);


% Parse left and right pupil data
for i = 1:size(world_timestamp)
    if id (i)==1
        eyeInd = stampCntr(2);
        right_pupil_world_timestamp(eyeInd) = world_timestamp(i);
        right_pupil_world_index(eyeInd) = world_index(i);
        right_pupil_eye_id(eyeInd) = eye_id(i);
        right_pupil_confidence(eyeInd) = confidence(i);
        right_pupil_norm_pos_x(eyeInd) = norm_pos_x(i);
        right_pupil_norm_pos_y(eyeInd) = norm_pos_y(i);
        right_pupil_diameter(eyeInd) = diameter(i);
        right_pupil_method(eyeInd) = method(i); 
        right_pupil_ellipse_center_x(eyeInd) =ellipse_center_x(i);
        right_pupil_ellipse_center_y(eyeInd) =ellipse_center_y(i);
        right_pupil_ellipse_axis_a(eyeInd) =ellipse_axis_a(i);
        right_pupil_ellipse_axis_b(eyeInd) =ellipse_axis_b(i);
        right_pupil_ellipse_angle(eyeInd) =ellipse_angle(i);
        right_pupil_diameter_3d(eyeInd) =diameter_3d(i);
        right_pupil_model_confidence(eyeInd) =model_confidence(i);
        right_pupil_model_id(eyeInd) =model_id(i);
        right_pupil_sphere_center_x(eyeInd) =sphere_center_x(i);
        right_pupil_sphere_center_y(eyeInd) =sphere_center_y(i);
        right_pupil_sphere_center_z(eyeInd) =sphere_center_z(i);
        right_pupil_sphere_radius(eyeInd) =sphere_radius(i);
        right_pupil_circle_3d_center_x(eyeInd) =circle_3d_center_x(i);
        right_pupil_circle_3d_center_y(eyeInd) =circle_3d_center_y(i);
        right_pupil_circle_3d_center_z(eyeInd) =circle_3d_center_z(i);
        right_pupil_circle_3d_normal_x(eyeInd) =circle_3d_normal_x(i);
        right_pupil_circle_3d_normal_y(eyeInd) =circle_3d_normal_y(i);
        right_pupil_circle_3d_normal_z(eyeInd) =circle_3d_normal_z(i);
        right_pupil_circle_3d_radius(eyeInd) =circle_3d_radius(i);
        right_pupil_theta(eyeInd) =theta(i);
        right_pupil_phi(eyeInd) =phi(i);
        right_pupil_projected_sphere_center_x(eyeInd) =projected_sphere_center_x(i);
        right_pupil_projected_sphere_center_y(eyeInd) =projected_sphere_center_y(i);
        right_pupil_projected_sphere_axis_a(eyeInd) =projected_sphere_axis_a(i);
        right_pupil_projected_sphere_axis_b(eyeInd) =projected_sphere_axis_b(i);
        right_pupil_projected_sphere_angle(eyeInd) =projected_sphere_angle(i);
        stampCntr(2) = stampCntr(2) + 1;
        
    elseif id(i) == 0
        eyeInd = stampCntr(1);
        left_pupil_world_timestamp(eyeInd) = world_timestamp(i);
        left_pupil_world_index(eyeInd) = world_index(i);
        left_pupil_eye_id(eyeInd) = eye_id(i);
        left_pupil_confidence(eyeInd) = confidence(i);
        left_pupil_norm_pos_x(eyeInd) = norm_pos_x(i);
        left_pupil_norm_pos_y(eyeInd) = norm_pos_y(i);
        left_pupil_diameter(eyeInd) = diameter(i);
        left_pupil_method(eyeInd) = method(i); 
        left_pupil_ellipse_center_x(eyeInd) =ellipse_center_x(i);
        left_pupil_ellipse_center_y(eyeInd) =ellipse_center_y(i);
        left_pupil_ellipse_axis_a(eyeInd) =ellipse_axis_a(i);
        left_pupil_ellipse_axis_b(eyeInd) =ellipse_axis_b(i);
        left_pupil_ellipse_angle(eyeInd) =ellipse_angle(i);
        left_pupil_diameter_3d(eyeInd) =diameter_3d(i);
        left_pupil_model_confidence(eyeInd) =model_confidence(i);
        left_pupil_model_id(eyeInd) =model_id(i);
        left_pupil_sphere_center_x(eyeInd) =sphere_center_x(i);
        left_pupil_sphere_center_y(eyeInd) =sphere_center_y(i);
        left_pupil_sphere_center_z(eyeInd) =sphere_center_z(i);
        left_pupil_sphere_radius(eyeInd) =sphere_radius(i);
        left_pupil_circle_3d_center_x(eyeInd) =circle_3d_center_x(i);
        left_pupil_circle_3d_center_y(eyeInd) =circle_3d_center_y(i);
        left_pupil_circle_3d_center_z(eyeInd) =circle_3d_center_z(i);
        left_pupil_circle_3d_normal_x(eyeInd) =circle_3d_normal_x(i);
        left_pupil_circle_3d_normal_y(eyeInd) =circle_3d_normal_y(i);
        left_pupil_circle_3d_normal_z(eyeInd) =circle_3d_normal_z(i);
        left_pupil_circle_3d_radius(eyeInd) =circle_3d_radius(i);
        left_pupil_theta(eyeInd) =theta(i);
        left_pupil_phi(eyeInd) =phi(i);
        left_pupil_projected_sphere_center_x(eyeInd) =projected_sphere_center_x(i);
        left_pupil_projected_sphere_center_y(eyeInd) =projected_sphere_center_y(i);
        left_pupil_projected_sphere_axis_a(eyeInd) =projected_sphere_axis_a(i);
        left_pupil_projected_sphere_axis_b(eyeInd) =projected_sphere_axis_b(i);
        left_pupil_projected_sphere_angle(eyeInd) =projected_sphere_angle(i);
        stampCntr(2) = stampCntr(1) + 1;
        
    end
    
end




[world_timestamp,world_index,eye_id,confidence,norm_pos_x,norm_pos_y,diameter,method,ellipse_center_x,ellipse_center_y,ellipse_axis_a,ellipse_axis_b,ellipse_angle,diameter_3d,model_confidence,model_id,sphere_center_x,sphere_center_y,sphere_center_z,sphere_radius,circle_3d_center_x,circle_3d_center_y,circle_3d_center_z,circle_3d_normal_x,circle_3d_normal_y,circle_3d_normal_z,circle_3d_radius,theta,phi,projected_sphere_center_x,projected_sphere_center_y,projected_sphere_axis_a,projected_sphere_axis_b,projected_sphere_angle] = import_All_Gaze_Data(filename2);

% Define Gaze Data
gaze_world_timestamp = world_timestamp;
gaze_world_index = world_index;
gaze_eye_id = eye_id;
gaze_confidence = confidence;
gaze_norm_pos_x = norm_pos_x;
gaze_norm_pos_y = norm_pos_y;
gaze_diameter = diameter;
gaze_method = method; 
gaze_ellipse_center_x =ellipse_center_x;
gaze_ellipse_center_y =ellipse_center_y;
gaze_ellipse_axis_a =ellipse_axis_a;
gaze_ellipse_axis_b =ellipse_axis_b;
gaze_ellipse_angle =ellipse_angle;
gaze_diameter_3d =diameter_3d;
gaze_model_confidence =model_confidence;
gaze_model_id =model_id;
gaze_sphere_center_x =sphere_center_x;
gaze_sphere_center_y =sphere_center_y;
gaze_sphere_center_z =sphere_center_z;
gaze_sphere_radius =sphere_radius;
gaze_circle_3d_center_x =circle_3d_center_x;
gaze_circle_3d_center_y =circle_3d_center_y;
gaze_circle_3d_center_z =circle_3d_center_z;
gaze_circle_3d_normal_x =circle_3d_normal_x;
gaze_circle_3d_normal_y =circle_3d_normal_y;
gaze_circle_3d_normal_z =circle_3d_normal_z;
gaze_circle_3d_radius =circle_3d_radius;
gaze_theta =theta;
gaze_phi =phi;
gaze_projected_sphere_center_x =projected_sphere_center_x;
gaze_projected_sphere_center_y =projected_sphere_center_y;
gaze_projected_sphere_axis_a =projected_sphere_axis_a;
gaze_projected_sphere_axis_b =projected_sphere_axis_b;
gaze_projected_sphere_angle =projected_sphere_angle;



% Convert right pupil data to azimuth and elevation
[right_pupil_azimuth,right_pupil_elevation,right_pupil_r] = cart2sph(right_pupil_circle_3d_normal_x,right_pupil_circle_3d_normal_y,right_pupil_circle_3d_normal_z);

% Do the same for left and gaze
[left_pupil_azimuth,left_pupil_elevation,left_pupil_r] = cart2sph(left_pupil_circle_3d_normal_x,left_pupil_circle_3d_normal_y,left_pupil_circle_3d_normal_z);

[gaze_azimuth,gaze_elevation,gaze_r] = cart2sph(gaze_circle_3d_normal_x,gaze_circle_3d_normal_y,gaze_circle_3d_normal_z);


save('imported_azimuth_elevation.mat');


% Find average Confidence of each variable
average_Right_PupilConfidence=mean(right_pupil_confidence);
average_Left_PupilConfidence=mean(left_pupil_confidence);
averageGazeConfidence=mean(gaze_confidence);



pupilconfidenceData = figure('Name','Pupil Confidence Level');
axes
hold on
plot(right_pupil_world_timestamp,right_pupil_confidence,'color','b','linewidth',1);
plot(left_pupil_world_timestamp,left_pupil_confidence,'color','r','linewidth',1);
set(gca, 'fontsize',16);
axis([min(world_timestamp) max(world_timestamp) 0 1]);
xlabel('Time');
ylabel('Confidence');
text(450,0.9,num2str(average_Right_PupilConfidence));
text(450,0.8,num2str(average_Left_PupilConfidence));

savefig(pupilconfidenceData,'Pupil Confidence');



gazeconfidenceData = figure('Name','GazeConfidence Level');
axes
hold on
plot(gaze_world_timestamp,gaze_confidence,'color',[0 .7 0],'linewidth',1);
set(gca, 'fontsize',16);
axis([min(world_timestamp) max(world_timestamp) 0 1]);
xlabel('Time');
ylabel('Confidence');
text(450,0.9,num2str(averageGazeConfidence));


savefig(gazeconfidenceData,'Gaze Confidence');





Pupil_azimuth_Data = figure('Name','Pupil Azimuth Over Time');
axes
hold on
plot(right_pupil_world_timestamp,right_pupil_azimuth,'color','b','linewidth',1);
plot(left_pupil_world_timestamp,left_pupil_azimuth,'color','r','linewidth',1);
set(gca, 'fontsize',16);
axis([min(world_timestamp) max(world_timestamp) -10 10]);
xlabel('Time');
ylabel('Azimuth Position');


savefig(PupilxpositionData,'Pupil Azimuth');




Gaze_azimuth_positionData = figure('Name','Gaze Azimuth Position Over Time');
axes
hold on
plot(gaze_world_timestamp,gaze_azimuth,'color',[0 .7 0],'linewidth',1);
set(gca, 'fontsize',16);
axis([min(world_timestamp) max(world_timestamp) -100 100]);
xlabel('Time');
ylabel('Azimuth Position');


savefig(Gaze_azimuth_positionData,'Gaze Azimuth');






PupilypositionData = figure('Name','Pupil Elevation Over Time');
axes
hold on
axis([min(world_timestamp) max(world_timestamp) 0 2]);
plot(right_pupil_world_timestamp,right_pupil_elevation,'color','b','linewidth',1);
plot(left_pupil_world_timestamp,left_pupil_elevation,'color','r','linewidth',1);
set(gca, 'fontsize',16);
axis([min(world_timestamp) max(world_timestamp) -10 10]);
xlabel('Time');
ylabel('Elevation Position');


savefig(PupilypositionData,'Pupil Elevation');




GazeypositionData = figure('Name','Gaze Elevation Over Time');
axes
hold on
axis([min(world_timestamp) max(world_timestamp) 0 100]);
plot(gaze_world_timestamp,gaze_elevation,'color',[0 .7 0],'linewidth',1);
set(gca, 'fontsize',16);
axis([min(world_timestamp) max(world_timestamp) -100 100]);
xlabel('Time');
ylabel('Elevation Position');


savefig(GazeypositionData,'Gaze Elevation Position');

cd('D:\Trials\MatLab Stuff');
end