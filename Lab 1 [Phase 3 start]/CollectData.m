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

