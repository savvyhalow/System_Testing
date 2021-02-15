clear all;
close all;


selpath = uigetdir;
cd(selpath);


filename1 = uigetfile ({'*.csv'},'Pupil Position Data');

filename2 = uigetfile ({'*.csv'},'Gaze Position Data');


[timestamp,index,id,confidence,norm_pos_x,norm_pos_y]= importpupilposition(filename1);

nEyes = 2; %standard # of eyes per human
stampCntr = ones(1,nEyes); %keep track of how many timestamps we've gotten for each eye

for i = 1:size(timestamp)
    if id (i)==1
        eyeInd = stampCntr(2);
        rightpupilTimestamp(eyeInd)=timestamp(i);
        rightpupilIndex(eyeInd)=index(i);
        rightpupilConfidence(eyeInd)=confidence(i);
        rightpupilxPos(eyeInd)=norm_pos_x(i);
        rightpupilyPos(eyeInd)=norm_pos_y(i);
        stampCntr(2) = stampCntr(2) + 1;
        
    elseif id(i) == 0
        eyeInd = stampCntr(1);
        leftpupilTimestamp(eyeInd)=timestamp(i);
        leftpupilIndex(eyeInd)=index(i);
        leftpupilConfidence(eyeInd)=confidence(i);
        leftpupilxPos(eyeInd)=norm_pos_x(i);
        leftpupilyPos(eyeInd)=norm_pos_y(i);
        stampCntr(1) = stampCntr(1) + 1;
        
    end
    
end


[timestamp1,index1,confidence1,norm_pos_x1,norm_pos_y1] = importgazeposition(filename2);

gazeTimestamp=timestamp1;
gazeIndex=index1;
gazeConfidence=confidence1;
gazexPos=norm_pos_x1;
gazeyPos=norm_pos_y1;



average_Right_PupilConfidence=mean(rightpupilConfidence);
average_Left_PupilConfidence=mean(leftpupilConfidence);
averageGazeConfidence=mean(gazeConfidence);


average_Right_PupilxPosition=mean(rightpupilxPos);
average_Left_PupilxPosition=mean(leftpupilxPos);

average_Right_pupilyPos=mean(rightpupilyPos);
average_Left_pupilyPos=mean(leftpupilyPos);


averagegazexPos=mean(gazexPos);
averagegazeyPos=mean(gazeyPos);





pupilconfidenceData = figure('Name','Pupil Confidence Level');
axes
hold on
plot(rightpupilTimestamp,rightpupilConfidence,'color','b','linewidth',1);
plot(leftpupilTimestamp,leftpupilConfidence,'color','r','linewidth',1);
set(gca, 'fontsize',16);
axis([min(timestamp) max(timestamp) 0 1]);
xlabel('Time');
ylabel('Confidence');
text(450,0.9,num2str(average_Right_PupilConfidence));
text(450,0.8,num2str(average_Left_PupilConfidence));

savefig('Pupil Confidence');



gazeconfidenceData = figure('Name','GazeConfidence Level');
axes
hold on
plot(gazeTimestamp,gazeConfidence,'color',[0 .7 0],'linewidth',1);
set(gca, 'fontsize',16);
axis([min(timestamp) max(timestamp) 0 1]);
xlabel('Time');
ylabel('Confidence');
text(450,0.9,num2str(averageGazeConfidence));


savefig('Gaze Confidence');





PupilxpositionData = figure('Name','Pupil X Position Over Time');
axes
hold on
plot(rightpupilTimestamp,rightpupilxPos,'color','b','linewidth',1);
plot(leftpupilTimestamp,leftpupilxPos,'color','r','linewidth',1);
set(gca, 'fontsize',16);
axis([min(timestamp) max(timestamp) -10 10]);
xlabel('Time');
ylabel('x Position');
text(450,9,num2str(average_Right_PupilxPosition));
text(450,8,num2str(average_Left_PupilxPosition));

savefig('Pupil X Position');




GazexpositionData = figure('Name','Gaze X Position Over Time');
axes
hold on
plot(gazeTimestamp,gazexPos,'color',[0 .7 0],'linewidth',1);
set(gca, 'fontsize',16);
axis([min(timestamp) max(timestamp) -100 100]);
xlabel('Time');
ylabel('x Position');
text(450,80,num2str(averagegazexPos));

savefig('Gaze X Position');






PupilypositionData = figure('Name','Pupil Y Position Over Time');
axes
hold on
axis([min(timestamp) max(timestamp) 0 2]);
plot(rightpupilTimestamp,rightpupilyPos,'color','b','linewidth',1);
plot(leftpupilTimestamp,leftpupilyPos,'color','r','linewidth',1);
set(gca, 'fontsize',16);
axis([min(timestamp) max(timestamp) -10 10]);
xlabel('Time');
ylabel('Y Position');
text(450,9,num2str(average_Right_pupilyPos));
text(450,8,num2str(average_Left_pupilyPos));

savefig('Pupil Y Position');




GazeypositionData = figure('Name','Gaze Y Position Over Time');
axes
hold on
axis([min(timestamp) max(timestamp) 0 100]);
plot(gazeTimestamp,gazeyPos,'color',[0 .7 0],'linewidth',1);
set(gca, 'fontsize',16);
axis([min(timestamp) max(timestamp) -100 100]);
xlabel('Time');
ylabel('Y Position');
text(450,80,num2str(averagegazeyPos));

savefig('Gaze Y Position');