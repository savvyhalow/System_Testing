clear all;
close all;

selpath = uigetdir;
cd(selpath);

filename1 = uigetfile ({'*.txt'},'Unity Sync Signals');

filename2 = uigetfile ({'*.txt'},'Optitrack Sync Signals');

[SignalNumber,Day,Month,Year,Hour,Minute,Second,Microsecond] = import_sync_info(filename1);

UnitySignalNumber=SignalNumber;
UnityDay=Day;
UnityMonth=Month;
UnityYear=Year;
UnityHour=Hour;
UnityMinute=Minute;
UnitySecond=Second;
UnityMicrosecond=Microsecond;

UnitynewTimeSeconds=(UnitySecond*1000)+(UnityMicrosecond/1000);

[SignalNumber,Day,Month,Year,Hour,Minute,Second,Microsecond] = import_sync_info(filename2);

OptitrackSignalNumber=SignalNumber;
OptitrackDay=Day;
OptitrackMonth=Month;
OptitrackYear=Year;
OptitrackHour=Hour;
OptitrackMinute=Minute;
OptitrackSecond=Second;
OptitrackMicrosecond=Microsecond;

OptitracknewTimeSeconds=(OptitrackSecond*1000)+(OptitrackMicrosecond/1000);

TimeDifference=abs(UnitynewTimeSeconds-OptitracknewTimeSeconds);

AverageTimeDifference=mean(TimeDifference);

figure('name','Sync Signals');
axes
hold on

plot(UnitynewTimeSeconds,UnitySignalNumber,'k.','color','b','markersize',40);
plot(OptitracknewTimeSeconds,OptitrackSignalNumber,'k.','color','g','markersize',40);
plot(TimeDifference,OptitrackSignalNumber,'k.','color','r','markersize',40);
set(gca, 'fontsize',16);

xlabel('Time(milliseconds)');
ylabel('Signal Number');
text(40000,10,num2str(AverageTimeDifference));

%%savefig('Sync Signal Comparison');