clear all;
close all;

% Find opti and trial files
dirName = strcat('D:\Savvy\Work\Conflict Detection\System Testing\Tracking Tests');
dirName = char(dirName);
cd(dirName);

 load('importedTrackingTest1.mat');
load('importedTrackingTest2.mat');
load('importedTrackingTest3.mat');
load('importedTrackingTest4.mat');
load('importedTrackingTest5.mat');
load('importedTrackingTest6.mat');
load('importedTrackingTest7.mat');
%SteamVR -                SteamVRTime_TX  &  SteamVRYaw_TX
%OptiTrack GameObject -   SteamVRTime_TX  &  optiGoYaw_TX
%OptiTrack Rigidbody -    optitrackTime_TX  &  optiY_TX

%Error
%Enter generic yaw here:
yawOne = optiY_T2;
timeOne = optitrackTime_T2;

yawTwo = steamVRYaw_T2;
timeTwo = steamVRTime_T2;

%If yawOne array is larger
if length(yawOne) > length(yawTwo)
    b=nan(size(yawOne));          %create new array for yawTwo to fit
    for i = 1:size(yawTwo)        %for the size of yawTwo..
        b(i) = yawTwo(i);         %Insert yawTwo values
    end
    
    for i = 1:size(yawOne)
        errorY(i) = abs(yawOne(i) - b(i));  %Subtract
    end
    errorTime = timeOne;
    
elseif length(yawOne) < length(yawTwo)
    
    %If yawTwo array is larger
    b=nan(size(yawTwo));             %create new array for yawOne to fit in
    for i = 1:size(yawOne)           %for the size of yawOne..
        b(i) = yawOne(i);            % Add yawOne values
    end
    
    for i = 1:size(yawTwo)
        errorY(i) = abs(yawTwo(i) - b(i));  %Subtract
    end
    errorTime = timeTwo;
    
else
    for i = 1:size(yawOne)
        errorY(i) = abs(yawTwo(i) - yawOne(i));  %Subtract
    end
    errorTime = timeOne;
end

errorSTD = nanstd(errorY)
errorAvg = nanmean(errorY)


tracking_Data = figure('Name','Tracking Plot');
axes
hold on

plot(timeOne,yawOne,'color',[0 0.3 0],'linewidth',1.5);
plot(timeTwo,yawTwo,'color',[0 0.6 0],'linewidth',1);
% plot(errorTime,errorY,'color',[0 1 0],'linewidth',0.5);

set(gca, 'fontsize',16);
axis([-1 75 -10 50]);
legend('yawOne','yawTwo');
xlabel('Time (Sec)');
ylabel('Rotation (Degrees)');
text(70,40,num2str(errorAvg)); % print the mean
text(70,38,num2str(errorSTD)); % preint the SD

%savefig(tracking_Data, 'Tracking Plot');












cd('D:\');
