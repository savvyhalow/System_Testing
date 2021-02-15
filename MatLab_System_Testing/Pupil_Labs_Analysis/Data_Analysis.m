clear all;
%close all;


selpath = uigetdir;
cd(selpath);


filename1 = uigetfile ({'*.txt'},'Experimental Data File');

filename2 = uigetfile ({'*.csv'},'Optitrack Data File');

[Trial,WorldTime,MovementStart,MovementEnd,Movementdistance,Velocity,Gain,LengthofTrial,With0orAgainst1,Left0orRight1,Userchosewith1oragainst0,ChoseCorrectly1Correct] = importgoodnew(filename1);
[Frame,TimeSeconds,X,Y,Z,X1,Y1,Z1,VarName9] = importopti(filename2);
save('importeddata.mat');


selpath = uigetdir;
cd(selpath);


filename3 = uigetfile ({'*.csv'},'Pupil Data File');


%filename4 = uigetfile ({'*.csv'},'Gaze Data File');

[world_timestamp,world_index,eye_id,confidence,circle_3d_center_x,circle_3d_center_y,circle_3d_center_z] = import_pupil_center_position(filename3);

%https://docs.pupil-labs.com/#detailed-data-format
%circle_3d_center_x - x center of the pupil as 3d circle in eye pinhole camera 3d space units are mm.
%circle_3d_center_y - y center of the pupil as 3d circle
%circle_3d_center_z - z center of the pupil as 3d circle


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



%
%[world_timestamp,world_index,eye_id,confidence,circle_3d_center_x,circle_3d_center_y,circle_3d_center_z] = import_All_Gaze_Data(filename2);

% Define Gaze Data
 %       gaze_pupil_world_timestamp(eyeInd) = world_timestamp(i);
  %      gaze_pupil_world_index(eyeInd) = world_index(i);
   %     gaze_pupil_eye_id(eyeInd) = eye_id(i);
    %    gaze_pupil_confidence(eyeInd) = confidence(i);
     %   gaze_pupil_circle_3d_center_x(eyeInd) =circle_3d_center_x(i);
      %  gaze_pupil_circle_3d_center_y(eyeInd) =circle_3d_center_y(i);
       % gaze_pupil_circle_3d_center_z(eyeInd) =circle_3d_center_z(i);




% Convert right pupil data to azimuth and elevation
[right_pupil_azimuth,right_pupil_elevation,right_pupil_r] = cart2sph(right_pupil_circle_3d_center_x,right_pupil_circle_3d_center_y,right_pupil_circle_3d_center_z);

% Do the same for left and gaze
[left_pupil_azimuth,left_pupil_elevation,left_pupil_r] = cart2sph(left_pupil_circle_3d_center_x,left_pupil_circle_3d_center_y,left_pupil_circle_3d_center_z);

%[gaze_azimuth,gaze_elevation,gaze_r] = cart2sph(gaze_circle_3d_center_x,gaze_circle_3d_center_y,gaze_circle_3d_center_z);


save('imported_azimuth_elevation.mat');


%selpath = uigetdir;
%cd(selpath);

%load('importeddata.mat');


numtrials=length(Trial);

midyaw=nanmean(Y);

movetime=0;
dashtime=0;
aligned=0;

newTimeSeconds=TimeSeconds;

while aligned~=1
    rawyaw=figure;
    
    for i=1:1:numtrials
        if Left0orRight1(i)==0
            line([MovementStart(i) MovementEnd(i)],[midyaw midyaw],'color','r');
        end
        if Left0orRight1(i)==1
            line([MovementStart(i) MovementEnd(i)],[midyaw midyaw],'color','b');
        end
        hold on;
    end
    
    plot(newTimeSeconds,Y);
    
    pause
    
    dashtime=input('Dash time?');
    movetime=input('Move time?');
    
    newTimeSeconds=newTimeSeconds-movetime+dashtime;
    
    OTframerate=240;
    headMvmnt=zeros(numtrials,round(max(LengthofTrial)*OTframerate));
    for i=1:1:numtrials
        timestart=min(find(newTimeSeconds>MovementStart(i)));
        timeend=min(find(newTimeSeconds>MovementEnd(i)));
        thisMove=Y(timestart:timeend);
        thisMove=thisMove-thisMove(1);
        headMvmnt(i,1:length(thisMove))=thisMove;
        thisMove=[];
    end
    
    figure;plot(headMvmnt');
    
    
    
    headMvmntPlat=headMvmnt;
    for i=1:1:numtrials
        if Left0orRight1(i)==0          %0
            endpos=max(headMvmnt(i,:));
        end
        if Left0orRight1(i)==1             %1
            endpos=min(headMvmnt(i,:));
        end
        headMvmntPlat(i,find(headMvmnt(i,:)==endpos):end)=endpos*ones(size(headMvmnt(i,find(headMvmnt(i,:)==endpos):end)));
    end
    
    figure;plot(headMvmntPlat');
    
    headVel=diff(headMvmntPlat')*OTframerate;
    figure;plot(headVel);
    
    aligned=input('Aligned (1/0)?');
    
end

headVelSmooth=headVel;
fadewin=round(OTframerate/5); % fade in over 1/5th of a second
f=[1:1:fadewin];fade=normcdf(f,fadewin/2,fadewin/6); %figure;plot(f,fade);
for i=1:1:numtrials
    headVelSmooth(:,i)=fastsmooth(headVel(:,i),round(OTframerate/10),5,1);
    headVelSmooth(1:fadewin,i)=headVelSmooth(1:fadewin,i).*fade'; % fade-in
    headVelSmooth(size(headVelSmooth,1)-fadewin+1:end,i)=headVelSmooth(size(headVelSmooth,1)-fadewin+1:end,i).*fliplr(fade)'; % fade-out
end

%24-frame fade-in here

savefig(rawyaw,'rawyaw');

figure;plot(headVelSmooth);savefig('headVelSmooth');

figure;plot(cumsum(headVelSmooth)/OTframerate);savefig('headDispSmooth');

% Downsample before saving
idx = 1:size(headVelSmooth,1); % Index
numframes= size(headVelSmooth,1)*90/OTframerate; % downsample from OTframerate to 90 Hz                              
idxq = linspace(min(idx), max(idx), numframes);    % Interpolation Vector
for i=1:1:numtrials
    headVelSmooth90(:,i) = interp1(idx, headVelSmooth(:,i), idxq, 'linear');       % Downsampled Vector
end

headVelSmooth90(end,:)=zeros(1,numtrials);

dlmwrite('headvel.txt',headVelSmooth90','delimiter','\t','precision','%.6f');
dlmwrite('gain.txt',Gain','delimiter','\t','precision','%4f');


% Find average Confidence of each variable
average_Right_PupilConfidence=mean(right_pupil_confidence);
average_Left_PupilConfidence=mean(left_pupil_confidence);
%averageGazeConfidence=mean(gaze_confidence);



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



%gazeconfidenceData = figure('Name','GazeConfidence Level');
%axes
%hold on
%plot(gaze_world_timestamp,gaze_confidence,'color',[0 .7 0],'linewidth',1);
%set(gca, 'fontsize',16);
%axis([min(world_timestamp) max(world_timestamp) 0 1]);
%xlabel('Time');
%ylabel('Confidence');
%text(450,0.9,num2str(averageGazeConfidence));


%savefig(gazeconfidenceData,'Gaze Confidence');



Pupil_azimuth_Data = figure('Name','Pupil Azimuth Over Time');
axes
hold on
plot(right_pupil_world_timestamp,right_pupil_azimuth,'color','b','linewidth',1);
plot(left_pupil_world_timestamp,left_pupil_azimuth,'color','r','linewidth',1);
set(gca, 'fontsize',16);
axis([min(world_timestamp) max(world_timestamp) -10 10]);
xlabel('Time');
ylabel('Azimuth');


savefig(Pupil_azimuth_Data,'Pupil Azimuth');


%Gaze_azimuth_positionData = figure('Name','Gaze Azimuth Position Over Time');
%axes
%hold on
%plot(gaze_world_timestamp,gaze_azimuth,'color',[0 .7 0],'linewidth',1);
%set(gca, 'fontsize',16);
%axis([min(world_timestamp) max(world_timestamp) -100 100]);
%xlabel('Time');
%ylabel('Azimuth Position');

%savefig(Gaze_azimuth_positionData,'Gaze Azimuth');


Pupil_elevation_Data = figure('Name','Pupil Elevation Over Time');
axes
hold on
axis([min(world_timestamp) max(world_timestamp) 0 2]);
plot(right_pupil_world_timestamp,right_pupil_elevation,'color','b','linewidth',1);
plot(left_pupil_world_timestamp,left_pupil_elevation,'color','r','linewidth',1);
set(gca, 'fontsize',16);
axis([min(world_timestamp) max(world_timestamp) -10 10]);
xlabel('Time');
ylabel('Elevation');


savefig(Pupil_elevation_Data,'Pupil Elevation');

%GazeypositionData = figure('Name','Gaze Elevation Over Time');
%axes
%hold on
%axis([min(world_timestamp) max(world_timestamp) 0 100]);
%plot(gaze_world_timestamp,gaze_elevation,'color',[0 .7 0],'linewidth',1);
%set(gca, 'fontsize',16);
%axis([min(world_timestamp) max(world_timestamp) -100 100]);
%xlabel('Time');
%ylabel('Elevation Position');


%savefig(GazeypositionData,'Gaze Elevation Position');

%selpath = uigetdir;
%cd(selpath);

%load('imported_azimuth_elevation.mat');

  %  selpath = uigetdir;
 %   cd(selpath);

%load('importeddata.mat');


% Plotting head vs azimuth
pupil_movetime=0;
pupil_dashtime=0;
aligned=0;

pupil_movetime=0;
pupil_dashtime=0;
pupil_aligned=0;


new_pupil_Time=world_timestamp;


while aligned~=1
    headvsazimuth=figure;
    
    plot(newTimeSeconds,Y);
    plot(new_pupil_Time,right_pupil_azimuth,'color','b','linewidth',1);
    plot(new_pupil_Time,left_pupil_azimuth,'color','r','linewidth',1);
    
    pause
    
    pupil_dashtime=input('Pupil Dash time?');
    pupil_movetime=input('Pupil Move time?');
    
    new_pupil_Time=world_timestamp-pupil_movetime+pupil_dashtime;
    
    plot(newTimeSeconds,Y);
    plot(new_pupil_Time,right_pupil_azimuth,'color','b','linewidth',1);
    plot(new_pupil_Time,left_pupil_azimuth,'color','r','linewidth',1);
    aligned=input('Aligned (1/0)?');
           
    
end
    
savefig(headvsazimuth,'Yaw_vs_Azimuth')



numtrials=length(Trial);
staircase=figure;
    for i=1:1:numtrials
    if Userchosewith1oragainst0(i)==0
        line(Trial(i),Gain(i),'Marker','.','color','r');
    elseif Userchosewith1oragainst0(i)==1
        line(Trial(i),Gain(i),'Marker','.','color','b');
    end
    hold on
    end
plot(Trial,Gain,'bo');
savefig(staircase,'Staircase_Fig');


AllStimLevels=[AllStimLevels;Gain];
AllNumPos=[AllNumPos;Userchosewith1oragainst0];

StimLevels=unique(AllStimLevels);

for i=1:1:size(StimLevels,1)
    ind=[];
    ind=find(AllStimLevels==StimLevels(i));
    NumPos(i,1)=sum(AllNumPos(ind));
    OutOfNum(i,1)=length(ind);
end
    

thresh_st=1;
slope_st=1;
guess_st=0;
lapse_st=0;
searchGrid=[thresh_st slope_st guess_st lapse_st];
thresh_fr=1;
slope_fr=1;
guess_fr=0;
lapse_fr=0;
paramsFree=[thresh_fr slope_fr guess_fr lapse_fr];

PF=@PAL_CumulativeNormal;

[paramsValues LL exitflag output] = PAL_PFML_Fit(StimLevels, NumPos, OutOfNum, searchGrid, paramsFree, PF);

paramsValues(1)
1/paramsValues(2)

%Create simple plot
ProportionCorrectObserved=NumPos./OutOfNum; 
StimLevelsFineGrain=[min(StimLevels):max(StimLevels)./1000:max(StimLevels)];
ProportionCorrectModel = PF(paramsValues,StimLevelsFineGrain);
 
figure('name','Maximum Likelihood Psychometric Function Fitting');
axes
hold on
plot(StimLevelsFineGrain,ProportionCorrectModel,'-','color',[0 .7 0],'linewidth',4); % plot the green function
plot(StimLevels,ProportionCorrectObserved,'k.','markersize',40); % plot the black points
set(gca, 'fontsize',16);
% set(gca, 'Xtick',StimLevels);
axis([min(StimLevels) max(StimLevels) 0 1]);
xlabel('Stimulus Intensity');
ylabel('proportion correct');
text(1,.9,num2str(paramsValues(1))); % print the mean
text(1,.8,num2str(1/paramsValues(2))); % preint the SD 

savefig('psych_Fig');

cd('D:\Trials\MatLab Stuff');