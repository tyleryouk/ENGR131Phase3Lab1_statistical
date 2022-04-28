close all
clear all
clc

% B , a 
recording_time = 10; % set the recording time
recording_num = 100; % set the number of recordings

% B , b
s = struct('time',[],'light',[]);
% B, c 

serial_obj = serialport('/dev/cu.usbmodem14101',9600) ; %importing data from arduino
pause(2);  

% B,d,i
data_city1 = CollectData(serial_obj,recording_time,1); % calling the function
pause(10);
data_city2 = CollectData(serial_obj,recording_time,2); % calling the function
% B,d,ii
data_city1(1:10,:) = []; %trim off the first 10 samples 
data_city2(1:10,:) = [];
% B,d,iii
data_city1(:,1) = data_city1(:,1)-data_city1(1,1); %starting time will now be 0
data_city2(:,1) = data_city2(:,1)-data_city2(1,1); 
% (starting value = starting value - starting value = 0);

% B,d iv
data_city1(:,2) = (100*data_city1(:,2))/255; %light data will now range from 0 to 100
data_city2(:,2) = (100*data_city2(:,2))/255;

%B , d, v skipped for now 

% B,e 
%serial_obj = []; %clear the serial obj

figure 
subplot(1,2,1)
plot(data_city1(:,1),data_city1(:,2),'b',data_city2(:,1),data_city2(:,2),'r');
legend('City 1','City 2');
xlabel('Time(s)');
ylabel('Normalized Light intensity (%)');
title('Observed Light by City');

subplot(1,2,2)
histogram(data_city1(:,2));
hold on 
histogram(data_city2(:,2));
xlim([5 100]);
legend('City 1','City 2');
title('Light Distribution by City');
xlabel('Light intensity (%) ');

% PART 3 

city1 = [mean(data_city1(:,2));std(data_city1(:,2));median(data_city1(:,2));max(data_city1(:,2));min(data_city1(:,2));prctile(data_city1(:,2),95);prctile(data_city1(:,2),5)];
city2 = [mean(data_city2(:,2));std(data_city2(:,2));median(data_city2(:,2));max(data_city2(:,2));min(data_city2(:,2));prctile(data_city2(:,2),95);prctile(data_city2(:,2),5)];

table(city1,city2,'VariableNames',{'City 1','City 2'},'RowNames',{ 'Mean','Std Dev','Median','Max','Min','95th PCTL','5th PCTL'})


% PART C 

[h,p,ci,stats] = ttest2(data_city1(:,2),data_city2(:,2));

fprintf(' The p value for the paired t-test for the 2 samples is %d \n',p);
if p<=0.05
    disp(' The 2 Populations are statistially different ');
else
    disp(' The 2 Populations are not statistially different ');
end

% Part 4

