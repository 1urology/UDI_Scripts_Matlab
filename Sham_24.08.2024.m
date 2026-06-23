%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: M. von Siebenthal, edit: Pragya Nagar updated:24.08.2024
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% variable naming:
% e: entire measurement
% a: all measurement -> for Pbase & Pmax in SCI measurements
% z: zoom to one micturition cycle
% w: values within window (around the peak in pressure)
% tsp: timestamp e.g.: 47.042, 88.020 
% idx: index --> position in array, e.g. 4390, 5391, 6392
% val: value of the parameter
% logi: logical variable (1 if condition applies, 0 if not)
%%% structure: 
% 1.) e, z or w
% 2.) tsp, idx, val or logi
% 3.) variable (parameter)
clc; clear; close all;

%% values to be defined prior to analysis:
deriv_threshold = 0.65; %from maximal derivative
pre=20; % time analysed before the peak (s)
post=5; % time analysed after the peak (s)
corr = 0; 
analysisTime = 600; %time in seconds, that will be analysed

%% load tdms file and extract values for pressure and scale
% Find the .tdms file in the current folder
fileList = dir('*.tdms');

% Since there is only one .tdms file, assign its name to the variable
xy = fileList.name;

% Load the TDMS file and extract values for pressure and scale
[output, filestruct] = TDMS_readTDMSFile(xy);

e_var_pressure = output.data{1,3};
e_var_scale = output.data{1,4};
e_var_EMG = output.data{1,5};

% Set all the EMG values above 1 to 1 and all below -1 to -1
e_var_EMG(e_var_EMG < -1) = -1;
e_var_EMG(e_var_EMG > 1) = 1;

% Extract the sampling frequencies from the TDMS file
f = output.propValues{1,4};
fs_scale = 1/f{4};  % Sampling rate of scale
f = output.propValues{1,3};
fs = 1/f{4};  % Sampling rate of pressure and EMG

% Create time vectors
e_tsp = 1/fs : 1/fs : length(e_var_pressure)/fs;  % Vector of time (pressure and EMG)
e_idx = (1:length(e_tsp));
e_tsps = 1/fs_scale : 1/fs_scale : length(e_var_scale)/fs_scale;  % Vector of time (scale)

% Modify the file name
% Trim the filename to remove the last 4 characters (the time part)
% Assuming xy contains the filename with the format 19L_YYYYMMDDHHMM.tdms

% Find the position of the '.tdms' extension
dotIdx = strfind(xy, '.tdms');
xy = xy(1:dotIdx-5);
xy = [xy, '_555'];


%% recording time in minutes
e_val_RecordingTime = max(e_tsp)/60;

%% Figure 1 = raw data
set(0,'DefaultFigureWindowStyle','docked')
summaryGraph = figure;

%subplot 311
%plot(e_tsp, e_var_pressure);
%xlim([0 max(e_tsp)])
%title(replace(xy, '_', '-'))
%set(gca,'XTickLabel',[])
%set(gca,'FontSize',18)
%ylabel('P_v_e_s_i_c_a_l [cmH_2O]')

% Limit the data to the first 3000 seconds
max_time = 3000;
time_limit_idx = e_tsp <= max_time;
time_limit_idx_scale = e_tsps <= max_time;

% Plot the data up to the 3000-second timestamp
subplot 211
plot(e_tsp(time_limit_idx), e_var_pressure(time_limit_idx));
xlim([0 3000])
title(replace(xy, '_', '-'))
set(gca,'XTickLabel',[])
set(gca,'FontSize',18)
ylabel('P_v_e_s_i_c_a_l [cmH_2O]')

%subplot 312
%plot(e_tsp, e_var_EMG)
%xlim([0 max(e_tsp)])
%set(gca,'XTickLabel',[])
%set(gca,'FontSize',18)
%ylabel('EMG [mV]')

%subplot 312
%plot(e_tsp(time_limit_idx), e_var_EMG(time_limit_idx))
%xlim([0 3000])
%set(gca,'XTickLabel',[])
%set(gca,'FontSize',18)
%ylabel('EMG [mV]')

%subplot 313
%plot(e_tsps, e_var_scale)   %original data, 5Hz
%xlim([0 3000])
%set(gca,'FontSize',18)
%xlabel('Time [s]')
%ylabel('V_v_o_i_d [mL]')

subplot 212
plot(e_tsps(time_limit_idx_scale), e_var_scale(time_limit_idx_scale))   %original data, 5Hz
xlim([0 3000])
set(gca,'FontSize',18)
xlabel('Time [s]')
ylabel('V_v_o_i_d [mL]')

%%Trial 
%% Figure 1 = raw data
set(0,'DefaultFigureWindowStyle','docked')
summaryGraph = figure;

% Limit the data to the first 3000 seconds
max_time = 3000;
time_limit_idx = e_tsp <= max_time;
time_limit_idx_scale = e_tsps <= max_time;

% Normalizing pressure data
e_var_pressure_norm = e_var_pressure(time_limit_idx) - min(e_var_pressure(time_limit_idx));

% Plot the normalized pressure data up to the 3000-second timestamp
subplot(211)
plot(e_tsp(time_limit_idx), e_var_pressure_norm);
xlim([0 3000])
ylim([0 60])  % Set the y-axis range from 0 to 40
yticks(0:10:60)  % Set y-axis ticks with intervals of 10
title(replace(xy, '_', '-'))
set(gca,'XTickLabel',[])
set(gca,'FontSize',18)
ylabel('P_v_e_s_i_c_a_l [cmH_2O]')

% Normalizing scale data
e_var_scale_norm = e_var_scale(time_limit_idx_scale) - min(e_var_scale(time_limit_idx_scale));

% Plot the normalized scale data up to the 3000-second timestamp
subplot(212)
plot(e_tsps(time_limit_idx_scale), e_var_scale_norm);
xlim([0 3000])
set(gca,'FontSize',18)
xlabel('Time [s]')
ylabel('V_v_o_i_d [mL]')

%% Make selection in the pressure graph for BL and Sham
% Click at the beginning and end of micturition
[x, y] = ginput(2);

% Set values to NaN that are not used in BL and Sham
a_val_Pbase = NaN; % baseline pressure of whole measurement
a_val_nPmax = NaN; % normalized maximal pressure of whole measurement

%% find Pmax & Pbase --> for SCI
% [x1, y1] = ginput(2);
% [a_idxs] = findselection(e_tsps, x1);  % timespan between click 1 & 2
% a_tsps = e_tsps(a_idxs);  % variable containing time (of scale) within the selection
% a_idx_t = e_tsp>min(a_tsps) & e_tsp<max(a_tsps); % variable containing time of pressure and EMG
% a_val_p = e_var_pressure(a_idx_t);  % variable containing pressure within the selection
% 
% a_val_Pbase = min(a_val_p); % baseline Pressure
% a_val_Pmax = max(a_val_p); % maximal Pressure
% a_val_nPmax = a_val_Pmax - a_val_Pbase; % normalized maximal pressure
%% make selection in the pressure graph --> for SCI
% % click once, then it automatically finds the coordinates 10 min later
% [x, y] = ginput(1);
% x(2) = x(1)+analysisTime;



%% Identifies all the values within the selected region
[z_idxs] = findselection(e_tsps, x);  % timespan between click 1 & 2
z_tsps = e_tsps(z_idxs);  % variable containing time (of scale) within the selection
z_val_scale = e_var_scale_norm(z_idxs);  % use the normalized scale data

% Filter pressure data within the selected time window
z_idx_t = e_tsp >= min(z_tsps) & e_tsp <= max(z_tsps);
z_idx = e_idx(z_idx_t);
z_tsp = e_tsp(z_idx_t);
z_val_p = e_var_pressure_norm(z_idx_t);  % use the normalized pressure data
z_val_emg = e_var_EMG(z_idx_t);  % keep the EMG data as is

%% Find peak in the selected pressure data
[z_idx_Pmax, z_val_Pmax] = findpeak(z_val_p);
z_tsp_Pmax = z_tsp(z_idx_Pmax);
z_val_PmaxDuration = (z_tsp_Pmax - min(z_tsps)) / 60; % in minutes
fprintf('\n \n Number of peaks = %01d, value of peak = %.2f cmH2O \n', length(z_idx_Pmax), z_val_Pmax);

%% Plot the results of the selected windowed data
subplot(211); hold on;
plot(z_tsp, z_val_p, 'm')  % Plot the selected and normalized pressure data in magenta
% subplot(312); hold on; 
% plot(z_tsp, z_val_emg, 'm')
subplot(212); hold on;
plot(z_tsps, z_val_scale, 'm')  % Plot the selected and normalized scale data in magenta



%% find minimum
[z_idx_Pbase, z_val_Pbase] = findmin(z_val_p);

%% calculate amplitude
z_val_nPmax = z_val_Pmax - z_val_Pbase;          % detrusor pressure amplitude
fprintf('\n normalised maximal detrusor pressure = %.2f cmH2O \n', z_val_nPmax);

%% find time window of selected micturition cycle
[w_idx] = findtimewindow(z_tsp,z_idx_Pmax, pre, post); % find the time slots (e.g. 10s before peak, 10s after peak) being analysed
[w_idx_pre] = findpre(z_tsp,z_idx_Pmax, pre); % section before the first peak
[w_idx_post] = findpost(z_tsp, z_idx_Pmax, post, fs); % section after the first peak
% the value of the first peak is missing

%% find micturition cycle duration in minutes
z_val_MicDuration = max((z_tsps)-min(z_tsps))/60; %in minutes
fprintf('\n Micturition cylce duration = %.2f min \n', z_val_MicDuration);

%% lines are added on graph before the drops
z_idx_drop = find(diff(z_val_scale) > 0);
fix = 0; % =0 time step before drop; =1 after drop
z_tsps_drop = z_tsps(z_idx_drop+fix);

% plot lines on graph with scale
%for kk = 1:length(z_tsps_drop)
    %subplot 212; hold on; xline(z_tsps_drop(kk), 'g', 'Linewidth', 1);
%end
 %plot lines on graph with pressure and emg
%for jj = 1:length(z_tsps_drop)
    %id_drop2 = find( round(z_tsp, 4) == round(z_tsps_drop(jj), 4)); % data format issue, has to be rounded
    %t_drop = z_tsp(id_drop2);
    %subplot 211; hold on; xline(t_drop, 'g', 'Linewidth', 1);
    %subplot 212; hold on; xline(t_drop, 'g', 'Linewidth', 1);
%end



%% Define the folder paths
parent_folder = fullfile('..', 'figures'); % Folder one level up called 'figures'
target_folder = fullfile(parent_folder, 'micturationcycle figure'); % Subfolder within 'figures'

% Ensure the "figures/micturitioncycle figure" folder exists, create it if it doesn't
if ~exist(target_folder, 'dir')
    mkdir(target_folder);
    fprintf('The folder "%s" did not exist, so it was created.\n', target_folder);
else
    fprintf('The folder "%s" already exists.\n', target_folder);
end
%% define folder where to save results 

% Define folder one level up in a folder called 'figures'
destinationfolder_up = fullfile('..', 'figures');

% Save one folder up (figures)
fig1_filename = strrep(xy, '_555', '_fig1');
saveas(gcf, fullfile(destinationfolder_up, fig1_filename), 'png'); % Save as PNG

%% apply median filter to pressure measurement and calculate the derivative
z_val_Pfilt = smooth(z_val_p, 500);
z_val_Pfilt = transpose(z_val_Pfilt);
z_val_Pderiv = diff(z_val_Pfilt); %derivative of filtered pressure
z_val_dP = [z_val_Pderiv,corr]; % derivative array is 1 measurement point shorter after filtering, thus I add a 0 at the end
z_val_dP(1)=0; %set first value to 0, as this value is always very big

%% define variables within the time window 
w_val_p=z_val_p(w_idx); %pressure within the window
w_val_Pfilt = z_val_Pfilt(w_idx); %filtered pressure within window around peak
[w_idx_Pmax, w_val_Pmax] = findpeak(w_val_p); %peak within window around peak
w_tsp=z_tsp(w_idx); %timestamp within window around peak
w_val_dP = z_val_dP(w_idx); %derivative of pressure within window around peak

%% create array with 1 if threshold is reached, otherwise it's 0 
norm_threshold = max(w_val_dP)*deriv_threshold; % normalize threshold to max value of dP within window around peak
% norm_threshold = max(z_val_dP)*deriv_threshold; % normalize threshold to max value of dP within zoom
z_logi_thresh = (z_val_dP>=norm_threshold); %logical array when threshold is reached
z_idx_thresh = find(z_val_dP> norm_threshold); %index where threshold is reached
z_tsp_thresh = z_tsp(z_idx_thresh); %timestamp when threshold is reached

w_logi_thresh=z_logi_thresh(w_idx); %logical array when threshold is reached within window around peak
w_tsp_thresh=w_tsp(w_logi_thresh ==1); % timestamp when threshold is reached within window around peak 
w_idx_thresh = find(w_val_dP> norm_threshold); %index where threshold is reached within window around peak 

%% threhsold pressure
w_val_Pthresh = w_val_p(w_idx_thresh(1));
z_val_nPthresh = w_val_Pthresh - z_val_Pbase; %normalized threshold pressure
fprintf('\n normalised threshold detrusor pressure = %.2f cmH2O \n', z_val_nPthresh);
w_val_PthreshToPmax = z_val_nPmax - z_val_nPthresh;
fprintf('\n detrusor pressure amplitude from theshold to maximum = %.2f cmH2O \n', w_val_PthreshToPmax);

%% timepoint when threshold is reached the first time within window
w_idx_thresh1 = zeros(1,length(z_idx_thresh));
for ii = 1:length(z_idx_thresh)
    if (z_idx_Pmax(1)/fs)-(z_idx_thresh(ii)/fs) < pre && ((z_idx_Pmax(1)/fs)-(z_idx_thresh(ii)/fs)) > -post
    w_idx_thresh1(ii) = z_idx_thresh(ii);
    else
    end
end
z_idx_thresh2 = nonzeros(w_idx_thresh1);

%% times during one cycle: filling phase, contraction phase, BL after contraction
% filling: start - Pthresh
z_tsp_fill = z_tsp(1:z_idx_thresh2(1)); %timestamp of filling phase
z_val_fillDuration = max((z_tsp_fill)-min(z_tsp_fill))/60; %in minutes
z_idx_fill = z_idx(1:z_idx_thresh2(1)); % index from thresh till end of cycle

% Pthresh - end
z_tsp_thresh_end = z_tsp(z_idx_thresh2(1):end); %timestamp from thresh till end of cycle
z_val_thresh_endDuration = max((z_tsp_thresh_end)-min(z_tsp_thresh_end))/60; %in minutes
z_idx_thresh_end = (z_idx_thresh2(1)):length(z_idx); % index of contraction phase in whole cycle


% contraction: Pthresh - 10% between minimum after Pmax and Pmax 
% min P after Pmax
z_val_thresh_end = z_val_p(z_idx_thresh2(1):end);
[z_idx_Pmin_postMax, z_val_Pmin_postMax] = findmin(z_val_thresh_end);
z_val_nPmin_postMax = z_val_Pmin_postMax - z_val_Pbase;
% value of 10% between min after Pmax and Pmax
z_val_contrEnd = (z_val_Pmax - z_val_Pmin_postMax)*0.1 + z_val_Pmin_postMax;
z_val_ncontrEnd = z_val_contrEnd - z_val_Pbase;
z_logi_contrEnd = (z_val_thresh_end>=z_val_contrEnd); % logical array when value is higher than cutoff
z_idx_contrEnd = find(z_logi_contrEnd==0, 1, 'first'); %find the first occurance of a 0
z_tsp_contrEnd = z_tsp_thresh_end(z_idx_contrEnd); % timestamp of when contraction ends (=10% before BL)
z_idx_contrEnd3 = find(z_tsp==z_tsp_contrEnd);

%duration of the contraction
z_val_contrDuration = (z_tsp_contrEnd - max(z_tsp_fill))/60; %in minutes
%timestamp of contraction phase
z_idx_contr = (z_idx_thresh2(1)):(z_idx_contrEnd3); % index of contraction phase in whole cycle
z_tsp_contr = z_tsp(z_idx_contr);

% BL: contrEnd - end of cycle
z_val_BLDuration = (z_tsp(end) - z_tsp_contrEnd)/60; %in minutes
%timestamp of BL phase
z_idx_BL = (z_idx_contrEnd3):length(z_idx); % index of contraction phase in whole cycle
z_tsp_BL = z_tsp(z_idx_BL);


%% compliance
z_val_compl = z_val_fillDuration*20/z_val_nPthresh; % ul/cmH2O

%% Find the time-point when urine falls onto the scale
% find change in scale in the zoom window and sum up all the positive changes
z_val_diff = diff(z_val_scale);
z_val_scaleDiff = [z_val_diff, corr];
z_idx_scaleDiff_up = find(z_val_scaleDiff>0); 
z_val_vVoid = sum(z_val_scaleDiff(z_idx_scaleDiff_up))*1000; % sum of values in zoom with positive change in scale, in µl
fprintf('\n Voided volume in whole mic Cycle = %.2f µl', z_val_vVoid);

% find tsp of voiding in window
if isempty(z_tsps_drop)
    w_val_vVoid = 0;
else
    w_tsps_drop = zeros(1,length(z_tsps_drop));
    w_logis_drop = zeros(1,length(z_tsps_drop));
    for jj = 1:length(z_tsps_drop)
        if (z_tsp_Pmax(1)-z_tsps_drop(jj) < pre) && (z_tsp_Pmax(1)-z_tsps_drop(jj) > -post)
            w_tsps_drop (jj) = z_tsps_drop(jj);
            w_logis_drop(jj)= find(w_tsps_drop(jj)>0);
        else
        end
    end
    w_idxs_drop=z_idx_scaleDiff_up.*w_logis_drop; %create array with timestamps of positive scale changes
    w_idxs_drop = nonzeros(w_idxs_drop); % delet all values which are 0
    w_val_vVoid = sum(z_val_scaleDiff(w_idxs_drop))*1000; % sum of values of positive change in scale in window, in µl
end

fprintf('\n Voided volume in window around peak = %.2f µl \n', w_val_vVoid);


%% non-voiding contractions (15%)
cutoff_nonvoid_contr = w_val_Pthresh + w_val_PthreshToPmax*0.15;

%% determine number of NVC's 15% above threshold
z_val_Pfilt_NVC_tot = smooth(z_val_p, 2500);

% only look at the filling phase
z_val_Pfilt_NVC1 = z_val_Pfilt_NVC_tot(1:length(z_idx_fill));

% Set data smaller than threshold to 0 and higher to 1
z_val_Pfilt_NVC_15aboveThresh = zeros(1,length(z_val_Pfilt_NVC1));
for ii = 1:length(z_val_Pfilt_NVC1)
if z_val_Pfilt_NVC1(ii) < cutoff_nonvoid_contr
    z_val_Pfilt_NVC_15aboveThresh(ii) = 0;
else
    z_val_Pfilt_NVC_15aboveThresh(ii) = 1;
end
end

% Find peaks
[z_no_NVC_15aboveThresh,z_idx_NVC_15aboveThresh] = findpeaks(z_val_Pfilt_NVC_15aboveThresh);
fprintf('\n Number of NVCs during filling 15%% above Threshold: %d \n', length(z_no_NVC_15aboveThresh));

z_val_numberNVC_15aboveThresh = length(z_no_NVC_15aboveThresh);

%% determine number of NVC's at threshold
% Set data smaller than threshold to 0 and higher to 1
z_val_Pfilt_NVC = zeros(1,length(z_val_Pfilt_NVC1));
for ii = 1:length(z_val_Pfilt_NVC1)
if z_val_Pfilt_NVC1(ii) < w_val_Pthresh
    z_val_Pfilt_NVC(ii) = 0;
else
    z_val_Pfilt_NVC(ii) = 1;
end
end

% Find peaks
[z_no_NVC,z_idx_NVC] = findpeaks(z_val_Pfilt_NVC);
fprintf('\n Number of NVCs during filling at Threshold: %d \n', length(z_no_NVC));

z_val_numberNVC = length(z_no_NVC);

%% figure for NVC's

set(0,'DefaultFigureWindowStyle','docked')
h(4) = figure;

plot(z_tsp, z_val_p, z_tsp, z_val_Pfilt);
hold on;
plot_legend = plot(z_tsp, z_val_Pfilt_NVC_tot, 'Linewidth', 2);
hold on; %red line at Pmax
for ll = 1:length(z_tsp_Pmax)
    plot([z_tsp_Pmax(ll) z_tsp_Pmax(ll)], [min(z_val_p), max(z_val_p)], 'r', 'Linewidth', 1);
end
hold on;%green lines when urine falls onto scale
for jj = 1:length(z_tsps_drop)
    if (z_tsp_Pmax(1)-z_tsps_drop(jj) < pre) && (z_tsp_Pmax(1)-z_tsps_drop(jj) > -post)
        id_drop2 = find( round(z_tsp, 4) == round(z_tsps_drop(jj), 4));
        t_drop = z_tsp(id_drop2);
        hold on; xline(t_drop, 'g', 'Linewidth', 1);
    else
    end
end
yline(w_val_Pthresh, 'm', 'Linewidth', 1); %horizontal line indicating threshold
yline(cutoff_nonvoid_contr, 'm'); %horizontal line indicating 15% above threshold (between thresh and Pmax)
xline(w_tsp_thresh(1), 'm', 'Linewidth', 1); %vertical line when threshold is reached for the first time near the peak 
legend((plot_legend),{'filtered for NVC'}, 'Location', 'southwest');

%% define folder where to save results 

% Define folder one level up in a folder called 'figures'
destinationfolder_up = fullfile('..', 'figures', 'micturationcycle figure');

% Save one folder up (figures)
new_filename = strrep(xy, '_555', '_fig2');
saveas(gcf, fullfile(destinationfolder_up, new_filename), 'png'); % Save as PNG

%% convert the character vector xy to a string
Measurement_Name = convertCharsToStrings(xy);

%% Save the result table as csv file
% Convert the character vector xy to a string
Measurement_Name = convertCharsToStrings(xy);

% Navigate one folder up from the current directory
parentDir = fileparts(pwd);

% Define the path to the "output results" folder
outputDir = fullfile(parentDir, 'output results');

% Create the "output results" folder if it doesn't exist
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% Modify the file name for the CSV output
outputFileName = strrep(Measurement_Name, '_555', '_results.csv');

% Define the full path for the CSV file
outputFilePath = fullfile(outputDir, outputFileName);

% Open the file for writing
fileID = fopen(outputFilePath, 'w');

% Write the headers
fprintf(fileID, 'Measurement Name,Number of Peaks,Value of Peak (cmH2O),Normalized Max Detrusor Pressure (cmH2O),');
fprintf(fileID, 'Micturition Cycle Duration (min),Normalized Threshold Detrusor Pressure (cmH2O),');
fprintf(fileID, 'Detrusor Pressure Amplitude from Threshold to Maximum (cmH2O),Voided Volume in Whole Micturition Cycle (µl),');
fprintf(fileID, 'Voided Volume in Window around Peak (µl),Number of NVCs during Filling 15%% above Threshold,');
fprintf(fileID, 'Number of NVCs during Filling at Threshold\n');

% Write the data
fprintf(fileID, '%s,%01d,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%d,%d\n', ...
    Measurement_Name, length(z_idx_Pmax), z_val_Pmax, z_val_nPmax, ...
    z_val_MicDuration, z_val_nPthresh, w_val_PthreshToPmax, ...
    z_val_vVoid, w_val_vVoid, length(z_no_NVC_15aboveThresh), length(z_no_NVC));

% Close the file
fclose(fileID);

% Display the output file path
disp(['Output saved to ' outputFilePath]);

% Additional output messages
fprintf('\n \n Number of peaks = %01d, value of peak = %.2f cmH20 \n', length(z_idx_Pmax), z_val_Pmax);
fprintf('\n normalised maximal detrusor pressure = %.2f cmH2O \n', z_val_nPmax);
fprintf('\n Micturition cycle duration = %.2f min \n', z_val_MicDuration);
fprintf('\n normalised threshold detrusor pressure = %.2f cmH2O \n', z_val_nPthresh);
fprintf('\n detrusor pressure amplitude from threshold to maximum = %.2f cmH2O \n', w_val_PthreshToPmax);
fprintf('\n Voided volume in whole mic Cycle = %.2f µl', z_val_vVoid);
fprintf('\n Voided volume in window around peak = %.2f µl \n', w_val_vVoid);
fprintf('\n Number of NVCs during filling 15%% above Threshold: %d \n', length(z_no_NVC_15aboveThresh));
fprintf('\n Number of NVCs during filling at Threshold: %d \n', length(z_no_NVC));
%% normalize time of zoom to start at 0
z_tsp_n = z_tsp - z_tsp(1);
w_tsp_thresh_n = w_tsp_thresh(1) - z_tsp(1); %normalize threshold

%% find EMG signal between Pthresh and Pmax --> divide into active or silent --> used to analyse BL and Sham
[w_idx_Pthresh_Pmax] = findsection(z_tsp,z_idx_Pmax, z_idx_thresh2); % find the time slot between thresh to max --> is identical to the variable w_idx_tot_5
w_tsp_Pthresh_Pmax = z_tsp_n(w_idx_Pthresh_Pmax);  %variable containing timestamps from thresh to max
w_val_Pfilt_thresh_max = z_val_Pfilt(w_idx_Pthresh_Pmax); % variable containing filtered pressure from thresh to max
%w_val_emg_thresh_max = z_val_emg(w_idx_Pthresh_Pmax); % variable containing emg from thresh to max

% find prolonged timeslot, 1s before Pthresh to 1s after Pmax --> take the
% emg signal within this section --> find variables for hht --> apply a
% median filter to the EMG power --> delete the prolonged ends, so that
% only the section from Pthresh to Pmax stays
[w_idx_Pthresh_Pmax_prolonged] = findprolongedsection(z_tsp,z_idx_Pmax, z_idx_thresh2); % find the time slot between thresh to max and adds 1s (=5000 data points) to each end
w_val_emg_thresh_max_prolonged = z_val_emg(w_idx_Pthresh_Pmax_prolonged); % variable containing emg from 1s before thresh to 1s after max

%definition of variables for hht plot
imf_thresh_max_prolonged = emd(w_val_emg_thresh_max_prolonged, 'MaxNumIMF', 20,'Display',0);
[hs_thresh_max_prolonged,f_thresh_max_prolonged,time_thresh_max_prolonged,~,~] = hht(imf_thresh_max_prolonged,fs,'FrequencyLimits',[0 500]);

parfor ii = 1:length(hs_thresh_max_prolonged)
    eng_all_thresh_max_prolonged(ii) = sum( trapz(f_thresh_max_prolonged, hs_thresh_max_prolonged(:, ii)) ); % calculation of total energy
    eng_thresh_max_prolonged(ii) = sum( trapz( f_thresh_max_prolonged(1:5), hs_thresh_max_prolonged(1:5, ii) ) ); % calculation of 0-20 Hz energy content
end

% EMG power median filtered
w_val_EMGfilt_thresh_max_prolonged = smooth(eng_all_thresh_max_prolonged, 5000);
w_val_EMGfilt_thresh_max_prolonged = transpose(w_val_EMGfilt_thresh_max_prolonged);
w_val_EMGfilt_thresh_max = w_val_EMGfilt_thresh_max_prolonged(5000:(end-5001)); %remove the prolonged ends

% use filtered EMG signal, take median value
% as cutoff for silent or active
w_val_EMGcutoff25_thresh_max = prctile(w_val_EMGfilt_thresh_max,25);
w_val_EMGcutoff75_thresh_max = prctile(w_val_EMGfilt_thresh_max,75);

% make all values lower than cutoff25 equal to Pmax and all higher ones
% equal to Pbase
w_val_EMGfig25_thresh_max = w_val_EMGfilt_thresh_max;
w_val_EMGfig25_thresh_max(w_val_EMGfig25_thresh_max < w_val_EMGcutoff25_thresh_max) = -100;
w_val_EMGfig25_thresh_max(w_val_EMGfig25_thresh_max >= w_val_EMGcutoff25_thresh_max) = 100;
w_val_EMGfig25_thresh_max(w_val_EMGfig25_thresh_max == -100) = z_val_Pmax;
w_val_EMGfig25_thresh_max(w_val_EMGfig25_thresh_max == 100) = z_val_Pbase;

% make all values higher than cutoff75 equal to Pmax and all smaller ones
% equal to Pbase
w_val_EMGfig75_thresh_max = w_val_EMGfilt_thresh_max;
w_val_EMGfig75_thresh_max(w_val_EMGfig75_thresh_max >= w_val_EMGcutoff75_thresh_max) = z_val_Pmax;
w_val_EMGfig75_thresh_max(w_val_EMGfig75_thresh_max < w_val_EMGcutoff75_thresh_max) = z_val_Pbase;

% make all values between cutoff25 and cutoff75 equal to Pmax and rest
% equal to Pbase
w_val_EMGfigMid_thresh_max = w_val_EMGfilt_thresh_max;
w_val_EMGfigMid_thresh_max((w_val_EMGfigMid_thresh_max < w_val_EMGcutoff25_thresh_max) | (w_val_EMGfigMid_thresh_max > w_val_EMGcutoff75_thresh_max)) = 100;
w_val_EMGfigMid_thresh_max((w_val_EMGcutoff25_thresh_max < w_val_EMGfigMid_thresh_max) & (w_val_EMGfigMid_thresh_max < w_val_EMGcutoff75_thresh_max)) = -100;
w_val_EMGfigMid_thresh_max(w_val_EMGfigMid_thresh_max == 100) = z_val_Pbase;
w_val_EMGfigMid_thresh_max(w_val_EMGfigMid_thresh_max == -100) = z_val_Pmax;

% plot pressure with overlayed energy contents color coded from Pthresh 
% to Pmax
h (5) = figure;
area(w_tsp_Pthresh_Pmax,w_val_EMGfig25_thresh_max, z_val_Pbase, 'FaceColor', 	'#EDB120', 'FaceAlpha', [0.8]) % lower than 25th percentile
hold on
area(w_tsp_Pthresh_Pmax,w_val_EMGfigMid_thresh_max, z_val_Pbase, 'FaceColor', '#D95319', 'FaceAlpha', [0.8]) % between 25th and 75th percentile
hold on
area(w_tsp_Pthresh_Pmax,w_val_EMGfig75_thresh_max, z_val_Pbase, 'FaceColor', 	'#A2142F', 'FaceAlpha', [0.8]) % higher than 75th percentile
hold on
plot(z_tsp_n, z_val_Pfilt, 'color', 'k', 'Linewidth', 3) % filtered pressure signal
hold on
plot([z_idx_thresh2(1)/fs z_idx_thresh2(1)/fs], ylim, 'color', 'm', 'Linewidth', 2); % plot line when threshold is first reached within window
title(replace(xy, '_', '-'))
ylabel('Intravesical pressure [cmH_2O]')
xlabel('Time [s]')
set(gca,'FontSize',18)
ylim([(z_val_Pbase-0.5) (z_val_Pmax+0.5)])

%% define folder where to save results 

destinationfolder = './Results/Pthresh-Pmax';
saveas(gcf, fullfile(destinationfolder, xy), 'png'); %gcf returns the current figure handle 


%% find time windows in which energy content will be calculated (EMG signal)
% divide thresh-to-max in 5 equal length sections --> dividing by 5
% resulting in .0 -> no missing value; .2 -> 1 missing value; .4 -> 2
% missing values; .6 -> 3 missing values; .8 -> missing values just before
% Pmax
description1 = "1: PthreshToPmax 5 equal sections";
[w_idx_tot_5] = findsection(z_tsp,z_idx_Pmax, z_idx_thresh2); % find the time slot between thresh and Pmax (equal to w_idx_Pthresh_Pmax)

% duration (s) of one fifth from thresh to peak
w_duration_1_5 = length(w_idx_tot_5)/5/fs; 

% remove prolonged ends of energy content
eng_all_thresh_max = eng_all_thresh_max_prolonged(5000:(end-5001));
eng_thresh_max = eng_thresh_max_prolonged(5000:(end-5001));

% divide index from thresh to max into 5 equal sections
w_idx_1_5 = (1:floor(length(eng_thresh_max)/5));
w_idx_2_5 = (floor(length(eng_thresh_max)/5)+1:floor(length(eng_thresh_max)/5)*2);
w_idx_3_5 = ((floor(length(eng_thresh_max)/5)*2)+1:((floor(length(eng_thresh_max)/5))*3));
w_idx_4_5 = ((floor(length(eng_thresh_max)/5)*3)+1:((floor(length(eng_thresh_max)/5))*4));
w_idx_5_5 = ((floor(length(eng_thresh_max)/5)*4)+1:((floor(length(eng_thresh_max)/5))*5));

% divide total energy (0-500Hz) from thresh to max into 5 equal sections 
% and calculate sum
z_val_tot_eng_1_5 = sum(eng_all_thresh_max(w_idx_1_5));
z_val_tot_eng_2_5 = sum(eng_all_thresh_max(w_idx_2_5));
z_val_tot_eng_3_5 = sum(eng_all_thresh_max(w_idx_3_5));
z_val_tot_eng_4_5 = sum(eng_all_thresh_max(w_idx_4_5));
z_val_tot_eng_5_5 = sum(eng_all_thresh_max(w_idx_5_5));

% divide low energy (0-20Hz) from thresh to max into 5 equal sections 
% and calculate sum
z_val_low_eng_1_5 = sum(eng_thresh_max(w_idx_1_5));
z_val_low_eng_2_5 = sum(eng_thresh_max(w_idx_2_5));
z_val_low_eng_3_5 = sum(eng_thresh_max(w_idx_3_5));
z_val_low_eng_4_5 = sum(eng_thresh_max(w_idx_4_5));
z_val_low_eng_5_5 = sum(eng_thresh_max(w_idx_5_5));
fprintf('\n total energy 1_5 = %.2f, 2_5 = %.2f, 3_5 = %.2f, 4_5 = %.2f, 5_5 = %.2f \n 0-20Hz energy 1_5 = %.2f, 2_5 = %.2f, 3_5 = %.2f, 4_5 = %.2f, 5_5 = %.2f \n', z_val_tot_eng_1_5, z_val_tot_eng_2_5, z_val_tot_eng_3_5, z_val_tot_eng_4_5, z_val_tot_eng_5_5, z_val_low_eng_1_5, z_val_low_eng_2_5, z_val_low_eng_3_5, z_val_low_eng_4_5, z_val_low_eng_5_5);

%as percentages
total_tot_5 = z_val_tot_eng_1_5+z_val_tot_eng_2_5+z_val_tot_eng_3_5+z_val_tot_eng_4_5+z_val_tot_eng_5_5;
s1_5_tot_perc = z_val_tot_eng_1_5/total_tot_5*100; %in percent
s2_5_tot_perc = z_val_tot_eng_2_5/total_tot_5*100; %in percent
s3_5_tot_perc = z_val_tot_eng_3_5/total_tot_5*100; %in percent
s4_5_tot_perc = z_val_tot_eng_4_5/total_tot_5*100; %in percent
s5_5_tot_perc = z_val_tot_eng_5_5/total_tot_5*100; %in percent
total_low_5 = z_val_low_eng_1_5+z_val_low_eng_2_5+z_val_low_eng_3_5+z_val_low_eng_4_5+z_val_low_eng_5_5;
s1_5_low_perc = z_val_low_eng_1_5/total_low_5*100; %in percent
s2_5_low_perc = z_val_low_eng_2_5/total_low_5*100; %in percent
s3_5_low_perc = z_val_low_eng_3_5/total_low_5*100; %in percent
s4_5_low_perc = z_val_low_eng_4_5/total_low_5*100; %in percent
s5_5_low_perc = z_val_low_eng_5_5/total_low_5*100; %in percent
fprintf('\n percentage of total energy per fifth from Pthresh-to-Pmax: \n 1_5 = %.2f%%, 2_5 = %.2f%%, 3_5 = %.2f%%, 4_5 = %.2f%%, 5_5 = %.2f%% \n percentage of 0-20Hz energy per fifth from Pthresh-to-Pmax: \n 1_5 = %.2f%%, 2_5 = %.2f%%, 3_5 = %.2f%%, 4_5 = %.2f%%, 5_5 = %.2f%% \n', s1_5_tot_perc, s2_5_tot_perc, s3_5_tot_perc, s4_5_tot_perc, s5_5_tot_perc, s1_5_low_perc, s2_5_low_perc, s3_5_low_perc, s4_5_low_perc, s5_5_low_perc);


%% is voiding happening before or after Pmax?
% find timestamps of voiding between Pthresh and Pmax 
z_tsps_drop_pre = (z_tsp_Pmax(1) > z_tsps_drop) & (w_tsp_thresh(1) < z_tsps_drop);
z_tsps_drop_pre = z_tsps_drop(z_tsps_drop_pre);
% find timestamps of voiding after Pmax 
z_tsps_drop_post = (z_tsp_Pmax(1) < z_tsps_drop) & (z_tsp_Pmax(1)+post*fs > z_tsps_drop);
z_tsps_drop_post = z_tsps_drop(z_tsps_drop_post);

z_tsps_drop_pre1 = zeros(1,length(z_tsps_drop));
for jj = 1:length(z_tsps_drop)
    if (z_tsp_Pmax(1) > z_tsps_drop(jj)) && (w_tsp_thresh(1) < z_tsps_drop(jj))
        z_tsps_drop_pre1(jj) = 1; % between Pthresh and Pmax
    elseif (z_tsp_Pmax(1) < z_tsps_drop(jj)) && (z_tsp_Pmax(1)+post*fs > z_tsps_drop(jj))
        z_tsps_drop_pre1(jj) = 2; % 5s after Pmax
    else
        z_tsps_drop_pre1(jj) = 0; % elsewhere
    end
end

if any(z_tsps_drop_pre1(:) == 1) % only if there is a scale change between Pthresh - Pmax
    voiding_pre_peak = "yes";
    z_idx_drop_pre2 = find(abs(z_tsp-z_tsps_drop_pre(1))<0.001); %find index of first void occurance between Pthresh - Pmax. Need to search in this way because sometimes it doesnt find the values (floating value problems)
    z_idx_drop_pre2 = z_idx_drop_pre2-1+fs/5; % -1+fs/5 to find the index of first scale change between Pthresh - Pmax
    z_whenvoidhappens_perc = (z_idx_drop_pre2(1)-z_idx_thresh2(1))/(z_idx_Pmax(1)-z_idx_thresh2(1))*100; % at what percentage the first scalechange happens between thresh - Pmax
    %pressure when first scalechange occurs
    z_val_Pvoid = z_val_p(z_idx_drop_pre2);
    z_val_nPvoid = z_val_Pvoid - z_val_Pbase; %normalized pressure at first void occurance
else
    voiding_pre_peak = "no";
    z_whenvoidhappens_perc = "None during Pthresh - Pmax";
    z_val_nPvoid = NaN;
end


%% Inter-contraction Interval (ICI) --> used for SCI
% % find all the local peaks
% % z_val_peakProminence = amplitude of peak, measured from the higher local minimum 
% % z_val_peakWidth= width at half prominence
% [z_val_ICIpeaks,z_tsp_ICIpeaks,z_val_peakWidth,z_val_peakProm] = findpeaks(z_val_Pfilt, z_tsp_n, 'MinPeakDistance', 5, 'MinPeakProminence', 5);
% 
% % find all local minima
% [z_val_ICImin,z_tsp_ICImin] = findpeaks(-z_val_Pfilt, z_tsp_n, 'MinPeakDistance', 5, 'MinPeakProminence', 5);
% z_val_ICImin = -z_val_ICImin;
% 
% %timestamps of ICIpeaks
% z_idx_ICIpeaks = zeros(1,length(z_tsp_ICIpeaks));
% for ii = 1:length(z_tsp_ICIpeaks)
% z_idx_ICIpeaks(ii) = find(z_tsp_n == z_tsp_ICIpeaks(ii));
% end
% 
% %timestamps of ICI minima
% z_idx_ICImin = zeros(1,length(z_tsp_ICImin));
% for ii = 1:length(z_tsp_ICImin)
% z_idx_ICImin(ii) = find(z_tsp_n == z_tsp_ICImin(ii));
% end
% 
% % delete first peak if it occurs before the first minimum
% if z_idx_ICImin(1) > z_idx_ICIpeaks(1)
%     z_idx_ICIpeaks = z_idx_ICIpeaks(2:end);
%     z_tsp_ICIpeaks = z_tsp_ICIpeaks(2:end);
%     z_val_ICIpeaks = z_val_ICIpeaks(2:end);
%     z_val_peakProm = z_val_peakProm(2:end);
% end
% 
% % delete last minimum if it occurs after the last peak
% if z_idx_ICImin(end) > z_idx_ICIpeaks(end)
%     z_idx_ICImin(end) = [];
%     z_tsp_ICImin(end) = [];
%     z_val_ICImin(end) = [];
% end
% 
% % mean duration between two peaks
% z_val_ICImean = mean(diff(z_tsp_ICIpeaks));
% % mean peak prominence
% z_val_peakPromMean = mean(z_val_peakProm);
% % number of peaks
% z_val_ICINo = length(z_tsp_ICIpeaks);
% % Contraction amplitude from min to max
% z_val_ICIpeakAmpl = zeros(1,length(z_val_ICIpeaks));
% for ii = 1:length(z_tsp_ICIpeaks)
%     z_val_ICIpeakAmpl(ii) = z_val_ICIpeaks(ii)-z_val_ICImin(ii);
% end
% z_val_ICIpeakMeanAmpl = mean(z_val_ICIpeakAmpl);
% z_val_ICIpeakSDAmpl = std(z_val_ICIpeakAmpl); %standard deviation
% % duration of the contraction 
% z_val_ICIcontractionDuration = z_tsp_ICIpeaks - z_tsp_ICImin;
% 
% 
% %% look at each contraction independently
% % first create empty cells, then they will contain variables from local min to peak (ICI)
% % call a specific section using A{n} = ...
% 
% %%%%% Pressure signal
% 
% % create empty cells, then they will contain variables from local min
% % to peak (ICI) (timestamp and filtered pressure signal)
% ICIs_idx = cell(1,length(z_idx_ICIpeaks)); ICIs_tsp_n = ICIs_idx; ICIs_val_Pfilt = ICIs_idx;
% for ii = 1:length(z_idx_ICIpeaks)
% [ICIs_idx{ii}] = findsection(z_idx,z_idx_ICIpeaks(ii), z_idx_ICImin(ii)); % variable containing indices from local min to peak
% ICIs_tsp_n{ii} = z_tsp_n(ICIs_idx{ii});  %variable containing timestamps from local min to peak
% ICIs_val_Pfilt{ii} = z_val_Pfilt(ICIs_idx{ii}); % variable containing filtered pressure from local min to peak
% end
% 
% %%%%% EMG signal
% 
% % create prolonged cells, that contain each timespan from min to peak (ICI)
% % from the EMG data
% % prolonged ends are created to be able to apply a smooth filter afterwards
% ICIs_idx_prolonged = cell(1,length(z_idx_ICIpeaks)); ICIs_tsp_n_prolonged = ICIs_idx_prolonged; ICIs_val_emg_prolonged = ICIs_idx_prolonged;
% for ii = 1:length(z_idx_ICIpeaks)
%     [ICIs_idx_prolonged{ii}] = findprolsection(z_idx,z_idx_ICIpeaks(ii), z_idx_ICImin(ii)); % variable containing indices from 1s before local min to 1s after peak
%     ICIs_tsp_n_prolonged{ii} = z_tsp_n(ICIs_idx_prolonged{ii});  %variable containing timestamps from 1s before local min to 1s after peak
%     ICIs_val_emg_prolonged{ii} = z_val_emg(ICIs_idx_prolonged{ii}); % variable containing EMG from 1s before local min to 1s after peak
% end
% 
% % Definition of variables for hht plot (prolonged)
% imf = cell(1,length(z_idx_ICIpeaks)); hs = imf; time = imf;
% for ii = 1:length(z_idx_ICIpeaks)
%     imf{ii} = emd(ICIs_val_emg_prolonged{ii}, 'MaxNumIMF', 20,'Display',0);
%     [hs{ii},f{ii},time{ii},~,~] = hht(imf{ii},fs,'FrequencyLimits',[0 500]);
% end
% 
% % calculate energy content of each contraction (prolonged)
% eng_all = cell(1,length(z_idx_ICIpeaks)); eng = cell(1,length(z_idx_ICIpeaks));
% parfor jj = 1:length(hs)
%     for ii = 1:length(hs{jj})
%         eng_all{jj}(ii) = sum( trapz(f{jj}, hs{jj}(:, ii)) ); % calculation of total energy
%         eng{jj}(ii) = sum( trapz( f{jj}(1:5), hs{jj}(1:5, ii) ) ); % calculation of 0-20 Hz energy content
%     end
% end
% 
% %% analyse total Energy content of EMG per contraction, 5th's
% % remove prolonged ends from EMG energy because here, we don't apply a
% % filter
% % total energy (0-250Hz)
% ICIs_val_emg_all5 = eng_all; ICIs_val_emg_all_1_5 = ICIs_val_emg_all5; ICIs_val_emg_all_2_5 = ICIs_val_emg_all5; ICIs_val_emg_all_3_5 = ICIs_val_emg_all5; ICIs_val_emg_all_4_5 = ICIs_val_emg_all5; ICIs_val_emg_all_5_5 = ICIs_val_emg_all5; ICIs_val_emg_all_5 = ICIs_val_emg_all5; ICIs_val_emg_all5_first = ICIs_val_emg_all5; ICIs_val_emg_all5_middle = ICIs_val_emg_all5; ICIs_val_emg_all5_last = ICIs_val_emg_all5;% dummy cells
% for ii = 1:length(eng_all)
%     ICIs_val_emg_all5{ii} = eng_all{ii}(5000:(end-5001)); %remove the prolonged ends
%     ICIs_val_emg_all_1_5{ii} = sum(ICIs_val_emg_all5{ii}(1:ceil(end/5)));% sum of energy in the first fifth
%     ICIs_val_emg_all_2_5{ii} = sum(ICIs_val_emg_all5{ii}(ceil(end/5):floor(end/5*2)));% sum of energy in the second fifth
%     ICIs_val_emg_all_3_5{ii} = sum(ICIs_val_emg_all5{ii}(ceil(end/5*2):floor(end/5*3)));% sum of energy in the third fifth
%     ICIs_val_emg_all_4_5{ii} = sum(ICIs_val_emg_all5{ii}(ceil(end/5*3):floor(end/5*4)));% sum of energy in the fourth fifth
%     ICIs_val_emg_all_5_5{ii} = sum(ICIs_val_emg_all5{ii}(ceil(end/5*4):floor(end)));% sum of energy in the fifth fifth
%     ICIs_val_emg_all_5{ii} = sum(ICIs_val_emg_all5{ii}(1:end));% sum of energy in the whole section from local min to local max
%     % look at 2first fifths, middle fifth and 2 last fifths
%     ICIs_val_emg_all5_first{ii} = (ICIs_val_emg_all_1_5{ii} + ICIs_val_emg_all_2_5{ii})/2; %mean of first section
%     ICIs_val_emg_all5_middle{ii} = ICIs_val_emg_all_3_5{ii}; % middle section
%     ICIs_val_emg_all5_last{ii} = (ICIs_val_emg_all_4_5{ii} + ICIs_val_emg_all_5_5{ii})/2; %mean of last section
% end
% 
% %automatically determine whether activity is increasing, decreasing or v
% %shaped
% ICIs_val_emg_all5_code = ICIs_val_emg_all5; %dummy
% 
% for ii = 1:length(ICIs_val_emg_all5)
% ICIs_val_emg_all5_code{ii} = 0;
% % lowest activity -> 1
% % intermediate activity -> 2
% % highest activity -> 3
% % voiding contractions: 
% % 1   2   3 --> 5
% % 1   3   2 --> 6
% if (ICIs_val_emg_all5_first{ii} < ICIs_val_emg_all5_middle{ii}) && (ICIs_val_emg_all5_middle{ii} < ICIs_val_emg_all5_last{ii})
%     ICIs_val_emg_all5_code{ii} = 5;
% end
% if (ICIs_val_emg_all5_first{ii} < ICIs_val_emg_all5_last{ii}) && (ICIs_val_emg_all5_last{ii} < ICIs_val_emg_all5_middle{ii})
%     ICIs_val_emg_all5_code{ii} = 6;
% end
% % non-voiding contractions
% % 3   1   2 --> 1
% % 2   1   3 --> 2
% % 3   2   1 --> 3
% % 2   3   1 --> 4
% if (ICIs_val_emg_all5_middle{ii} < ICIs_val_emg_all5_last{ii}) && (ICIs_val_emg_all5_last{ii} < ICIs_val_emg_all5_first{ii})
%     ICIs_val_emg_all5_code{ii} =1;
% end
% if (ICIs_val_emg_all5_middle{ii} < ICIs_val_emg_all5_first{ii}) && (ICIs_val_emg_all5_first{ii} < ICIs_val_emg_all5_last{ii})
%     ICIs_val_emg_all5_code{ii} =2;
% end
% if (ICIs_val_emg_all5_last{ii} < ICIs_val_emg_all5_middle{ii}) && (ICIs_val_emg_all5_middle{ii} < ICIs_val_emg_all5_first{ii})
%     ICIs_val_emg_all5_code{ii} =3;
% end
% if (ICIs_val_emg_all5_last{ii} < ICIs_val_emg_all5_first{ii}) && (ICIs_val_emg_all5_first{ii} < ICIs_val_emg_all5_middle{ii})
%     ICIs_val_emg_all5_code{ii} =4;
% end
% end
% 
% 
% % make array
% ICIs_val_emg_all5_code = cell2mat(ICIs_val_emg_all5_code); 
% 
% % number of contractions per code (increasing, decreasing, v shaped)
% ICI_emg_all5_Code1 = sum (ICIs_val_emg_all5_code == 1);
% ICI_emg_all5_Code2 = sum (ICIs_val_emg_all5_code == 2);
% ICI_emg_all5_Code3 = sum (ICIs_val_emg_all5_code == 3);
% ICI_emg_all5_Code4 = sum (ICIs_val_emg_all5_code == 4);
% ICI_emg_all5_Code5 = sum (ICIs_val_emg_all5_code == 5);
% ICI_emg_all5_Code6 = sum (ICIs_val_emg_all5_code == 6);
% ICI_emg_all5_No = ICI_emg_all5_Code1+ICI_emg_all5_Code2+ICI_emg_all5_Code3+ICI_emg_all5_Code4+ICI_emg_all5_Code5+ICI_emg_all5_Code6;
% ICI_emg_all5_Void = ICI_emg_all5_Code1+ICI_emg_all5_Code2+ICI_emg_all5_Code3+ICI_emg_all5_Code4;
% ICI_emg_all5_nonVoid = ICI_emg_all5_Code5+ICI_emg_all5_Code6;
% 
% % %%%%%%%%%%%%%%%%%%%%%%%%%
% %% analyse low Energy content of EMG per contraction, 5th's
% % remove prolonged ends from EMG energy because here, we don't apply a
% % filter
% % total energy (0-250Hz)
% ICIs_val_emg_low5 = eng; ICIs_val_emg_low_1_5 = ICIs_val_emg_low5; ICIs_val_emg_low_2_5 = ICIs_val_emg_low5; ICIs_val_emg_low_3_5 = ICIs_val_emg_low5; ICIs_val_emg_low_4_5 = ICIs_val_emg_low5; ICIs_val_emg_low_5_5 = ICIs_val_emg_low5; ICIs_val_emg_low_5 = ICIs_val_emg_low5; ICIs_val_emg_low5_first = ICIs_val_emg_low5; ICIs_val_emg_low5_middle = ICIs_val_emg_low5; ICIs_val_emg_low5_last = ICIs_val_emg_low5;% dummy cells
% for ii = 1:length(eng)
%     ICIs_val_emg_low5{ii} = eng{ii}(5000:(end-5001)); %remove the prolonged ends
%     ICIs_val_emg_low_1_5{ii} = sum(ICIs_val_emg_low5{ii}(1:ceil(end/5)));% sum of energy in the first fifth
%     ICIs_val_emg_low_2_5{ii} = sum(ICIs_val_emg_low5{ii}(ceil(end/5):floor(end/5*2)));% sum of energy in the second fifth
%     ICIs_val_emg_low_3_5{ii} = sum(ICIs_val_emg_low5{ii}(ceil(end/5*2):floor(end/5*3)));% sum of energy in the third fifth
%     ICIs_val_emg_low_4_5{ii} = sum(ICIs_val_emg_low5{ii}(ceil(end/5*3):floor(end/5*4)));% sum of energy in the fourth fifth
%     ICIs_val_emg_low_5_5{ii} = sum(ICIs_val_emg_low5{ii}(ceil(end/5*4):floor(end)));% sum of energy in the fifth fifth
%     ICIs_val_emg_low_5{ii} = sum(ICIs_val_emg_low5{ii}(1:end));% sum of energy in the whole section from local min to local max
%     % look at 2first fifths, middle fifth and 2 last fifths
%     ICIs_val_emg_low5_first{ii} = (ICIs_val_emg_low_1_5{ii} + ICIs_val_emg_low_2_5{ii})/2; %mean of first section
%     ICIs_val_emg_low5_middle{ii} = ICIs_val_emg_low_3_5{ii}; % middle section
%     ICIs_val_emg_low5_last{ii} = (ICIs_val_emg_low_4_5{ii} + ICIs_val_emg_low_5_5{ii})/2; %mean of last section
% end
% 
% %automatically determine whether activity is increasing, decreasing or v
% %shaped
% ICIs_val_emg_low5_code = ICIs_val_emg_low5; %dummy
% 
% for ii = 1:length(ICIs_val_emg_low5)
% ICIs_val_emg_low5_code{ii} = 0;
% % lowest activity -> 1
% % intermediate activity -> 2
% % highest activity -> 3
% % voiding contractions: 
% % 1   2   3 --> 5
% % 1   3   2 --> 6
% if (ICIs_val_emg_low5_first{ii} < ICIs_val_emg_low5_middle{ii}) && (ICIs_val_emg_low5_middle{ii} < ICIs_val_emg_low5_last{ii})
%     ICIs_val_emg_low5_code{ii} = 5;
% end
% if (ICIs_val_emg_low5_first{ii} < ICIs_val_emg_low5_last{ii}) && (ICIs_val_emg_low5_last{ii} < ICIs_val_emg_low5_middle{ii})
%     ICIs_val_emg_low5_code{ii} = 6;
% end
% % non-voiding contractions
% % 3   1   2 --> 1
% % 2   1   3 --> 2
% % 3   2   1 --> 3
% % 2   3   1 --> 4
% if (ICIs_val_emg_low5_middle{ii} < ICIs_val_emg_low5_last{ii}) && (ICIs_val_emg_low5_last{ii} < ICIs_val_emg_low5_first{ii})
%     ICIs_val_emg_low5_code{ii} =1;
% end
% if (ICIs_val_emg_low5_middle{ii} < ICIs_val_emg_low5_first{ii}) && (ICIs_val_emg_low5_first{ii} < ICIs_val_emg_low5_last{ii})
%     ICIs_val_emg_low5_code{ii} =2;
% end
% if (ICIs_val_emg_low5_last{ii} < ICIs_val_emg_low5_middle{ii}) && (ICIs_val_emg_low5_middle{ii} < ICIs_val_emg_low5_first{ii})
%     ICIs_val_emg_low5_code{ii} =3;
% end
% if (ICIs_val_emg_low5_last{ii} < ICIs_val_emg_low5_first{ii}) && (ICIs_val_emg_low5_first{ii} < ICIs_val_emg_low5_middle{ii})
%     ICIs_val_emg_low5_code{ii} =4;
% end
% end
% 
% % make array
% ICIs_val_emg_low5_code = cell2mat(ICIs_val_emg_low5_code); 
% 
% % number of contractions per code (increasing, decreasing, v shaped)
% ICI_emg_low5_Code1 = sum (ICIs_val_emg_low5_code == 1);
% ICI_emg_low5_Code2 = sum (ICIs_val_emg_low5_code == 2);
% ICI_emg_low5_Code3 = sum (ICIs_val_emg_low5_code == 3);
% ICI_emg_low5_Code4 = sum (ICIs_val_emg_low5_code == 4);
% ICI_emg_low5_Code5 = sum (ICIs_val_emg_low5_code == 5);
% ICI_emg_low5_Code6 = sum (ICIs_val_emg_low5_code == 6);
% ICI_emg_low5_No = ICI_emg_low5_Code1+ICI_emg_low5_Code2+ICI_emg_low5_Code3+ICI_emg_low5_Code4+ICI_emg_low5_Code5+ICI_emg_low5_Code6;
% ICI_emg_low5_Void = ICI_emg_low5_Code1+ICI_emg_low5_Code2+ICI_emg_low5_Code3+ICI_emg_low5_Code4;
% ICI_emg_low5_nonVoid = ICI_emg_low5_Code5+ICI_emg_low5_Code6;
% 
% 
% %% analyse total Energy content of EMG per contraction, 3rd's
% % remove prolonged ends from EMG energy because here, we don't apply a
% % filter
% % total energy (0-250Hz)
% ICIs_val_emg_all3 = eng_all; ICIs_val_emg_all_1_3 = ICIs_val_emg_all3; ICIs_val_emg_all_2_3 = ICIs_val_emg_all3; ICIs_val_emg_all_3_3 = ICIs_val_emg_all3; ICIs_val_emg_all_3 = ICIs_val_emg_all3;% dummy cells
% for ii = 1:length(eng_all)
%     ICIs_val_emg_all3{ii} = eng_all{ii}(5000:(end-5001)); %remove the prolonged ends
%     ICIs_val_emg_all_1_3{ii} = sum(ICIs_val_emg_all3{ii}(1:ceil(end/3)));% sum of energy in the first third
%     ICIs_val_emg_all_2_3{ii} = sum(ICIs_val_emg_all3{ii}(ceil(end/3):floor(end/3*2)));% sum of energy in the second third
%     ICIs_val_emg_all_3_3{ii} = sum(ICIs_val_emg_all3{ii}(ceil(end/3*2):floor(end/3*3)));% sum of energy in the third third
%     ICIs_val_emg_all_3{ii} = sum(ICIs_val_emg_all3{ii}(1:end));% sum of energy in the whole section from local min to local max
% end
% 
% %automatically determine whether activity is increasing, decreasing or v
% %shaped
% ICIs_val_emg_all3_code = ICIs_val_emg_all3; %dummy
% 
% for ii = 1:length(ICIs_val_emg_all3)
% ICIs_val_emg_all3_code{ii} = 0;
% % lowest activity -> 1
% % intermediate activity -> 2
% % highest activity -> 3
% % voiding contractions: 
% % 1   2   3 --> 5
% % 1   3   2 --> 6
% if (ICIs_val_emg_all_1_3{ii} < ICIs_val_emg_all_2_3{ii}) && (ICIs_val_emg_all_2_3{ii} < ICIs_val_emg_all_3_3{ii})
%     ICIs_val_emg_all3_code{ii} = 5;
% end
% if (ICIs_val_emg_all_1_3{ii} < ICIs_val_emg_all_3_3{ii}) && (ICIs_val_emg_all_3_3{ii} < ICIs_val_emg_all_2_3{ii})
%     ICIs_val_emg_all3_code{ii} = 6;
% end
% % non-voiding contractions
% % 3   1   2 --> 1
% % 2   1   3 --> 2
% % 3   2   1 --> 3
% % 2   3   1 --> 4
% if (ICIs_val_emg_all_2_3{ii} < ICIs_val_emg_all_3_3{ii}) && (ICIs_val_emg_all_3_3{ii} < ICIs_val_emg_all_1_3{ii})
%     ICIs_val_emg_all3_code{ii} =1;
% end
% if (ICIs_val_emg_all_2_3{ii} < ICIs_val_emg_all_1_3{ii}) && (ICIs_val_emg_all_1_3{ii} < ICIs_val_emg_all_3_3{ii})
%     ICIs_val_emg_all3_code{ii} =2;
% end
% if (ICIs_val_emg_all_3_3{ii} < ICIs_val_emg_all_2_3{ii}) && (ICIs_val_emg_all_2_3{ii} < ICIs_val_emg_all_1_3{ii})
%     ICIs_val_emg_all3_code{ii} =3;
% end
% if (ICIs_val_emg_all_3_3{ii} < ICIs_val_emg_all_1_3{ii}) && (ICIs_val_emg_all_1_3{ii} < ICIs_val_emg_all_2_3{ii})
%     ICIs_val_emg_all3_code{ii} =4;
% end
% end
% 
% 
% % make array
% ICIs_val_emg_all3_code = cell2mat(ICIs_val_emg_all3_code); 
% 
% % number of contractions per code (increasing, decreasing, v shaped)
% ICI_emg_all3_Code1 = sum (ICIs_val_emg_all3_code == 1);
% ICI_emg_all3_Code2 = sum (ICIs_val_emg_all3_code == 2);
% ICI_emg_all3_Code3 = sum (ICIs_val_emg_all3_code == 3);
% ICI_emg_all3_Code4 = sum (ICIs_val_emg_all3_code == 4);
% ICI_emg_all3_Code5 = sum (ICIs_val_emg_all3_code == 5);
% ICI_emg_all3_Code6 = sum (ICIs_val_emg_all3_code == 6);
% ICI_emg_all3_No = ICI_emg_all3_Code1+ICI_emg_all3_Code2+ICI_emg_all3_Code3+ICI_emg_all3_Code4+ICI_emg_all3_Code5+ICI_emg_all3_Code6;
% ICI_emg_all3_Void = ICI_emg_all3_Code1+ICI_emg_all3_Code2+ICI_emg_all3_Code3+ICI_emg_all3_Code4;
% ICI_emg_all3_nonVoid = ICI_emg_all3_Code5+ICI_emg_all3_Code6;
% 
% 
% %% analyse low Energy content of EMG per contraction, 3rd's
% % remove prolonged ends from EMG energy because here, we don't apply a
% % filter
% % total energy (0-250Hz)
% ICIs_val_emg_low3 = eng; ICIs_val_emg_low_1_3 = ICIs_val_emg_low3; ICIs_val_emg_low_2_3 = ICIs_val_emg_low3; ICIs_val_emg_low_3_3 = ICIs_val_emg_low3; ICIs_val_emg_low_3 = ICIs_val_emg_low3;% dummy cells
% for ii = 1:length(eng)
%     ICIs_val_emg_low3{ii} = eng{ii}(5000:(end-5001)); %remove the prolonged ends
%     ICIs_val_emg_low_1_3{ii} = sum(ICIs_val_emg_low3{ii}(1:ceil(end/3)));% sum of energy in the first third
%     ICIs_val_emg_low_2_3{ii} = sum(ICIs_val_emg_low3{ii}(ceil(end/3):floor(end/3*2)));% sum of energy in the second third
%     ICIs_val_emg_low_3_3{ii} = sum(ICIs_val_emg_low3{ii}(ceil(end/3*2):floor(end/3*3)));% sum of energy in the third third
%     ICIs_val_emg_low_3{ii} = sum(ICIs_val_emg_low3{ii}(1:end));% sum of energy in the whole section from local min to local max
% end
% 
% %automatically determine whether activity is increasing, decreasing or v
% %shaped
% ICIs_val_emg_low3_code = ICIs_val_emg_low3; %dummy
% 
% for ii = 1:length(ICIs_val_emg_low3)
% ICIs_val_emg_low3_code{ii} = 0;
% % lowest activity -> 1
% % intermediate activity -> 2
% % highest activity -> 3
% % voiding contractions: 
% % 1   2   3 --> 5
% % 1   3   2 --> 6
% if (ICIs_val_emg_low_1_3{ii} < ICIs_val_emg_low_2_3{ii}) && (ICIs_val_emg_low_2_3{ii} < ICIs_val_emg_low_3_3{ii})
%     ICIs_val_emg_low3_code{ii} = 5;
% end
% if (ICIs_val_emg_low_1_3{ii} < ICIs_val_emg_low_3_3{ii}) && (ICIs_val_emg_low_3_3{ii} < ICIs_val_emg_low_2_3{ii})
%     ICIs_val_emg_low3_code{ii} = 6;
% end
% % non-voiding contractions
% % 3   1   2 --> 1
% % 2   1   3 --> 2
% % 3   2   1 --> 3
% % 2   3   1 --> 4
% if (ICIs_val_emg_low_2_3{ii} < ICIs_val_emg_low_3_3{ii}) && (ICIs_val_emg_low_3_3{ii} < ICIs_val_emg_low_1_3{ii})
%     ICIs_val_emg_low3_code{ii} =1;
% end
% if (ICIs_val_emg_low_2_3{ii} < ICIs_val_emg_low_1_3{ii}) && (ICIs_val_emg_low_1_3{ii} < ICIs_val_emg_low_3_3{ii})
%     ICIs_val_emg_low3_code{ii} =2;
% end
% if (ICIs_val_emg_low_3_3{ii} < ICIs_val_emg_low_2_3{ii}) && (ICIs_val_emg_low_2_3{ii} < ICIs_val_emg_low_1_3{ii})
%     ICIs_val_emg_low3_code{ii} =3;
% end
% if (ICIs_val_emg_low_3_3{ii} < ICIs_val_emg_low_1_3{ii}) && (ICIs_val_emg_low_1_3{ii} < ICIs_val_emg_low_2_3{ii})
%     ICIs_val_emg_low3_code{ii} =4;
% end
% end
% 
% 
% % make array
% ICIs_val_emg_low3_code = cell2mat(ICIs_val_emg_low3_code); 
% 
% % number of contractions per code (increasing, decreasing, v shaped)
% ICI_emg_low3_Code1 = sum (ICIs_val_emg_low3_code == 1);
% ICI_emg_low3_Code2 = sum (ICIs_val_emg_low3_code == 2);
% ICI_emg_low3_Code3 = sum (ICIs_val_emg_low3_code == 3);
% ICI_emg_low3_Code4 = sum (ICIs_val_emg_low3_code == 4);
% ICI_emg_low3_Code5 = sum (ICIs_val_emg_low3_code == 5);
% ICI_emg_low3_Code6 = sum (ICIs_val_emg_low3_code == 6);
% ICI_emg_low3_No = ICI_emg_low3_Code1+ICI_emg_low3_Code2+ICI_emg_low3_Code3+ICI_emg_low3_Code4+ICI_emg_low3_Code5+ICI_emg_low3_Code6;
% ICI_emg_low3_Void = ICI_emg_low3_Code1+ICI_emg_low3_Code2+ICI_emg_low3_Code3+ICI_emg_low3_Code4;
% ICI_emg_low3_nonVoid = ICI_emg_low3_Code5+ICI_emg_low3_Code6;
% 
% 
% %% graphical representations, using percentiles
% % apply smooth filter to the prolonged EMG power signal --> remove the prolonged ends
% % and calculate the percentiles as cutoff values for active, intermediate
% % and silent phases
% ICIs_val_EMGfilt_prolonged = cell(1,length(eng_all)); ICIs_val_EMGfilt = ICIs_val_EMGfilt_prolonged; ICIs_val_EMGcutoff25 = ICIs_val_EMGfilt_prolonged; ICIs_val_EMGcutoff75 = ICIs_val_EMGfilt_prolonged;
% for ii = 1:length(eng_all)
%     ICIs_val_EMGfilt_prolonged{ii}= smooth(eng_all{ii}, 5000); % variable containing filtered EMG power from 1s before local min to 1s after peak
%     ICIs_val_EMGfilt{ii} = ICIs_val_EMGfilt_prolonged{ii}(5000:(end-5001)); %remove the prolonged ends
%     % divide contraction into active, intermediate and silent phase
%     ICIs_val_EMGcutoff25{ii} = prctile(ICIs_val_EMGfilt{ii},25);
%     ICIs_val_EMGcutoff75{ii} = prctile(ICIs_val_EMGfilt{ii},75);
% end
% 
% ICIs_val_EMGfig25 = ICIs_val_EMGfilt; ICIs_val_EMGfig75 = ICIs_val_EMGfilt; ICIs_val_EMGfigMid = ICIs_val_EMGfilt;
% for ii = 1:length(ICIs_val_EMGfig25)
% % make all values lower than cutoff25 equal to Pmax and all higher ones
% % equal to Pbase
% ICIs_val_EMGfig25{ii}(ICIs_val_EMGfig25{ii} < ICIs_val_EMGcutoff25{ii}) = -100;
% ICIs_val_EMGfig25{ii}(ICIs_val_EMGfig25{ii} >= ICIs_val_EMGcutoff25{ii}) = 100;
% ICIs_val_EMGfig25{ii}(ICIs_val_EMGfig25{ii} == -100) = z_val_Pmax;
% ICIs_val_EMGfig25{ii}(ICIs_val_EMGfig25{ii} == 100) = z_val_Pbase;
% 
% % make all values higher than cutoff75 equal to Pmax and all smaller ones
% % equal to Pbase
% ICIs_val_EMGfig75{ii}(ICIs_val_EMGfig75{ii} >= ICIs_val_EMGcutoff75{ii}) = z_val_Pmax;
% ICIs_val_EMGfig75{ii}(ICIs_val_EMGfig75{ii} < ICIs_val_EMGcutoff75{ii}) = z_val_Pbase;
% 
% % make all values between cutoff25 and cutoff75 equal to Pmax and rest
% % equal to Pbase
% ICIs_val_EMGfigMid{ii}((ICIs_val_EMGfigMid{ii} < ICIs_val_EMGcutoff25{ii}) | (ICIs_val_EMGfigMid{ii} > ICIs_val_EMGcutoff75{ii})) = 100;
% ICIs_val_EMGfigMid{ii}((ICIs_val_EMGcutoff25{ii} < ICIs_val_EMGfigMid{ii}) & (ICIs_val_EMGfigMid{ii} < ICIs_val_EMGcutoff75{ii})) = -100;
% ICIs_val_EMGfigMid{ii}(ICIs_val_EMGfigMid{ii} == 100) = z_val_Pbase;
% ICIs_val_EMGfigMid{ii}(ICIs_val_EMGfigMid{ii} == -100) = z_val_Pmax;
% end
% 
% % plot the local peaks and minima with overlayed energy contents color coded
% h (5) = figure;
% %this section is for the color coding of the percentiles
% % for ii = 1:length(ICIs_tsp_n)
% %     hold on; area(ICIs_tsp_n{ii},ICIs_val_EMGfig25{ii}, z_val_Pbase, 'FaceColor', 	'#EDB120', 'FaceAlpha', [0.8]) % lower than 25th percentile
% %     hold on; area(ICIs_tsp_n{ii},ICIs_val_EMGfigMid{ii}, z_val_Pbase, 'FaceColor', '#D95319', 'FaceAlpha', [0.8]) % between 25th and 75th percentile
% %     hold on; area(ICIs_tsp_n{ii},ICIs_val_EMGfig75{ii}, z_val_Pbase, 'FaceColor', 	'#A2142F', 'FaceAlpha', [0.8]) % higher than 75th percentile
% % end
% % hold on
% plot(z_tsp_n, z_val_Pfilt, 'color', 'k', 'Linewidth', 3) % filtered pressure signal
% hold on
% plot(z_tsp_ICIpeaks, z_val_ICIpeaks, 'v', 'color', 'b', 'Linewidth', 2) % indicates local peaks
% hold on
% plot(z_tsp_ICImin, z_val_ICImin, '^', 'color', 'b', 'Linewidth', 2) % indicates local minima
% text(z_tsp_ICImin+1.5,z_val_ICImin,num2str((1:numel(z_val_ICImin))'), 'fontweight', 'bold', 'Color', 'b', 'FontSize', 18) % number the minima
% hold on
% plot([z_idx_thresh2(1)/fs z_idx_thresh2(1)/fs], ylim, 'color', 'm', 'Linewidth', 2); % plot line when threshold is first reached within window
% hold on
% text(z_tsp_ICIpeaks+1.5,z_val_ICIpeaks,num2str((1:numel(z_val_ICIpeaks))'), 'fontweight', 'bold', 'Color', 'b', 'FontSize', 18) % number the peaks
% title(replace(xy, '_', '-'))
% ylabel('Intravesical pressure [cmH_2O]')
% xlabel('Time [s]')
% set(gca,'FontSize',18)
% ylim([(z_val_Pbase-0.5) (z_val_Pmax+0.5)])
% 
% %% define folder where to save results 
% 
% destinationfolder = 'C:\Michelle\MatLab\202105_T1SCI\Data\Results\ICI_EMG';
% saveas(gcf, fullfile(destinationfolder, xy), 'png'); %gcf returns the current figure handle 
% 
%% convert the character vector xy to a string
Measurement_Name = convertCharsToStrings(xy);

%% Save the result table as csv file --> BL/sham
T = table(Measurement_Name, deriv_threshold, norm_threshold, z_val_Pbase, z_val_nPthresh, z_val_nPmax, z_val_PmaxDuration, ...
    w_val_PthreshToPmax, z_val_MicDuration, z_val_vVoid, w_val_vVoid, ...
    z_val_fillDuration, z_val_thresh_endDuration, z_val_compl, z_val_ncontrEnd, z_val_nPmin_postMax, ...
    z_val_numberNVC_15aboveThresh, z_val_numberNVC, ...
    e_val_RecordingTime, a_val_Pbase, a_val_nPmax, ...
    ...
    voiding_pre_peak, z_whenvoidhappens_perc, z_val_nPvoid, ...
    ...
    w_val_EMGcutoff25_thresh_max, w_val_EMGcutoff75_thresh_max, ...
    ...
    description1, w_duration_1_5, ...
    z_val_tot_eng_1_5, z_val_tot_eng_2_5, z_val_tot_eng_3_5, z_val_tot_eng_4_5, z_val_tot_eng_5_5, ...
    z_val_low_eng_1_5, z_val_low_eng_2_5, z_val_low_eng_3_5, z_val_low_eng_4_5, z_val_low_eng_5_5);


T(1,:);
Result_Table = fullfile([destinationfolder, '/', xy, '.csv']);
writetable(T,Result_Table)

%% Save the result table as csv file --> SCI
% T = table(Measurement_Name, threshold, norm_threshold, z_val_Pbase, z_val_nPthresh, z_val_nPmax, z_val_PmaxDuration, ...
%     w_val_PthreshToPmax, z_val_MicDuration, z_val_vVoid, w_val_vVoid, ...
%     z_val_fillDuration, z_val_thresh_endDuration, z_val_compl, z_val_ncontrEnd, z_val_nPmin_postMax, ...
%     z_val_numberNVC_15aboveThresh, z_val_numberNVC, ...
%     e_val_RecordingTime, a_val_Pbase, a_val_nPmax, ...
%     ...
%     voiding_pre_peak, z_whenvoidhappens_perc, z_val_nPvoid, ...
%     ...
%     w_val_EMGcutoff25_thresh_max, w_val_EMGcutoff75_thresh_max, ...
%     ...
%     description1, w_duration_1_5, ...
%     z_val_tot_eng_1_5, z_val_tot_eng_2_5, z_val_tot_eng_3_5, z_val_tot_eng_4_5, z_val_tot_eng_5_5, ...
%     z_val_low_eng_1_5, z_val_low_eng_2_5, z_val_low_eng_3_5, z_val_low_eng_4_5, z_val_low_eng_5_5, ...
%     ...
%     z_val_ICImean, z_val_peakPromMean, z_val_ICINo, z_val_ICIpeakAmpl, ...
%     z_val_ICIpeakMeanAmpl, z_val_ICIpeakSDAmpl, z_val_ICIcontractionDuration, ...
%     ...
%     ICIs_val_emg_all_1_5, ICIs_val_emg_all_2_5, ICIs_val_emg_all_3_5, ICIs_val_emg_all_4_5, ICIs_val_emg_all_5_5,...
%     ICIs_val_emg_all5_code, ...
%     ICI_emg_all5_Code1, ICI_emg_all5_Code2, ICI_emg_all5_Code3, ICI_emg_all5_Code4, ICI_emg_all5_Code5, ICI_emg_all5_Code6,...
%     ICI_emg_all5_No, ICI_emg_all5_Void, ICI_emg_all5_nonVoid, ...
%     ...
%     ICIs_val_emg_low_1_5, ICIs_val_emg_low_2_5, ICIs_val_emg_low_3_5, ICIs_val_emg_low_4_5, ICIs_val_emg_low_5_5,...
%     ICIs_val_emg_low5_code, ...
%     ICI_emg_low5_Code1, ICI_emg_low5_Code2, ICI_emg_low5_Code3, ICI_emg_low5_Code4, ICI_emg_low5_Code5, ICI_emg_low5_Code6,...
%     ICI_emg_low5_No, ICI_emg_low5_Void, ICI_emg_low5_nonVoid, ...
%     ...
%     ICIs_val_emg_all_1_3, ICIs_val_emg_all_2_3, ICIs_val_emg_all_3_3,...
%     ICIs_val_emg_all3_code, ...
%     ICI_emg_all3_Code1, ICI_emg_all3_Code2, ICI_emg_all3_Code3, ICI_emg_all3_Code4, ICI_emg_all3_Code5, ICI_emg_all3_Code6,...
%     ICI_emg_all3_No, ICI_emg_all3_Void, ICI_emg_all3_nonVoid, ...
%     ...  
%     ICIs_val_emg_low_1_3, ICIs_val_emg_low_2_3, ICIs_val_emg_low_3_3,...
%     ICIs_val_emg_low3_code, ...
%     ICI_emg_low3_Code1, ICI_emg_low3_Code2, ICI_emg_low3_Code3, ICI_emg_low3_Code4, ICI_emg_low3_Code5, ICI_emg_low3_Code6,...
%     ICI_emg_low3_No, ICI_emg_low3_Void, ICI_emg_low3_nonVoid,...
%     ...
%     ICIs_val_EMGcutoff25, ICIs_val_EMGcutoff75);
% 
% 
% T(1,:);
% Result_Table = fullfile([destinationfolder, '/', xy, '.csv']);
% writetable(T,Result_Table)

%% other analysis strategies (not used)
%% cross-correlation coefficient
% [c,lags] = xcorr(z_val_Pfilt,z_val_EMGfilt); %filtered
% %[c,lags] = xcorr(z_val_p,z_val_emg); %unfiltered
% 
% xcorr(z_val_Pfilt,z_val_EMGfilt, 0, 'coeff'); %filtered
% %xcorr(z_val_p,z_val_emg, 0, 'coeff'); %unfiltered
% 
% % find peak in xcorr
% [z_idx_xcorr, z_val_xcorr] = findpeak(c);
% z_tsp_xcorrmax = lags(z_idx_xcorr);
% 
% %plot xcorr
% h (5) = figure;
% plot(lags,c)
% xline(0)
% xline(z_tsp_xcorrmax)
% text([z_tsp_xcorrmax], 0.7*[1], {z_tsp_xcorrmax})
% 
%% fourier transform
% %xxx = fft(z_val_EMGfilt);
% %xxx = fft(z_val_emg);
% 
% %xxx = fft(z_val_Pfilt);
% xxx = fft(z_val_p);
% 
% T=1/fs;
% L = 1500;
% t = (0:L-1)*T;
% 
% P2 = abs(xxx/L);
% P1 = P2(1:L/2+1);
% P1(2:end-1) = 2*P1(2:end-1);
% 
% f = fs*(0:(L/2))/L;
% 
% h (5) = figure;
% plot(f,P1) 
% title('Single-Sided Amplitude Spectrum of X(t)')
% xlabel('f (Hz)')
% ylabel('|P1(f)|')
% xlim ([0 500])
% 
% % h (5) = figure;
% % plot(z_tsp_n, xxx)

%% unused plots
%% plot the local peaks and minima with overlayed energy contents color coded
% h (5) = figure;
% area(z_tsp_n,z_val_EMGfig25, z_val_Pbase, 'FaceColor', 	'#EDB120', 'FaceAlpha', [0.8]) % lower than 25th percentile
% hold on
% area(z_tsp_n,z_val_EMGfigMid, z_val_Pbase, 'FaceColor', '#D95319', 'FaceAlpha', [0.8]) % between 25th and 75th percentile
% hold on
% area(z_tsp_n,z_val_EMGfig75, z_val_Pbase, 'FaceColor', 	'#A2142F', 'FaceAlpha', [0.8]) % higher than 75th percentile
% hold on
% plot(z_tsp_n, z_val_Pfilt, 'color', 'k', 'Linewidth', 3) % filtered pressure signal
% hold on
% plot(z_tsp_ICIpeaks, z_val_ICIpeaks, 'v', 'color', 'b', 'Linewidth', 2) % indicates local peaks
% hold on
% plot(z_tsp_ICImin, z_val_ICImin, '^', 'color', 'b', 'Linewidth', 2) % indicates local minima
% text(z_tsp_ICImin+1.5,z_val_ICImin,num2str((1:numel(z_val_ICImin))'), 'fontweight', 'bold', 'Color', 'b') % number the peaks
% hold on
% plot([z_idx_thresh2(1)/fs z_idx_thresh2(1)/fs], ylim, 'color', 'm', 'Linewidth', 2); % plot line when threshold is first reached within window
% hold on
% text(z_tsp_ICIpeaks+1.5,z_val_ICIpeaks,num2str((1:numel(z_val_ICIpeaks))'), 'fontweight', 'bold', 'Color', 'b') % number the peaks
% title(replace(xy, '_', '-'))  %title with two lines
% ylabel('Intravesical pressure [cmH_2O]')
% xlabel('Time [s]')
% set(gca,'FontSize',18)
% ylim([(z_val_Pbase-0.5) (z_val_Pmax+0.5)])

%% plot pressure and energy content overlay
% h (6) = figure;
% 
% yyaxis left
% plot(z_tsp_n,z_val_Pfilt);
% yline(w_val_Pthresh, 'm', 'Linewidth', 1); %horizontal line indicating threshold
% plot1.Color(4) = 0.01;
% 
% for ii = 1:length(ICIs_tsp_n)
%     hold on; plot(ICIs_tsp_n{ii}, ICIs_val_Pfilt{ii}, '-', 'color', 'g') % first contraction
% end
% 
% yyaxis right
% semilogy(time, z_val_EMGfilt, 'k')
% %plot(time, z_val_EMGfilt)
% for ii = 1:length(ICIs_tsp_n)
%     hold on; plot(ICIs_tsp_n{ii}, ICIs_val_EMGfilt{ii}, '-', 'color', 'g') % first contraction
% end
% 
% % hold on; % green line when urine falls onto scale
% % for ii = z_idx_scaleDiff_up(1:end)
% %     plot([ii/fs_scale ii/fs_scale], ylim, '-', 'color', 'g', 'Linewidth', 1);
% % end
% hold on; % draw line at peak in pressure
% for ii = z_idx_Pmax(1:end)
%     plot([ii/fs ii/fs], ylim, '-', 'color', 'r','Linewidth', 1);
% end
% hold on; plot([z_idx_thresh2(1)/fs z_idx_thresh2(1)/fs], ylim, '-', 'color', 'm', 'Linewidth', 1); % plot line when threshold is first reached within window
% 
%% plots width and prominence of a peak
% h (5) = figure;
% findpeaks(z_val_Pfilt, z_tsp_n, 'MinPeakDistance', 5, 'MinPeakProminence', 5, 'Annotate', 'extents');
% h (5) = figure;
% findpeaks(-z_val_Pfilt, z_tsp_n, 'MinPeakDistance', 5, 'MinPeakProminence', 5, 'Annotate', 'extents'); %negative

%% figure of zoom window: filtered pressure, derivative of pressure, when thershold is reached
% set(0,'DefaultFigureWindowStyle','docked')
% h(2) = figure;
% subplot 311
% plot_legend = plot(z_tsp,z_val_p,z_tsp,z_val_Pfilt);
% hold on; %red line at Pmax
% for ll = 1:length(z_tsp_Pmax)
%     plot([z_tsp_Pmax(ll) z_tsp_Pmax(ll)], [min(z_val_p), max(z_val_p)], 'r', 'Linewidth', 1);
% end
% hold on; %cyan line when threshold near peak is reached
% for kk = 1:length(w_tsp_thresh)
%     plot([w_tsp_thresh(kk) w_tsp_thresh(kk)], [min(z_val_p), max(z_val_p)], 'c', 'Linewidth', 1);
% end
% hold on;%green lines when urine falls onto scale
% for jj = 1:length(z_tsps_drop)
%     if (z_tsp_Pmax(1)-z_tsps_drop(jj) < pre) && (z_tsp_Pmax(1)-z_tsps_drop(jj) > -post)
%         id_drop2 = find( round(z_tsp, 4) == round(z_tsps_drop(jj), 4));
%         t_drop = z_tsp(id_drop2);
%         hold on; xline(t_drop, 'g', 'Linewidth', 1);
%     else
%     end
% end
% yline(w_val_Pthresh, 'm', 'Linewidth', 1); %horizontal line indicating threshold
% yline(cutoff_nonvoid_contr, 'm', 1);
% xline(w_tsp_thresh(1), 'm', 'Linewidth', 1); %vertical line when threshold is reached for the first time near the peak 
% xline(z_tsp_contrEnd, 'm', 'Linewidth', 1); %vertical line when contraction ends
% legend((plot_legend),{'original', 'median filtered'}, 'Location', 'southwest');
% 
% subplot 312
% plot_legend = plot(z_tsp,z_val_p,z_tsp,z_val_Pfilt);
% hold on; %red line at Pmax
% for ll = 1:length(z_tsp_Pmax)
%     plot([z_tsp_Pmax(ll) z_tsp_Pmax(ll)], [min(z_val_p), max(z_val_p)], 'r', 'Linewidth', 1);
% end
% hold on; %black line when threshold is reached away from the peak
% for kk = 1:length(z_tsp_thresh)
%     plot([z_tsp_thresh(kk) z_tsp_thresh(kk)], [min(z_val_p), max(z_val_p)], 'k', 'Linewidth', 1);
% end
% hold on; %cyan line when threshold near peak is reached
% for kk = 1:length(w_tsp_thresh)
%     plot([w_tsp_thresh(kk) w_tsp_thresh(kk)], [min(z_val_p), max(z_val_p)], 'c', 'Linewidth', 1);
% end
% hold on; %green lines when urine falls onto scale
% for jj = 1:length(z_tsps_drop)
%     id_drop2 = find( round(z_tsp, 4) == round(z_tsps_drop(jj), 4)); % data format issue, has to be rounded
%     t_drop = z_tsp(id_drop2);
%     hold on; xline(t_drop, 'g', 'Linewidth', 1);
% end
% hold on;
% yline(w_val_Pthresh, 'm', 'Linewidth', 1); %horizontal line indicating threshold
% xline(w_tsp_thresh(1), 'm', 'Linewidth', 1); %vertical line when threshold is reached for the first time near the peak 
% xline(z_tsp_contrEnd, 'm', 'Linewidth', 1); %vertical line when contraction ends
% legend((plot_legend),{'original', 'median filtered'}, 'Location', 'southwest');
% 
% subplot 313
% plot_legend = plot(z_tsp,z_val_dP);
% yline(norm_threshold, 'm', 'Linewidth', 1);
% hold on;
% for ll = 1:length(z_tsp_Pmax)
%     plot([z_tsp_Pmax(ll) z_tsp_Pmax(ll)], [min(z_val_dP), max(z_val_dP)], 'r', 'Linewidth', 1);
% end
% legend((plot_legend),{'derivative of pressure'}, 'Location', 'southwest');
%% figure of window around the peak: filtered pressure, derivative of pressure, threshold
% h(3) = figure;
% subplot 211
% plot_legend = plot(w_tsp,w_val_p,w_tsp,w_val_Pfilt);
% hold on;
% for ll = 1:length(z_tsp_Pmax)
%     plot([z_tsp_Pmax(ll) z_tsp_Pmax(ll)], [min(w_val_p), max(w_val_p)], 'r', 'Linewidth', 1);
% end
% hold on;
% for kk = 1:length(w_tsp_thresh)
%     plot([w_tsp_thresh(kk) w_tsp_thresh(kk)], [min(w_val_p), max(w_val_p)], 'c', 'Linewidth', 1);
% end
% hold on;%green lines when urine falls onto scale
% for jj = 1:length(z_tsps_drop)
%     if (z_tsp_Pmax(1)-z_tsps_drop(jj) < pre) && (z_tsp_Pmax(1)-z_tsps_drop(jj) > -post)
%         id_drop2 = find( round(z_tsp, 4) == round(z_tsps_drop(jj), 4));
%         t_drop = z_tsp(id_drop2);
%         hold on; xline(t_drop, 'g', 'Linewidth', 1);
%     else
%     end
% end
% yline(w_val_Pthresh, 'm', 'Linewidth', 1); %horizontal line indicating threshold
% xline(w_tsp_thresh(1), 'm', 'Linewidth', 1); %vertical line when threshold is reached for the first time near the peak 
% legend((plot_legend),{'original', 'median filtered'});
% 
% subplot 212
% plot_legend = plot(w_tsp,w_val_dP);
% hold on;
% for ll = 1:length(z_tsp_Pmax)
%     plot([z_tsp_Pmax(ll) z_tsp_Pmax(ll)], [min(z_val_dP), max(z_val_dP)], 'r', 'Linewidth', 1);
% end
% yline(norm_threshold, 'm', 'Linewidth', 1);
% legend((plot_legend),{'derivative of pressure'});


%% plot energy content
% h(4) = figure;
% semilogy(time, eng_all, 'k')
% hold on; 
% semilogy(time, eng, 'b')
% hold on; % green line when urine falls onto scale
% for ii = 1:length(z_idx_scaleDiff_up)
%     if (z_idx_Pmax(1)/fs)-(z_idx_scaleDiff_up(ii)/fs_scale) < pre && ((z_idx_Pmax(1)/fs)-(z_idx_scaleDiff_up(ii)/fs_scale)) > -post
%         plot([z_idx_scaleDiff_up(ii)/fs_scale z_idx_scaleDiff_up(ii)/fs_scale], ylim, 'color', 'g', 'Linewidth', 1);
%     else
%     end
% end
% 
% hold on; % plot line when threshold is reached the first time within window
% plot([z_idx_thresh2(1)/fs z_idx_thresh2(1)/fs], ylim, 'color', 'm', 'Linewidth', 1);
% plot([z_tsp_contrEnd-z_tsp(1) z_tsp_contrEnd-z_tsp(1)], ylim, 'color', 'm', 'Linewidth', 1)
% 
% hold on; % draw line at peak in pressure
% for ii = z_idx_Pmax(1:end)
%     plot([ii/fs ii/fs], ylim, 'color', 'r','Linewidth', 1);
% end
% 
% 
% legend ('0-500Hz energy', '0-20Hz energy')
