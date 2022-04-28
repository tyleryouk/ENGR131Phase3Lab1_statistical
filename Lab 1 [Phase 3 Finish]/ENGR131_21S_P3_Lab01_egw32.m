close all
clear all
clc

% Part 1

% B , a 
recording_time = 10; % set the recording time
recording_num = 100; % set the number of recordings

% B , b
s = struct('time',[],'light',[]);

% B, c 
serial_obj = serialport('COM3',9600) ; %importing data from arduino
pause(2);  

% B,d,i
data_city1 = CollectData(serial_obj,recording_time,1); % calling the function
pause(10);
data_city2 = CollectData(serial_obj,recording_time,2); % calling the function
% B,d,ii
data_city1 = data_city1(11:length(data_city1),:); %trim off the first 10 samples 
data_city2 = data_city2(11:length(data_city2),:);
% B,d,iii
data_city1(:,1) = data_city1(:,1)-data_city1(1,1); %starting time will now be 0
data_city2(:,1) = data_city2(:,1)-data_city2(1,1); 
% (starting value = starting value - starting value = 0);

% B,d iv
data_city1(:,2) = (100*data_city1(:,2))/255; %light data will now range from 0 to 100
data_city2(:,2) = (100*data_city2(:,2))/255;

%B , d, v
s(1).time = data_city1(:,1);
s(1).light = data_city1(:,2);
s(2).time = data_city2(:,1);
s(2).light = data_city2(:,2);

% B,e 
serial_obj = []; %clear the serial obj

% Part 2

%plotting data using the created structure and setting appropriate label's
%and axis limits
figure 
subplot(1,2,1)
plot(s(1).time,s(1).light,'b',s(2).time,s(2).light,'r');
legend('City 1','City 2');
xlabel('Time(s)');
ylabel('Normalized Light intensity (%)');
title('Observed Light by City');

subplot(1,2,2)
histogram(s(1).light);
hold on 
histogram(s(2).light);
xlim([5 100]);
legend('City 1','City 2');
title('Light Distribution by City');
xlabel('Light intensity (%) ');

% PART 3 
% creating a table of the data statistics
city1 = [mean(data_city1(:,2));std(data_city1(:,2));median(data_city1(:,2));max(data_city1(:,2));min(data_city1(:,2));prctile(data_city1(:,2),95);prctile(data_city1(:,2),5)];
city2 = [mean(data_city2(:,2));std(data_city2(:,2));median(data_city2(:,2));max(data_city2(:,2));min(data_city2(:,2));prctile(data_city2(:,2),95);prctile(data_city2(:,2),5)];

table(city1,city2,'VariableNames',{'City 1','City 2'},'RowNames',{ 'Mean','Std Dev','Median','Max','Min','95th PCTL','5th PCTL'})


% PART C 

%Doing a t-test of the data 
[h,p,ci,stats] = ttest2(data_city1(:,2),data_city2(:,2));

fprintf(' The p value for the paired t-test for the 2 samples is %d \n',p);
if p<=0.05
    disp(' The 2 Populations are statistially different ');
else
    disp(' The 2 Populations are not statistially different ');
end

% Part 4

DataSort(data_city1,data_city2)

function [Sorted_Data] = DataSort(data_city1,data_city2)

Manual_Data_1 = data_city1;
Manual_Data_2 = data_city2;

%Manually Sorting Data using nested for loops and indexing while timing
%both cities data with the "tic toc" function
tic
for i = 1:length(Manual_Data_1)-1
    IndexLow = i;
    for j = i+1:length(Manual_Data_1)
        if Manual_Data_1(j,2) < Manual_Data_1(IndexLow,2)
            IndexLow = j;
        end
    end
    temp = Manual_Data_1(i,2);
    Manual_Data_1(i,2) = Manual_Data_1(IndexLow,2);
    Manual_Data_1(IndexLow,2) = temp;
end
toc
aa = toc;

tic
for i = 1:length(Manual_Data_2)-1
    IndexLow = i;
    for j = i+1:length(Manual_Data_2)
        if Manual_Data_2(j,2) < Manual_Data_2(IndexLow,2)
            IndexLow = j;
        end
    end
    temp = Manual_Data_2(i,2);
    Manual_Data_2(i,2) = Manual_Data_2(IndexLow,2);
    Manual_Data_2(IndexLow,2) = temp;
end
toc
bb = toc;

Data_1 = data_city1;
Data_2 = data_city2;

%Using the sort command for each cities Data while using "tic toc" function
%to time it
tic
Func_Sort1 = sort(Data_1,'ascend');
toc
cc=toc;

tic
Func_Sort2 = sort(Data_2,'ascend');
toc
dd=toc;

%{2x2 matrix of times where column 1 is manual sort and column 2 is matlab sort%}
sort_times = [aa,cc;bb,dd]

% Creates a nested Data Structure for both cities containing fields 'Time',
% 'Light', and 'Sorted' (containing the sortyed data values, both manually
% and by the function)
SortedStruct1 = struct('Manual',Manual_Data_1,'MatLab',Func_Sort1);
DataStruct_City1 = struct('Time',data_city1(:,1),'Light',data_city1(:,2),'Sorted',SortedStruct1)

SortedStruct2 = struct('Manual',Manual_Data_2,'MatLab',Func_Sort2);
DataStruct_City2 = struct('Time',data_city2(:,1),'Light',data_city2(:,2),'Sorted',SortedStruct2)

% Plotting sorted data for both cities with an appropriate title, axis
% labels, and legend
figure(2)
plot(Manual_Data_1(:,1),Manual_Data_1(:,2),'bs',Manual_Data_2(:,1),Manual_Data_2(:,2),'rs',Func_Sort1(:,1),Func_Sort1(:,2),'b',Func_Sort2(:,1),Func_Sort2(:,2),'r');
legend('City 1 Manual','City 2 Manual','City 1 Auto','City 2 Auto');
xlabel('Time(s)');
ylabel('Normalized Light intensity (%)');
title('Sorted Observed Light by City');

%Reporting the average time for the manual and Matlab sorts
average_manual_time=(aa+bb)/2
average_matlab_time=(cc+dd)/2
end

function [data] = CollectData(s,rec_time,iteration)

v =[]; % brightness array
t = []; % time array
tic 
fprintf('Recording Started for City %i \n',iteration);
while toc<=rec_time % rec_time is defined by user 
    
    data = readline(s); % read data arduino produces
    v = [v str2double(data)]; % grabbing brightness
    t = [t toc]; % grabbing time
    
end
fprintf('Recording Stopped for City %i \n',iteration);

data = [t' v'];  
end

