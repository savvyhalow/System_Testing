%Written by Douglas Powell, PhD to (1) identify points associated with
%phase transitions and (2) to calculate COP displacements and velocities 
%in the AP and ML directions during gait initiation 

clear;
clc;

%Identify file path and import data to array
directory=('C:\MyFiles\GSU Collaboration\Gait Initiation_2018\');
filename=('AA14067 Baseline GI Norm 1');
inpath=[directory '\Data\' filename '.csv'];
data=csvread(inpath,4,0);

%determine the size of the data array
[row,col]=size(data);

%parse data into unidimensional arrays for FP1 & FP3
copx1=data(:,2);
copy1=data(:,3);
fz1=data(:,10);

copx3=data(:,26);
copy3=data(:,27);
fz3=data(:,34);

% %filter FP1 data
% fs=1000;        %sampling rate
% fc=50;          %cutoff frequency
% N=4;            %order of filter
% [B,A]=butter(N,fc/fs,'low');        %determine filter coefficients
% 
% copx1=filtfilt(B,A,copx1);
% copy1=filtfilt(B,A,copy1);
% fz1=filtfilt(B,A,fz1);
% copx3=filtfilt(B,A,copx3);
% copy3=filtfilt(B,A,copy3);
% fz3=filtfilt(B,A,fz3);

%calculate total Fz and determine when Fz falls below 10 N
fz=fz1+fz3;
idxFz=find(fz<10);
idx=idxFz(1)-1;

%calculate overall center of pressure
for i=1:idx
    copX(i)=.1*(((fz1(i)*copx1(i))+(fz3(i)*copx3(i)))/fz(i));
    copY(i)=.1*(((fz1(i)*copy1(i))+(fz3(i)*copy3(i)))/fz(i));
end

%plot overall cop plot
figure(1); clf;
plot(copX,copY,'k'); xlabel('COP X'); ylabel('COP Y');
msgStr{1}=('Select the four points of interest');
msgStr{2}=('Right click to Quit');
titleStr=('Ready for data acquisition');
uiwait(msgbox(msgStr,titleStr,'warn','modal'));
drawnow

%user input to determine beginning and end points
but1=1; n=0;
while but1==1       %right click but1=4
    [xv,yv,but1]=ginput(1);
    plot(copX,copY,'k',xv,yv,'ro');xlabel('COP X'); ylabel('COP Y');
    n=n+1;
    if n==4,but1=3;end;
    xyvar1(n,:)=[xv,yv];
end

%calculate displacement between 4 identified points of interest
for i_seg=1:3
    xDisp(i_seg)=abs(xyvar1(i_seg+1,1)-xyvar1(i_seg,1));
    yDisp(i_seg)=abs(xyvar1(i_seg+1,2)-xyvar1(i_seg,2));
end


for i_point=1:4
    [minDistance(i_point),idxMin(i_point)]=min(abs(xyvar1(i_point,1)-copX(:)));
end

frames=diff(idxMin);

%Calculate average cop velocities across each segment (diff b/w 4 points)
for i_seg=1:3
    xVel(i_seg)=xDisp(i_seg)/(frames(i_seg)*.001);
    yVel(i_seg)=yDisp(i_seg)/(frames(i_seg)*.001);
end

%Identify where to write to file
outFolder=[directory 'Processed\'];
outfile=[outFolder filename '_Processed.xlsx'];
outArray=[xDisp' yDisp' xVel' yVel'];
outHeader=({'Segment' 'COP X Displacement' 'COP Y Displacement' 'COP X Velocity' 'COP Y Velocity'});
outSeg=1:1:i_seg;

%write to file
xlswrite(outfile,outHeader,'Sheet1','A1');
xlswrite(outfile,outSeg','Sheet1','A2');
xlswrite(outfile,outArray,'Sheet1','B2');















