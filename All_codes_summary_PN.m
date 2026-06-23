%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compilation of UDI analysis codes
% Pragya Nagar , updated:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%% PART-1: File name: SCI_24.08.2024/Sham_24.08.2024
% 
% SCI/Sham - Difference in selection in pressure graph
% Urine drop detection and incorporation commented out due to unreliability
% No EMG Data - Analysis commented out
%
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
%%
% %% Make selection in the pressure graph for BL and Sham
% % Click at the beginning and end of micturition
% [x, y] = ginput(2);
% 
% % Set values to NaN that are not used in BL and Sham
% a_val_Pbase = NaN; % baseline pressure of whole measurement
% a_val_nPmax = NaN; % normalized maximal pressure of whole measurement

%% find Pmax & Pbase --> for SCI
[x1, y1] = ginput(2);
[a_idxs] = findselection(e_tsps, x1);  % timespan between click 1 & 2
a_tsps = e_tsps(a_idxs);  % variable containing time (of scale) within the selection
a_idx_t = e_tsp>min(a_tsps) & e_tsp<max(a_tsps); % variable containing time of pressure and EMG
a_val_p = e_var_pressure(a_idx_t);  % variable containing pressure within the selection

a_val_Pbase = min(a_val_p); % baseline Pressure
a_val_Pmax = max(a_val_p); % maximal Pressure
a_val_nPmax = a_val_Pmax - a_val_Pbase; % normalized maximal pressure
%% make selection in the pressure graph --> for SCI
% click once, then it automatically finds the coordinates 10 min later
[x, y] = ginput(1);
x(2) = x(1)+analysisTime;

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

% %% normalize time of zoom to start at 0
% z_tsp_n = z_tsp - z_tsp(1);
% w_tsp_thresh_n = w_tsp_thresh(1) - z_tsp(1); %normalize threshold
% 
% %% find EMG signal between Pthresh and Pmax --> divide into active or silent --> used to analyse BL and Sham
% [w_idx_Pthresh_Pmax] = findsection(z_tsp,z_idx_Pmax, z_idx_thresh2); % find the time slot between thresh to max --> is identical to the variable w_idx_tot_5
% w_tsp_Pthresh_Pmax = z_tsp_n(w_idx_Pthresh_Pmax);  %variable containing timestamps from thresh to max
% w_val_Pfilt_thresh_max = z_val_Pfilt(w_idx_Pthresh_Pmax); % variable containing filtered pressure from thresh to max
% %w_val_emg_thresh_max = z_val_emg(w_idx_Pthresh_Pmax); % variable containing emg from thresh to max
% 
% % find prolonged timeslot, 1s before Pthresh to 1s after Pmax --> take the
% % emg signal within this section --> find variables for hht --> apply a
% % median filter to the EMG power --> delete the prolonged ends, so that
% % only the section from Pthresh to Pmax stays
% [w_idx_Pthresh_Pmax_prolonged] = findprolongedsection(z_tsp,z_idx_Pmax, z_idx_thresh2); % find the time slot between thresh to max and adds 1s (=5000 data points) to each end
% w_val_emg_thresh_max_prolonged = z_val_emg(w_idx_Pthresh_Pmax_prolonged); % variable containing emg from 1s before thresh to 1s after max
% 
% %definition of variables for hht plot
% imf_thresh_max_prolonged = emd(w_val_emg_thresh_max_prolonged, 'MaxNumIMF', 20,'Display',0);
% [hs_thresh_max_prolonged,f_thresh_max_prolonged,time_thresh_max_prolonged,~,~] = hht(imf_thresh_max_prolonged,fs,'FrequencyLimits',[0 500]);
% 
% parfor ii = 1:length(hs_thresh_max_prolonged)
%     eng_all_thresh_max_prolonged(ii) = sum( trapz(f_thresh_max_prolonged, hs_thresh_max_prolonged(:, ii)) ); % calculation of total energy
%     eng_thresh_max_prolonged(ii) = sum( trapz( f_thresh_max_prolonged(1:5), hs_thresh_max_prolonged(1:5, ii) ) ); % calculation of 0-20 Hz energy content
% end
% 
% % EMG power median filtered
% w_val_EMGfilt_thresh_max_prolonged = smooth(eng_all_thresh_max_prolonged, 5000);
% w_val_EMGfilt_thresh_max_prolonged = transpose(w_val_EMGfilt_thresh_max_prolonged);
% w_val_EMGfilt_thresh_max = w_val_EMGfilt_thresh_max_prolonged(5000:(end-5001)); %remove the prolonged ends
% 
% % use filtered EMG signal, take median value
% % as cutoff for silent or active
% w_val_EMGcutoff25_thresh_max = prctile(w_val_EMGfilt_thresh_max,25);
% w_val_EMGcutoff75_thresh_max = prctile(w_val_EMGfilt_thresh_max,75);
% 
% % make all values lower than cutoff25 equal to Pmax and all higher ones
% % equal to Pbase
% w_val_EMGfig25_thresh_max = w_val_EMGfilt_thresh_max;
% w_val_EMGfig25_thresh_max(w_val_EMGfig25_thresh_max < w_val_EMGcutoff25_thresh_max) = -100;
% w_val_EMGfig25_thresh_max(w_val_EMGfig25_thresh_max >= w_val_EMGcutoff25_thresh_max) = 100;
% w_val_EMGfig25_thresh_max(w_val_EMGfig25_thresh_max == -100) = z_val_Pmax;
% w_val_EMGfig25_thresh_max(w_val_EMGfig25_thresh_max == 100) = z_val_Pbase;
% 
% % make all values higher than cutoff75 equal to Pmax and all smaller ones
% % equal to Pbase
% w_val_EMGfig75_thresh_max = w_val_EMGfilt_thresh_max;
% w_val_EMGfig75_thresh_max(w_val_EMGfig75_thresh_max >= w_val_EMGcutoff75_thresh_max) = z_val_Pmax;
% w_val_EMGfig75_thresh_max(w_val_EMGfig75_thresh_max < w_val_EMGcutoff75_thresh_max) = z_val_Pbase;
% 
% % make all values between cutoff25 and cutoff75 equal to Pmax and rest
% % equal to Pbase
% w_val_EMGfigMid_thresh_max = w_val_EMGfilt_thresh_max;
% w_val_EMGfigMid_thresh_max((w_val_EMGfigMid_thresh_max < w_val_EMGcutoff25_thresh_max) | (w_val_EMGfigMid_thresh_max > w_val_EMGcutoff75_thresh_max)) = 100;
% w_val_EMGfigMid_thresh_max((w_val_EMGcutoff25_thresh_max < w_val_EMGfigMid_thresh_max) & (w_val_EMGfigMid_thresh_max < w_val_EMGcutoff75_thresh_max)) = -100;
% w_val_EMGfigMid_thresh_max(w_val_EMGfigMid_thresh_max == 100) = z_val_Pbase;
% w_val_EMGfigMid_thresh_max(w_val_EMGfigMid_thresh_max == -100) = z_val_Pmax;
% 
% % plot pressure with overlayed energy contents color coded from Pthresh 
% % to Pmax
% h (5) = figure;
% area(w_tsp_Pthresh_Pmax,w_val_EMGfig25_thresh_max, z_val_Pbase, 'FaceColor', 	'#EDB120', 'FaceAlpha', [0.8]) % lower than 25th percentile
% hold on
% area(w_tsp_Pthresh_Pmax,w_val_EMGfigMid_thresh_max, z_val_Pbase, 'FaceColor', '#D95319', 'FaceAlpha', [0.8]) % between 25th and 75th percentile
% hold on
% area(w_tsp_Pthresh_Pmax,w_val_EMGfig75_thresh_max, z_val_Pbase, 'FaceColor', 	'#A2142F', 'FaceAlpha', [0.8]) % higher than 75th percentile
% hold on
% plot(z_tsp_n, z_val_Pfilt, 'color', 'k', 'Linewidth', 3) % filtered pressure signal
% hold on
% plot([z_idx_thresh2(1)/fs z_idx_thresh2(1)/fs], ylim, 'color', 'm', 'Linewidth', 2); % plot line when threshold is first reached within window
% title(replace(xy, '_', '-'))
% ylabel('Intravesical pressure [cmH_2O]')
% xlabel('Time [s]')
% set(gca,'FontSize',18)
% ylim([(z_val_Pbase-0.5) (z_val_Pmax+0.5)])
% 
% %% define folder where to save results 
% 
% destinationfolder = './Results/Pthresh-Pmax';
% saveas(gcf, fullfile(destinationfolder, xy), 'png'); %gcf returns the current figure handle 
% 
% 
% %% find time windows in which energy content will be calculated (EMG signal)
% % divide thresh-to-max in 5 equal length sections --> dividing by 5
% % resulting in .0 -> no missing value; .2 -> 1 missing value; .4 -> 2
% % missing values; .6 -> 3 missing values; .8 -> missing values just before
% % Pmax
% description1 = "1: PthreshToPmax 5 equal sections";
% [w_idx_tot_5] = findsection(z_tsp,z_idx_Pmax, z_idx_thresh2); % find the time slot between thresh and Pmax (equal to w_idx_Pthresh_Pmax)
% 
% % duration (s) of one fifth from thresh to peak
% w_duration_1_5 = length(w_idx_tot_5)/5/fs; 
% 
% % remove prolonged ends of energy content
% eng_all_thresh_max = eng_all_thresh_max_prolonged(5000:(end-5001));
% eng_thresh_max = eng_thresh_max_prolonged(5000:(end-5001));
% 
% % divide index from thresh to max into 5 equal sections
% w_idx_1_5 = (1:floor(length(eng_thresh_max)/5));
% w_idx_2_5 = (floor(length(eng_thresh_max)/5)+1:floor(length(eng_thresh_max)/5)*2);
% w_idx_3_5 = ((floor(length(eng_thresh_max)/5)*2)+1:((floor(length(eng_thresh_max)/5))*3));
% w_idx_4_5 = ((floor(length(eng_thresh_max)/5)*3)+1:((floor(length(eng_thresh_max)/5))*4));
% w_idx_5_5 = ((floor(length(eng_thresh_max)/5)*4)+1:((floor(length(eng_thresh_max)/5))*5));
% 
% % divide total energy (0-500Hz) from thresh to max into 5 equal sections 
% % and calculate sum
% z_val_tot_eng_1_5 = sum(eng_all_thresh_max(w_idx_1_5));
% z_val_tot_eng_2_5 = sum(eng_all_thresh_max(w_idx_2_5));
% z_val_tot_eng_3_5 = sum(eng_all_thresh_max(w_idx_3_5));
% z_val_tot_eng_4_5 = sum(eng_all_thresh_max(w_idx_4_5));
% z_val_tot_eng_5_5 = sum(eng_all_thresh_max(w_idx_5_5));
% 
% % divide low energy (0-20Hz) from thresh to max into 5 equal sections 
% % and calculate sum
% z_val_low_eng_1_5 = sum(eng_thresh_max(w_idx_1_5));
% z_val_low_eng_2_5 = sum(eng_thresh_max(w_idx_2_5));
% z_val_low_eng_3_5 = sum(eng_thresh_max(w_idx_3_5));
% z_val_low_eng_4_5 = sum(eng_thresh_max(w_idx_4_5));
% z_val_low_eng_5_5 = sum(eng_thresh_max(w_idx_5_5));
% fprintf('\n total energy 1_5 = %.2f, 2_5 = %.2f, 3_5 = %.2f, 4_5 = %.2f, 5_5 = %.2f \n 0-20Hz energy 1_5 = %.2f, 2_5 = %.2f, 3_5 = %.2f, 4_5 = %.2f, 5_5 = %.2f \n', z_val_tot_eng_1_5, z_val_tot_eng_2_5, z_val_tot_eng_3_5, z_val_tot_eng_4_5, z_val_tot_eng_5_5, z_val_low_eng_1_5, z_val_low_eng_2_5, z_val_low_eng_3_5, z_val_low_eng_4_5, z_val_low_eng_5_5);
% 
% %as percentages
% total_tot_5 = z_val_tot_eng_1_5+z_val_tot_eng_2_5+z_val_tot_eng_3_5+z_val_tot_eng_4_5+z_val_tot_eng_5_5;
% s1_5_tot_perc = z_val_tot_eng_1_5/total_tot_5*100; %in percent
% s2_5_tot_perc = z_val_tot_eng_2_5/total_tot_5*100; %in percent
% s3_5_tot_perc = z_val_tot_eng_3_5/total_tot_5*100; %in percent
% s4_5_tot_perc = z_val_tot_eng_4_5/total_tot_5*100; %in percent
% s5_5_tot_perc = z_val_tot_eng_5_5/total_tot_5*100; %in percent
% total_low_5 = z_val_low_eng_1_5+z_val_low_eng_2_5+z_val_low_eng_3_5+z_val_low_eng_4_5+z_val_low_eng_5_5;
% s1_5_low_perc = z_val_low_eng_1_5/total_low_5*100; %in percent
% s2_5_low_perc = z_val_low_eng_2_5/total_low_5*100; %in percent
% s3_5_low_perc = z_val_low_eng_3_5/total_low_5*100; %in percent
% s4_5_low_perc = z_val_low_eng_4_5/total_low_5*100; %in percent
% s5_5_low_perc = z_val_low_eng_5_5/total_low_5*100; %in percent
% fprintf('\n percentage of total energy per fifth from Pthresh-to-Pmax: \n 1_5 = %.2f%%, 2_5 = %.2f%%, 3_5 = %.2f%%, 4_5 = %.2f%%, 5_5 = %.2f%% \n percentage of 0-20Hz energy per fifth from Pthresh-to-Pmax: \n 1_5 = %.2f%%, 2_5 = %.2f%%, 3_5 = %.2f%%, 4_5 = %.2f%%, 5_5 = %.2f%% \n', s1_5_tot_perc, s2_5_tot_perc, s3_5_tot_perc, s4_5_tot_perc, s5_5_tot_perc, s1_5_low_perc, s2_5_low_perc, s3_5_low_perc, s4_5_low_perc, s5_5_low_perc);

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
% %% convert the character vector xy to a string
% Measurement_Name = convertCharsToStrings(xy);
% 
% %% Save the result table as csv file --> BL/sham
% T = table(Measurement_Name, deriv_threshold, norm_threshold, z_val_Pbase, z_val_nPthresh, z_val_nPmax, z_val_PmaxDuration, ...
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
%     z_val_low_eng_1_5, z_val_low_eng_2_5, z_val_low_eng_3_5, z_val_low_eng_4_5, z_val_low_eng_5_5);
% 
% 
% T(1,:);
% Result_Table = fullfile([destinationfolder, '/', xy, '.csv']);
% writetable(T,Result_Table)

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
%
%% 2: File name: Sham_compliance_23.07.2025
% Additional method to calculate compliance (ΔV/ΔP) and volume filled by manual window selection
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pragya Nagar updated:15.05.2025
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

subplot 212
plot(e_tsps(time_limit_idx_scale), e_var_scale(time_limit_idx_scale))   %original data, 5Hz
xlim([0 3000])
set(gca,'FontSize',18)
xlabel('Time [s]')
ylabel('V_v_o_i_d [mL]')

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
ylim([0 40])  % Set the y-axis range from 0 to 40
yticks(0:10:40)  % Set y-axis ticks with intervals of 10
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

%% test

% Your existing normalized data & limited time indices:
% e_var_pressure_norm, e_tsp(time_limit_idx)
% e_var_scale_norm, e_tsps(time_limit_idx_scale)

% Plot your existing figure again if needed
figure(summaryGraph); % make sure the figure exists or create a new one

subplot(211)
plot(e_tsp(time_limit_idx), e_var_pressure_norm, 'k');
xlim([0 3000]);
ylim([0 40]);
yticks(0:10:40);
title('Pressure (normalized)');
set(gca,'XTickLabel',[]);
set(gca,'FontSize',18);
ylabel('P_v_e_s_i_c_a_l [cmH_2O]');
hold on;

subplot(212)
plot(e_tsps(time_limit_idx_scale), e_var_scale_norm, 'b');
xlim([0 3000]);
set(gca,'FontSize',18);
xlabel('Time [s]');
ylabel('V_v_o_i_d [mL]');
hold on;

% === Manual selection on pressure plot ===
subplot(211);
fprintf('Click start and end of micturition on the pressure plot.\n');
[x_sel, ~] = ginput(2);
t_start = min(x_sel);
t_end = max(x_sel);

% === Extract indices in the selected window ===
idx_pressure_window = find(e_tsp(time_limit_idx) >= t_start & e_tsp(time_limit_idx) <= t_end);
idx_scale_window = find(e_tsps(time_limit_idx_scale) >= t_start & e_tsps(time_limit_idx_scale) <= t_end);

% Check if indices are empty (common mistake)
if isempty(idx_pressure_window) || isempty(idx_scale_window)
    error('No data points found in selected window. Please select within data range.');
end

%%
% === Extract data slices ===
pressure_window = e_var_pressure_norm(idx_pressure_window);
time_pressure_window = e_tsp(time_limit_idx);
time_pressure_window = time_pressure_window(idx_pressure_window);

scale_window = e_var_scale_norm(idx_scale_window);
time_scale_window = e_tsps(time_limit_idx_scale);
time_scale_window = time_scale_window(idx_scale_window);

% === Restrict time vectors to their overlapping range to avoid NaNs in interpolation ===
t_min = max(min(time_pressure_window), min(time_scale_window));
t_max = min(max(time_pressure_window), max(time_scale_window));

valid_idx = time_pressure_window >= t_min & time_pressure_window <= t_max;

pressure_window = pressure_window(valid_idx);
time_pressure_window = time_pressure_window(valid_idx);

% Interpolate volume data onto pressure time vector within overlapping window
scale_window_interp = interp1(time_scale_window, scale_window, time_pressure_window, 'linear');

% Check for NaNs after interpolation
if any(isnan(scale_window_interp))
    error('NaNs found in interpolated volume data after restricting time window. Check time vectors.');
end

% === Calculate compliance and volume filled ===
fill_duration_sec = t_end - t_start; % duration in seconds
volume_filled = (20 / 60) * fill_duration_sec;
delta_pressure = max(pressure_window) - min(pressure_window);
compliance = volume_filled / delta_pressure;
fprintf('Compliance (Vfilling / ΔP) = %.4f µl/cmH2O\n', compliance);


% === Plot highlighted window ===
subplot(211);
plot(time_pressure_window, pressure_window, 'r', 'LineWidth', 2);

subplot(212);
plot(time_pressure_window, scale_window_interp, 'm', 'LineWidth', 2);

%% compliance
z_val_compl = z_val_fillDuration*20/z_val_nPthresh; % ul/cmH2O

%% Vfilling
% volume reflects how much fluid was instilled into the bladder during the filling phase — before the bladder initiated contraction — and it represents the functional bladder capacity for that cycle.
%z_val_fillVolume = 20 * z_val_fillDuration; % µL

%%
% Replace '_555' in filename and save as PNG
new_filename = strrep(xy, '_555', '_fig2');
saveas(gcf, fullfile(destinationfolder_up, new_filename), 'png'); 

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

%% Define and Create Folder to Save Figure
destinationfolder_up = fullfile('..', 'figures', 'micturationcycle figure');
if ~exist(destinationfolder_up, 'dir')
    mkdir(destinationfolder_up);
end

% Replace '_555' in filename and save as PNG
new_filename = strrep(xy, '_555', '_fig3');
saveas(gcf, fullfile(destinationfolder_up, new_filename), 'png'); 

%% Convert the character vector xy to string
Measurement_Name = convertCharsToStrings(xy);

%% Save the Result Table as CSV
% Navigate one folder up from the current directory
parentDir = fileparts(pwd);

% Define output directory path
outputDir = fullfile(parentDir, 'output results');
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% Define output CSV file name and path
outputFileName = strrep(Measurement_Name, '_555', '_results.csv');
outputFilePath = fullfile(outputDir, outputFileName);

% Open the file and write headers
fileID = fopen(outputFilePath, 'w');
fprintf(fileID, ['Measurement Name,Number of Peaks,Value of Peak (cmH2O),Normalized Max Detrusor Pressure (cmH2O),',...
    'Micturition Cycle Duration (min),Normalized Threshold Detrusor Pressure (cmH2O),',...
    'Detrusor Pressure Amplitude from Threshold to Maximum (cmH2O),Voided Volume in Whole Micturition Cycle (µl),',...
    'Voided Volume in Window around Peak (µl),Number of NVCs during Filling 15%% above Threshold,',...
    'Number of NVCs during Filling at Threshold, Bladder Compliance (µl/cmH2O), Volume filled (µl), Compliance (ΔV/ΔP)(µl/cmH2O)\n']);

% Write the data row
fprintf(fileID, '%s,%01d,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%d,%d,%.2f,%.2f,%.2f\n', ...
    Measurement_Name, length(z_idx_Pmax), z_val_Pmax, z_val_nPmax, ...
    z_val_MicDuration, z_val_nPthresh, w_val_PthreshToPmax, ...
    z_val_vVoid, w_val_vVoid, length(z_no_NVC_15aboveThresh), ...
    length(z_no_NVC), z_val_compl,volume_filled,compliance);

% Close file
fclose(fileID);

%% Display Output Summary
disp(['Output saved to ' outputFilePath]);

%%
fprintf('\n--- Summary ---\n');
fprintf('Number of peaks = %d, Value of peak = %.2f cmH2O\n', length(z_idx_Pmax), z_val_Pmax);
fprintf('Normalized max detrusor pressure = %.2f cmH2O\n', z_val_nPmax);
fprintf('Micturition cycle duration = %.2f min\n', z_val_MicDuration);
fprintf('Normalized threshold detrusor pressure = %.2f cmH2O\n', z_val_nPthresh);
fprintf('Pressure amplitude (threshold to max) = %.2f cmH2O\n', w_val_PthreshToPmax);
fprintf('Voided volume (whole cycle) = %.2f µl\n', z_val_vVoid);
fprintf('Voided volume (around peak) = %.2f µl\n', w_val_vVoid);
fprintf('NVCs (15%% above threshold) = %d\n', length(z_no_NVC_15aboveThresh));
fprintf('NVCs (at threshold) = %d\n', length(z_no_NVC));
fprintf('Bladder compliance = %.2f µl/cmH2O\n', z_val_compl);
fprintf('Volume filled = %.4f µl\n', volume_filled);
fprintf('Estimated compliance (Vfilling / ΔP) = %.4f µl/cmH2O\n', compliance);

%% 3: File name: Timeseriesfiles_24042025
% To extract data in csv file (big files)
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pragya Nagar, Updated: 23.04.2025
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Variable Naming Conventions:
% e: entire measurement
% a: all measurements -> for Pbase & Pmax in SCI measurements
% z: zoom to one micturition cycle
% w: values within window (around the peak in pressure)
% tsp: timestamp e.g., 47.042, 88.020 
% idx: index --> position in array, e.g., 4390, 5391, 6392
% val: value of the parameter
% logi: logical variable (1 if condition applies, 0 if not)
%%% Structure: 
% 1.) e, z, or w
% 2.) tsp, idx, val, or logi
% 3.) variable (parameter)
clc; clear; close all;

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

%% Set time window of export
% Limit the data to the first 3000 seconds
max_time = 3000;
time_limit_idx = e_tsp <= max_time;
time_limit_idx_scale = e_tsps <= max_time;

%%
% Define the current directory for saving output CSV file
outputDir = pwd;  % Set the output directory to the current folder

% Define the data for pressure and time (pressure)
pressure_data = [e_tsp(time_limit_idx)', e_var_pressure(time_limit_idx)'];

% Define the data for scale and time (scale)
scale_data = [e_tsps(time_limit_idx_scale)', e_var_scale(time_limit_idx_scale)'];

% Define the header with column names and units
pressure_header = {'Time (Pressure) [s]', 'Pressure [mmH2O]'};
scale_header = {'Time (Scale) [s]', 'Voided Volume [mL]'};

% Define the filename and path for pressure data
output_csv_filename_pressure = fullfile(outputDir, [xy '_pressure_timeseries.csv']);

% Open the file for writing pressure data
fileID_pressure = fopen(output_csv_filename_pressure, 'w');

% Write the header for pressure data
fprintf(fileID_pressure, '%s,%s\n', pressure_header{:});

% Close the file and write pressure data with dlmwrite
fclose(fileID_pressure);
dlmwrite(output_csv_filename_pressure, pressure_data, '-append');

% Define the filename and path for scale data
output_csv_filename_scale = fullfile(outputDir, [xy '_scale_timeseries.csv']);

% Open the file for writing scale data
fileID_scale = fopen(output_csv_filename_scale, 'w');

% Write the header for scale data
fprintf(fileID_scale, '%s,%s\n', scale_header{:});

% Close the file and write scale data with dlmwrite
fclose(fileID_scale);
dlmwrite(output_csv_filename_scale, scale_data, '-append');

% Display confirmation
disp(['Pressure CSV file has been saved as: ' output_csv_filename_pressure]);
disp(['Scale CSV file has been saved as: ' output_csv_filename_scale]);

%% 
% Save Time Series Data to CSV (in common folder)
% Define the folder paths
parent_folder = fullfile('..', '..'); % Go two levels up
target_folder = fullfile(parent_folder, 'Exported_csv_files'); % Subfolder for exported CSV files

% Ensure the "Exported_csv_files" folder exists, create it if it doesn't
if ~exist(target_folder, 'dir')
    mkdir(target_folder);
    fprintf('The folder "%s" did not exist, so it was created.\n', target_folder);
else
    fprintf('The folder "%s" already exists.\n', target_folder);
end

% Define the filename and path for pressure data
output_csv_filename_pressure = fullfile(target_folder, [xy '_pressure_timeseries.csv']);

% Open the file for writing pressure data
fileID_pressure = fopen(output_csv_filename_pressure, 'w');

% Write the header for pressure data
fprintf(fileID_pressure, '%s,%s\n', pressure_header{:});

% Close the file and write pressure data with dlmwrite
fclose(fileID_pressure);
dlmwrite(output_csv_filename_pressure, pressure_data, '-append');

% Define the filename and path for scale data
output_csv_filename_scale = fullfile(target_folder, [xy '_scale_timeseries.csv']);

% Open the file for writing scale data
fileID_scale = fopen(output_csv_filename_scale, 'w');

% Write the header for scale data
fprintf(fileID_scale, '%s,%s\n', scale_header{:});

% Close the file and write scale data with dlmwrite
fclose(fileID_scale);
dlmwrite(output_csv_filename_scale, scale_data, '-append');

% Display confirmation
disp(['Pressure CSV file has been saved as: ' output_csv_filename_pressure]);
disp(['Scale CSV file has been saved as: ' output_csv_filename_scale]);

%% 4: File name: Sham_for_csv_19032026.m
% Include additional NVC data analysis and read csv format data
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pragya Nagar ,updated:19.03.2026
% Updated code to read pressure and scale files from new program (pedro)
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

%% ===========================
% 1. LOAD DATA (CSV with headers)
% ===========================

% Get folder name as measurement ID
currentFolder = pwd;
[~, xy] = fileparts(currentFolder);

disp(['Loaded folder: ', xy]);

% Read CSV files as tables (IMPORTANT)
df_pressure = readtable('pressure.csv');
df_scale    = readtable('scale.csv');

% Check column names (optional but useful)
disp('Pressure columns:');
disp(df_pressure.Properties.VariableNames);

disp('Scale columns:');
disp(df_scale.Properties.VariableNames);

%% ===========================
% 2. ALIGN TIME USING UNIX (same as Python)
% ===========================

t0 = min([min(df_pressure.t_unix_s), min(df_scale.t_unix_s)]);

df_pressure.t_rel = df_pressure.t_unix_s - t0;
df_scale.t_rel    = df_scale.t_unix_s - t0;

%% ===========================
% 3. EXTRACT VARIABLES (match old pipeline)
% ===========================

e_tsp = df_pressure.t_rel;          % pressure time (seconds)
e_var_pressure = df_pressure.pressure;

e_tsps = df_scale.t_rel;            % scale time (seconds)
e_var_scale = df_scale.scale;

e_idx = 1:length(e_tsp);

%% ===========================
% 4. SAMPLING RATES (auto-computed)
% ===========================

fs = 1 / mean(diff(e_tsp));
fs_scale = 1 / mean(diff(e_tsps));

fprintf('Sampling rate (pressure): %.2f Hz\n', fs);
fprintf('Sampling rate (scale): %.2f Hz\n', fs_scale);

%% ===========================
% 5. QUICK SANITY PLOT
% ===========================

figure;

subplot(2,1,1)
plot(e_tsp, e_var_pressure)
xlabel('Time (s)')
ylabel('Pressure')
title('Pressure vs Time')
grid on

subplot(2,1,2)
plot(e_tsps, e_var_scale)
xlabel('Time (s)')
ylabel('Scale')
title('Scale vs Time')
grid on

%% recording time in minutes
e_val_RecordingTime = max(e_tsp)/60;

%% Figure 1 = raw data
set(0,'DefaultFigureWindowStyle','docked')
summaryGraph = figure;

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

subplot 212
plot(e_tsps(time_limit_idx_scale), e_var_scale(time_limit_idx_scale))   %original data, 5Hz
xlim([0 3000])
set(gca,'FontSize',18)
xlabel('Time [s]')
ylabel('V_v_o_i_d [mL]')

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
%z_val_emg = e_var_EMG(z_idx_t);  % keep the EMG data as is

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

%% =========================
% Define Measurement Name and folders
%=========================
% current_folder = pwd;
% [animal_folder, current_name, ~] = fileparts(current_folder);
% Measurement_Name = current_name;       % Use folder name as measurement
% display_name = strrep(Measurement_Name,'_','-'); % optional display

current_folder = pwd; % e.g., '190R_2026-02-27_16-50-23'
[parent_folder, current_name, ~] = fileparts(current_folder);  % parent_folder = 190R
Measurement_Name = current_name;           % use folder name for filenames
display_name = strrep(current_name,'_','-'); % ID + date for title

% Create figures folder if it doesn't exist
figures_folder = fullfile(parent_folder,'figures');  % <-- parent_folder instead of undefined animal_folder
target_folder_fig = fullfile(figures_folder);
if ~exist(target_folder_fig,'dir')
    mkdir(target_folder_fig);
end


%% =========================
% SAVE FIGURE 1 (Before compliance/manual window selection)
% =========================

fig1_filename = [Measurement_Name '_fig1.png'];
saveas(gcf, fullfile(target_folder_fig, fig1_filename));
fprintf('Figure 1 saved: %s\n', fullfile(target_folder_fig, fig1_filename));

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

%% test

% Your existing normalized data & limited time indices:
% e_var_pressure_norm, e_tsp(time_limit_idx)
% e_var_scale_norm, e_tsps(time_limit_idx_scale)

% Plot your existing figure again if needed
figure(summaryGraph); % make sure the figure exists or create a new one

subplot(211)
plot(e_tsp(time_limit_idx), e_var_pressure_norm, 'k');
xlim([0 3000]);
ylim([0 40]);
yticks(0:10:40);
title('Pressure (normalized)');
set(gca,'XTickLabel',[]);
set(gca,'FontSize',18);
ylabel('P_v_e_s_i_c_a_l [cmH_2O]');
hold on;

subplot(212)
plot(e_tsps(time_limit_idx_scale), e_var_scale_norm, 'b');
xlim([0 3000]);
set(gca,'FontSize',18);
xlabel('Time [s]');
ylabel('V_v_o_i_d [mL]');
hold on;

% === Manual selection on pressure plot ===
subplot(211);
fprintf('Click start and end of micturition on the pressure plot.\n');
[x_sel, ~] = ginput(2);
t_start = min(x_sel);
t_end = max(x_sel);

% === Extract indices in the selected window ===
idx_pressure_window = find(e_tsp(time_limit_idx) >= t_start & e_tsp(time_limit_idx) <= t_end);
idx_scale_window = find(e_tsps(time_limit_idx_scale) >= t_start & e_tsps(time_limit_idx_scale) <= t_end);

% Check if indices are empty (common mistake)
if isempty(idx_pressure_window) || isempty(idx_scale_window)
    error('No data points found in selected window. Please select within data range.');
end

%%
% === Extract data slices ===
pressure_window = e_var_pressure_norm(idx_pressure_window);
time_pressure_window = e_tsp(time_limit_idx);
time_pressure_window = time_pressure_window(idx_pressure_window);

scale_window = e_var_scale_norm(idx_scale_window);
time_scale_window = e_tsps(time_limit_idx_scale);
time_scale_window = time_scale_window(idx_scale_window);

% === Restrict time vectors to their overlapping range to avoid NaNs in interpolation ===
t_min = max(min(time_pressure_window), min(time_scale_window));
t_max = min(max(time_pressure_window), max(time_scale_window));

valid_idx = time_pressure_window >= t_min & time_pressure_window <= t_max;

pressure_window = pressure_window(valid_idx);
time_pressure_window = time_pressure_window(valid_idx);

% Interpolate volume data onto pressure time vector within overlapping window
scale_window_interp = interp1(time_scale_window, scale_window, time_pressure_window, 'linear');

% Check for NaNs after interpolation
if any(isnan(scale_window_interp))
    error('NaNs found in interpolated volume data after restricting time window. Check time vectors.');
end

% === Calculate compliance and volume filled ===
fill_duration_sec = t_end - t_start; % duration in seconds
volume_filled = (20 / 60) * fill_duration_sec;
delta_pressure = max(pressure_window) - min(pressure_window);
compliance = volume_filled / delta_pressure;
fprintf('Compliance (Vfilling / ΔP) = %.4f µl/cmH2O\n', compliance);


% === Plot highlighted window ===
subplot(211);
plot(time_pressure_window, pressure_window, 'r', 'LineWidth', 2);

subplot(212);
plot(time_pressure_window, scale_window_interp, 'm', 'LineWidth', 2);

%% compliance
z_val_compl = z_val_fillDuration*20/z_val_nPthresh; % ul/cmH2O

%% Vfilling
% volume reflects how much fluid was instilled into the bladder during the filling phase — before the bladder initiated contraction — and it represents the functional bladder capacity for that cycle.
%z_val_fillVolume = 20 * z_val_fillDuration; % µL

% %% Find the time-point when urine falls onto the scale %
% % find change in scale in the zoom window and sum up all the positive changes
% 
% %Corrected 
% z_val_diff = diff(z_val_scale); 
% 
% if exist('corr','var') && ~isempty(corr)
%     % Ensure lengths match, truncate or pad if needed
%     min_len = min(length(z_val_diff), length(corr));
%     z_val_scaleDiff = [z_val_diff(1:min_len), corr(1:min_len)];
% else
%     z_val_scaleDiff = z_val_diff;
% end
% 
% z_idx_scaleDiff_up = find(z_val_scaleDiff > 0); 
% z_val_vVoid = sum(z_val_scaleDiff(z_idx_scaleDiff_up)) * 1000;
% fprintf('\n Voided volume in whole micturition cycle = %.2f µl\n', z_val_vVoid);
% 
% % find tsp of voiding in window
% if isempty(z_tsps_drop)
%     w_val_vVoid = 0;
% else
%     w_tsps_drop = zeros(1,length(z_tsps_drop));
%     w_logis_drop = zeros(1,length(z_tsps_drop));
%     for jj = 1:length(z_tsps_drop)
%         if (z_tsp_Pmax(1)-z_tsps_drop(jj) < pre) && (z_tsp_Pmax(1)-z_tsps_drop(jj) > -post)
%             w_tsps_drop (jj) = z_tsps_drop(jj);
%             w_logis_drop(jj)= find(w_tsps_drop(jj)>0);
%         else
%         end
%     end
%     w_idxs_drop=z_idx_scaleDiff_up.*w_logis_drop; %create array with timestamps of positive scale changes
%     w_idxs_drop = nonzeros(w_idxs_drop); % delet all values which are 0
%     w_val_vVoid = sum(z_val_scaleDiff(w_idxs_drop))*1000; % sum of values of positive change in scale in window, in µl
% end
% 
% fprintf('\n Voided volume in window around peak = %.2f µl \n', w_val_vVoid);

%% Find the time-point when urine falls onto the scale
z_val_diff = diff(z_val_scale); 

if exist('corr','var') && ~isempty(corr)
    % Ensure lengths match
    min_len = min(length(z_val_diff), length(corr));
    z_val_scaleDiff = [z_val_diff(1:min_len), corr(1:min_len)];
else
    z_val_scaleDiff = z_val_diff;
end

% Indices of positive changes
z_idx_scaleDiff_up = find(z_val_scaleDiff > 0); 
z_val_vVoid = sum(z_val_scaleDiff(z_idx_scaleDiff_up)) * 1000;
fprintf('\n Voided volume in whole micturition cycle = %.2f µl\n', z_val_vVoid);

% --- Voiding in window around peak ---
if isempty(z_tsps_drop)
    w_val_vVoid = 0;
else
    w_idxs_drop = []; % initialize empty
    for jj = 1:length(z_tsps_drop)
        % Find positive scale indices within window around this drop
        idx_in_window = z_idx_scaleDiff_up( ...
            z_tsp(z_idx_scaleDiff_up) >= z_tsps_drop(jj)-pre & ...
            z_tsp(z_idx_scaleDiff_up) <= z_tsps_drop(jj)+post ...
        );
        w_idxs_drop = [w_idxs_drop; idx_in_window]; % collect all indices
    end
    % Sum the positive scale changes in window
    w_val_vVoid = sum(z_val_scaleDiff(w_idxs_drop)) * 1000;
end

fprintf('\n Voided volume in window around peak = %.2f µl \n', w_val_vVoid);
%% Find the time-point when urine falls onto the scale
% Calculate the change in scale

%Corrected

z_val_diff = diff(z_val_scale);  % length = length(z_val_scale)-1

% Only consider positive changes for voided volume
z_idx_scaleDiff_up = find(z_val_diff > 0); 
z_val_vVoid = sum(z_val_diff(z_idx_scaleDiff_up)) * 1000; % µl
fprintf('\n Voided volume in whole micturition cycle = %.2f µl\n', z_val_vVoid);

% === Voided volume in selected window around peak ===
if isempty(z_tsps_drop)
    w_val_vVoid = 0;
else
    w_idxs_drop = [];
    for jj = 1:length(z_tsps_drop)
        % Only consider drops within pre/post window around peak
        if (z_tsp_Pmax(1) - z_tsps_drop(jj) < pre) && (z_tsp_Pmax(1) - z_tsps_drop(jj) > -post)
            % Find the closest index in z_val_scale to this drop
            [~, idx] = min(abs(z_tsp - z_tsps_drop(jj)));
            w_idxs_drop = [w_idxs_drop, idx];
        end
    end
    w_val_vVoid = sum(z_val_diff(intersect(w_idxs_drop, z_idx_scaleDiff_up))) * 1000; % µl
end

fprintf('Voided volume in window around peak = %.2f µl\n', w_val_vVoid);


%% =========================
% Define CSV output folder
% =========================
% Parent folder = animal ID folder, e.g., "190R"
current_folder = pwd;
[parent_folder, current_name, ~] = fileparts(current_folder);

% Output folder path
output_csv_folder = fullfile(parent_folder, 'output results');

% Create folder if it doesn't exist
if ~exist(output_csv_folder, 'dir')
    mkdir(output_csv_folder);
    fprintf('Created folder: %s\n', output_csv_folder);
else
    fprintf('Folder already exists: %s\n', output_csv_folder);
end

%% =========================
% NVC Detection (threshold + percentage above threshold, mutually exclusive)
% =========================

% --- 1. Prepare signal ---
% Use original filtered signal for filling phase
signal_fill = z_val_Pfilt(1:length(z_idx_fill));  

% --- 2. Smooth signal for peak shape (optional for findpeaks) ---
z_val_Pfilt_NVC1 = smooth(signal_fill, 2500); % large smoothing window as before

% --- 3. Define thresholds ---
if ~exist('cutoff_nonvoid_contr','var') || isempty(cutoff_nonvoid_contr)
    cutoff_nonvoid_contr = w_val_Pthresh + 0.15*w_val_PthreshToPmax;  % 15% above threshold
end
cutoff_5 = w_val_Pthresh + 0.05*w_val_PthreshToPmax;  % 5% above threshold
cutoff_2 = w_val_Pthresh + 0.02*w_val_PthreshToPmax;  % 2% above threshold

% --- 4. Detect all peaks using smoothed signal ---
[all_peaks_smooth, all_idx] = findpeaks(z_val_Pfilt_NVC1, ...
    'MinPeakDistance', round(fs*0.5), ...
    'MinPeakProminence', 0.5, ...
    'MinPeakWidth', round(fs*0.2));

% --- 5. Get true peak heights from filtered signal ---
all_peaks_true = signal_fill(all_idx);  % actual heights at detected peaks

% --- 6. Classify peaks mutually exclusive ---
idx_15  = all_peaks_true >= cutoff_nonvoid_contr;
idx_5   = all_peaks_true >= cutoff_5  & all_peaks_true < cutoff_nonvoid_contr;
idx_2   = all_peaks_true >= cutoff_2  & all_peaks_true < cutoff_5;
idx_thr = all_peaks_true >= w_val_Pthresh & all_peaks_true < cutoff_2;

% --- 7. Assign values and indices ---
z_no_NVC_15 = all_peaks_true(idx_15);
z_idx_NVC_15 = all_idx(idx_15);

z_no_NVC_5 = all_peaks_true(idx_5);
z_idx_NVC_5 = all_idx(idx_5);

z_no_NVC_2 = all_peaks_true(idx_2);
z_idx_NVC_2 = all_idx(idx_2);

z_no_NVC = all_peaks_true(idx_thr);
z_idx_NVC = all_idx(idx_thr);


% --- 8. Print results ---
fprintf('NVCs (15%% above threshold): %d\n', length(z_no_NVC_15));
fprintf('NVCs (5%% above threshold): %d\n', length(z_no_NVC_5));
fprintf('NVCs (2%% above threshold): %d\n', length(z_no_NVC_2));
fprintf('NVCs at threshold: %d\n', length(z_no_NVC));

%% figure for NVC's

set(0,'DefaultFigureWindowStyle','docked')
h(4) = figure;

% Plot raw and filtered pressure
plot(z_tsp, z_val_p, z_tsp, z_val_Pfilt);
hold on;

z_val_Pfilt_NVC_tot = movmean(z_val_Pfilt, round(fs*0.2)); % e.g., 0.2 s moving average
plot_legend = plot(z_tsp, z_val_Pfilt_NVC_tot, 'k', 'LineWidth', 2);% Plot smoothed NVC signal
plot_legend = plot(z_tsp, z_val_Pfilt_NVC_tot, 'LineWidth', 2);

% Red vertical lines at Pmax
for ll = 1:length(z_tsp_Pmax)
    plot([z_tsp_Pmax(ll) z_tsp_Pmax(ll)], [min(z_val_p), max(z_val_p)], 'r', 'LineWidth', 1);
end

% Horizontal threshold lines
yline(w_val_Pthresh, 'm', 'LineWidth', 1);             % NVC threshold
yline(cutoff_nonvoid_contr, 'm');                     % 15% above threshold

% First threshold crossing
if exist('w_tsp_thresh','var') && ~isempty(w_tsp_thresh)
    xline(w_tsp_thresh(1), 'm', 'LineWidth', 1);
end

% Legend
legend(plot_legend, {'Filtered for NVC'}, 'Location', 'southwest');

%% =========================
% SAVE FIGURE 2 (After compliance/manual window selection)
% =========================
% Define subfolder for micturationcycle figures under animal ID folder
fig_folder = fullfile(parent_folder,'figures', 'micturationcycle figure');
if ~exist(fig_folder,'dir')
    mkdir(fig_folder);
    fprintf('Created folder: %s\n', fig_folder);
else
    fprintf('Folder already exists: %s\n', fig_folder);
end

% Save the main figure (current figure) as Figure 2
fig2_filename = [Measurement_Name '_fig2.png'];
saveas(gcf, fullfile(fig_folder, fig2_filename));
fprintf('Figure 2 saved: %s\n', fullfile(fig_folder, fig2_filename));

% Optional: save any additional figures stored in h array (like old h(4))
if exist('h','var') && ~isempty(h)
    for k = 1:length(h)
        if isgraphics(h(k))
            fig_name = [Measurement_Name '_fig' num2str(k+2) '.png']; % +2 to avoid conflict with fig1/fig2
            saveas(h(k), fullfile(fig_folder, fig_name));
            fprintf('Additional figure saved: %s\n', fullfile(fig_folder, fig_name));
        end
    end
end

%% =========================
% MICRO + SUB-THRESHOLD DETECTION (robust)
% =========================

% --- Define filling phase locally ---
fill_end_idx = z_idx_thresh2(1);  % Find the first threshold crossing (end of filling)

if fill_end_idx < 10
    % If filling is extremely short, just use the whole signal as baseline
    baseline_std = std(z_val_p); 
    z_val_fill_local = z_val_p;
else
    % Otherwise, take the signal up to filling end as local baseline
    z_val_fill_local = z_val_p(1:fill_end_idx);
    % Use first 30% of filling to estimate baseline noise
    baseline_std = std(z_val_fill_local(1:round(end*0.3))); 
end

%%
% --- Micro threshold: noise-adaptive ---
% Define microcontractions as small peaks above baseline noise
% Use 3x the baseline standard deviation or a small fraction of main threshold
cutoff_micro = z_val_Pbase + max(3*baseline_std, 0.05*w_val_Pthresh); 

% --- Sub-threshold threshold ---
% Define sub-threshold peaks as anything between micro and main threshold
% Weighted average to avoid overlap with micro
cutoff_subNVC = w_val_Pthresh*0.7 + cutoff_micro*0.3;  

% --- Unified peak detection ---
% Detect all peaks in the filtered signal
% MinPeakDistance ensures peaks are not too close
% MinPeakProminence avoids counting noise
% MinPeakWidth ensures peaks are wide enough to be real contractions
[all_peaks, all_idx] = findpeaks(z_val_Pfilt_NVC1, ...
    'MinPeakDistance', round(fs*0.5), ...      
    'MinPeakProminence', max(0.5, baseline_std), ...
    'MinPeakWidth', round(fs*0.2));            

% --- Classify peaks ---
% Microcontractions: small peaks above noise but below sub-threshold
idx_micro  = all_peaks >= cutoff_micro & all_peaks < cutoff_subNVC;
% Sub-threshold contractions: peaks above micro but below main threshold
idx_sub    = all_peaks >= cutoff_subNVC & all_peaks < w_val_Pthresh;

% --- Extract peaks and indices ---
z_no_micro   = all_peaks(idx_micro);     % Micro peak heights
z_idx_micro  = all_idx(idx_micro);       % Micro peak positions (indices)

z_no_subNVC  = all_peaks(idx_sub);       % Sub-threshold peak heights
z_idx_subNVC = all_idx(idx_sub);         % Sub-threshold peak positions (indices)

% --- Print results ---
fprintf('Microcontractions: %d\n', length(z_no_micro));
fprintf('Sub-threshold contractions: %d\n', length(z_no_subNVC));


%% =========================
% CLEAN NVC + MICRO PLOT (fixed counts + legend)
% =========================

set(0,'DefaultFigureWindowStyle','docked')
figure; hold on;

% === Base signals ===
y_signal = z_val_Pfilt_NVC1;

% === Base signals ===
h_raw = plot(z_tsp, z_val_p, 'Color', [0.8 0.8 0.8], 'LineWidth', 1.5);
h_filt = plot(z_tsp, z_val_Pfilt, 'b', 'LineWidth', 1.5);
h_smooth = plot(z_tsp, z_val_Pfilt_NVC_tot, 'k', 'LineWidth', 3);

%% --- Threshold lines ---
yline(w_val_Pthresh, 'm', 'LineWidth',2); % main threshold
if exist('cutoff_nonvoid_contr','var'), yline(cutoff_nonvoid_contr,'r--','LineWidth',1.5); end
if exist('cutoff_5','var'), yline(cutoff_5,'Color',[1 0.5 0],'LineStyle','--','LineWidth',1.5); end
if exist('cutoff_2','var'), yline(cutoff_2,'c--','LineWidth',1.5); end
if exist('cutoff_subNVC','var'), yline(cutoff_subNVC,'y--','LineWidth',1.5); end
if exist('cutoff_micro','var'), yline(cutoff_micro,'g--','LineWidth',1.5); end

%% --- Pmax ---
for ll = 1:length(z_tsp_Pmax)
    xline(z_tsp_Pmax(ll), 'r', 'LineWidth',1.5);
end

%% --- Plot peaks using boolean thresholds (match counts) ---
ms = 6;

% 15% peaks
if exist('z_idx_NVC_15','var') && ~isempty(z_idx_NVC_15)
    h15 = plot(z_tsp(z_idx_NVC_15), z_val_p(z_idx_NVC_15), 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', ms);
else, h15 = []; end

% Threshold peaks
if exist('z_idx_NVC','var') && ~isempty(z_idx_NVC)
    hthr = plot(z_tsp(z_idx_NVC), z_val_p(z_idx_NVC), 'mo', 'MarkerFaceColor', 'm', 'MarkerSize', ms);
else, hthr = []; end

% 5% peaks
if exist('z_idx_NVC_5','var') && ~isempty(z_idx_NVC_5)
    h5 = plot(z_tsp(z_idx_NVC_5), z_val_p(z_idx_NVC_5), 'o', 'Color',[1 0.5 0], 'MarkerFaceColor',[1 0.5 0], 'MarkerSize', ms);
else, h5 = []; end

% 2% peaks
if exist('z_idx_NVC_2','var') && ~isempty(z_idx_NVC_2)
    h2 = plot(z_tsp(z_idx_NVC_2), z_val_p(z_idx_NVC_2), 'co', 'MarkerFaceColor','c','MarkerSize',ms);
else, h2 = []; end

% Sub-threshold
if exist('z_idx_subNVC','var')
    hsub = plot(z_tsp(z_idx_subNVC), z_val_p(z_idx_subNVC), ...
        'yo','MarkerFaceColor','y','MarkerSize',ms);
else, hsub=[]; end

% Microcontractions
if exist('z_idx_micro','var')
    hmicro = plot(z_tsp(z_idx_micro), z_val_p(z_idx_micro), ...
        'go','MarkerFaceColor','none','LineWidth',1.5,'MarkerSize',ms+1);
else, hmicro=[]; end

%% --- Labels & legend ---
title(display_name)
xlabel('Time (s)')
ylabel('Pressure (cmH2O)')
set(gca,'FontSize',10)

%% --- Collect handles and labels dynamically (always show all) ---
h_legend = [];
legend_labels = {};
ms = 6; % marker size

% Base signals
if exist('h_raw','var');    h_legend(end+1) = h_raw;    else h_legend(end+1) = plot(nan,nan,'Color',[0.8 0.8 0.8],'LineWidth',1.5); end
legend_labels{end+1} = 'Raw';

if exist('h_filt','var');   h_legend(end+1) = h_filt;   else h_legend(end+1) = plot(nan,nan,'b','LineWidth',1.5); end
legend_labels{end+1} = 'Filtered';

if exist('h_smooth','var'); h_legend(end+1) = h_smooth; else h_legend(end+1) = plot(nan,nan,'k','LineWidth',2); end
legend_labels{end+1} = 'Smoothed';

% Peaks
if exist('h15','var') && ~isempty(h15);       h_legend(end+1) = h15;       else h_legend(end+1) = plot(nan,nan,'ro','MarkerFaceColor','r','MarkerSize',ms); end
legend_labels{end+1} = 'NVC 15%';

if exist('hthr','var') && ~isempty(hthr);     h_legend(end+1) = hthr;     else h_legend(end+1) = plot(nan,nan,'mo','MarkerFaceColor','m','MarkerSize',ms); end
legend_labels{end+1} = 'Threshold';

if exist('h5','var') && ~isempty(h5);         h_legend(end+1) = h5;         else h_legend(end+1) = plot(nan,nan,'o','Color',[1 0.5 0],'MarkerFaceColor',[1 0.5 0],'MarkerSize',ms); end
legend_labels{end+1} = 'NVC 5%';

if exist('h2','var') && ~isempty(h2);         h_legend(end+1) = h2;         else h_legend(end+1) = plot(nan,nan,'co','MarkerFaceColor','c','MarkerSize',ms); end
legend_labels{end+1} = 'NVC 2%';

if exist('hsub','var') && ~isempty(hsub);     h_legend(end+1) = hsub;     else h_legend(end+1) = plot(nan,nan,'yo','MarkerFaceColor','y','MarkerSize',ms); end
legend_labels{end+1} = 'Sub-threshold';

if exist('hmicro','var') && ~isempty(hmicro); h_legend(end+1) = hmicro; else h_legend(end+1) = plot(nan,nan,'go','MarkerFaceColor','none','LineWidth',1.5,'MarkerSize',ms+1); end
legend_labels{end+1} = 'Micro-peaks';

% Apply legend
legend(h_legend, legend_labels, 'Location', 'southwest');


%% =========================
% Save results CSV
% =========================

% Define folder to save CSV
output_csv_folder = fullfile(parent_folder, 'output results');
if ~exist(output_csv_folder, 'dir')
    mkdir(output_csv_folder);
end

% Use current folder name as measurement
Measurement_Name = current_name;

% CSV file name
csv_name = [Measurement_Name '_results.csv'];
fileID = fopen(fullfile(output_csv_folder, csv_name), 'w');

% CSV header
fprintf(fileID, ['Measurement Name,Number of Peaks,Value of Peak (cmH2O),',...
    'Normalized Max Detrusor Pressure (cmH2O),Micturition Cycle Duration (min),',...
    'Normalized Threshold Detrusor Pressure (cmH2O),',...
    'Detrusor Pressure Amplitude from Threshold to Maximum (cmH2O),',...
    'Voided Volume Whole Cycle (µl),Voided Volume Window (µl),',...
    'NVC 15%% above Threshold,NVC at Threshold,NVC 5%% above Threshold,NVC 2%% above Threshold,',...
    'Sub-threshold Contractions,Microcontractions,',...
    'Bladder Compliance (µl/cmH2O),Volume filled (µl),Compliance (ΔV/ΔP)(µl/cmH2O)\n']);

%% =========================
% Prepare safe scalar values
% =========================
val_Pmax = NaN;       % peak pressure
val_nPmax = NaN;      % normalized max detrusor pressure
val_MicDur = NaN;     % micturition cycle duration
val_nPthresh = NaN;   % normalized threshold pressure
val_Pthresh2Pmax = NaN; % pressure amplitude from threshold to max
val_vVoidWhole = NaN; % voided volume whole cycle
val_vVoidWindow = NaN;% voided volume in window
val_NVC_15 = NaN;     % number of NVCs 15% above threshold
val_NVC_thresh = NaN; % number of NVCs at threshold
val_compl = NaN;      % bladder compliance
val_volFilled = NaN;  % volume filled
val_compliance = NaN; % estimated compliance (V/ΔP)
val_NVC_5 = NaN;
val_NVC_2 = NaN;
val_subNVC = NaN;
val_micro = NaN;

% Assign values if variables exist and are not empty
if exist('z_val_Pmax','var') && ~isempty(z_val_Pmax)
    val_Pmax = z_val_Pmax;
end
if exist('z_val_nPmax','var') && ~isempty(z_val_nPmax)
    val_nPmax = z_val_nPmax;
end
if exist('z_val_MicDuration','var') && ~isempty(z_val_MicDuration)
    val_MicDur = z_val_MicDuration;
elseif exist('fill_duration_sec','var') && ~isempty(fill_duration_sec)
    val_MicDur = fill_duration_sec/60; % convert seconds to minutes
end
if exist('z_val_nPthresh','var') && ~isempty(z_val_nPthresh)
    val_nPthresh = z_val_nPthresh;
end
if exist('w_val_PthreshToPmax','var') && ~isempty(w_val_PthreshToPmax)
    val_Pthresh2Pmax = w_val_PthreshToPmax;
end
if exist('z_val_vVoid','var') && ~isempty(z_val_vVoid)
    val_vVoidWhole = z_val_vVoid;
end
if exist('w_val_vVoid','var') && ~isempty(w_val_vVoid)
    val_vVoidWindow = w_val_vVoid;
end

if exist('z_no_NVC_15','var')
    val_NVC_15 = length(z_no_NVC_15);
else
    val_NVC_15 = NaN;
end

% Non-voiding contractions at threshold
if exist('z_no_NVC','var')
    val_NVC_thresh = length(z_no_NVC); % 0 if empty
else
    val_NVC_thresh = NaN;
end

% if exist('z_no_NVC_15aboveThresh','var') && ~isempty(z_no_NVC_15aboveThresh)
%     val_NVC_15 = length(z_no_NVC_15aboveThresh);
% end
% if exist('z_no_NVC','var') && ~isempty(z_no_NVC)
%     val_NVC_thresh = length(z_no_NVC);
% end
if exist('z_val_compl','var') && ~isempty(z_val_compl)
    val_compl = z_val_compl;
end
if exist('volume_filled','var') && ~isempty(volume_filled)
    val_volFilled = volume_filled;
end
if exist('compliance','var') && ~isempty(compliance)
    val_compliance = compliance;
end

if exist('z_no_NVC_5','var')
    val_NVC_5 = length(z_no_NVC_5);
end

if exist('z_no_NVC_2','var')
    val_NVC_2 = length(z_no_NVC_2);
end

if exist('z_no_subNVC','var')
    val_subNVC = length(z_no_subNVC);
end

if exist('z_no_micro','var')
    val_micro = length(z_no_micro);
end

%% =========================
% Write CSV row
% =========================
fprintf(fileID, '%s,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%d,%d,%d,%d,%d,%d,%.2f,%.2f,%.2f\n', ...
    Measurement_Name, length(z_val_Pmax), val_Pmax, val_nPmax, ...
    val_MicDur, val_nPthresh, val_Pthresh2Pmax, ...
    val_vVoidWhole, val_vVoidWindow, ...
    val_NVC_15, val_NVC_thresh, val_NVC_5, val_NVC_2, val_subNVC, val_micro, ...
    val_compl, val_volFilled, val_compliance);

% Close CSV
fclose(fileID);

disp(['CSV output saved to: ', fullfile(output_csv_folder, csv_name)]);


%% =========================
% Save latest NVC figure
% =========================

fig_folder = fullfile(parent_folder, 'figures', 'micturationcycle figure');
if ~exist(fig_folder, 'dir')
    mkdir(fig_folder);
end

% Take the **current figure** (the one being displayed)
h_latest = gcf;  % gcf = get current figure

if isgraphics(h_latest)
    fig_name = [Measurement_Name '_NVC_summary.png'];
    saveas(h_latest, fullfile(fig_folder, fig_name));
    fprintf('Latest NVC figure saved: %s\n', fullfile(fig_folder, fig_name));
end

%%  5: File name: Sham_for_tdms_31032026.m
% Include additional NVC data analysis and read csv format data
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pragya Nagar updated:31.03.2026
% Updated code to read pressure and scale files from new program (pedro)
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

%% ===========================
% LOAD TDMS (CSV-COMPATIBLE)
% ===========================

% Find TDMS file
fileList = dir('*.tdms');
if isempty(fileList)
    error('No TDMS file found in the current folder.');
end

% Use first file
xy = fileList(1).name;   % <-- IMPORTANT: define xy like CSV uses folder name

tdms_full = fullfile(pwd, xy);  % full path (fixes file ID error)

% Load TDMS
[output, ~] = TDMS_readTDMSFile(tdms_full);

% --- Extract channels ---
e_var_pressure = output.data{1,3};
e_var_scale    = output.data{1,4};
e_var_EMG      = output.data{1,5};

% --- Clamp EMG ---
e_var_EMG(e_var_EMG < -1) = -1;
e_var_EMG(e_var_EMG > 1)  = 1;

% --- Sampling rates ---
fs_scale = 1 / output.propValues{1,4}{4};
fs       = 1 / output.propValues{1,3}{4};

% --- Time vectors (match CSV style) ---
e_tsp  = (0:length(e_var_pressure)-1)' / fs;
e_tsps = (0:length(e_var_scale)-1)' / fs_scale;

% --- Ensure column vectors ---
e_var_pressure = e_var_pressure(:);
e_var_scale    = e_var_scale(:);
e_var_EMG      = e_var_EMG(:);

% --- Index ---
e_idx = (1:length(e_tsp))';

% --- OPTIONAL: remove .tdms extension for nicer titles ---
[~, xy_no_ext] = fileparts(xy);
xy = xy_no_ext;   % overwrite xy so title looks clean

% --- Recording time ---
e_val_RecordingTime = max(e_tsp)/60;

% --- Info ---
disp(['Loaded TDMS file: ', xy]);
fprintf('Sampling rate (pressure): %.2f Hz\n', fs);
fprintf('Sampling rate (scale): %.2f Hz\n', fs_scale);
fprintf('Recording duration: %.2f min\n', e_val_RecordingTime);

%% ===========================
% 5. QUICK SANITY PLOT
% ===========================

figure;

subplot(2,1,1)
plot(e_tsp, e_var_pressure)
xlabel('Time (s)')
ylabel('Pressure')
title('Pressure vs Time')
grid on

subplot(2,1,2)
plot(e_tsps, e_var_scale)
xlabel('Time (s)')
ylabel('Scale')
title('Scale vs Time')
grid on

%% Figure 1 = raw data
set(0,'DefaultFigureWindowStyle','docked')
summaryGraph = figure;

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

subplot 212
plot(e_tsps(time_limit_idx_scale), e_var_scale(time_limit_idx_scale))   %original data, 5Hz
xlim([0 3000])
set(gca,'FontSize',18)
xlabel('Time [s]')
ylabel('V_v_o_i_d [mL]')

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
%z_val_emg = e_var_EMG(z_idx_t);  % keep the EMG data as is

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

%% =========================
% Define Measurement Name and folders (TDMS-aware)
% =========================

current_folder = pwd;  
% e.g. .../189L/Day 2

% Go UP one level to get animal folder (189L)
[parent_folder, day_folder] = fileparts(current_folder);   % parent_folder = .../189L
[grandparent_folder, animal_ID] = fileparts(parent_folder); % animal_ID = 189L

% --- Get TDMS filename ---
fileList = dir('*.tdms');

if isempty(fileList)
    error('No TDMS file found in this folder.');
end

tdms_name = fileList(1).name;  % e.g. '189L_202602111046.tdms'

% Remove extension
[~, name_no_ext] = fileparts(tdms_name);

% --- Use TDMS name as measurement ---
Measurement_Name = name_no_ext;

% Optional display formatting
display_name = strrep(Measurement_Name,'_','-');

fprintf('Animal ID: %s\n', animal_ID);
fprintf('Day folder: %s\n', day_folder);
fprintf('Measurement: %s\n', Measurement_Name);

%% =========================
% Create figures folder (inside animal folder)
% =========================

figures_folder = fullfile(parent_folder,'figures');  % inside 189L
if ~exist(figures_folder,'dir')
    mkdir(figures_folder);
end

%% =========================
% SAVE FIGURE 1
% =========================

fig1_filename = [Measurement_Name '_fig1.png'];
saveas(gcf, fullfile(figures_folder, fig1_filename));

fprintf('Figure 1 saved: %s\n', fullfile(figures_folder, fig1_filename));
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

%% test

% Your existing normalized data & limited time indices:
% e_var_pressure_norm, e_tsp(time_limit_idx)
% e_var_scale_norm, e_tsps(time_limit_idx_scale)

% Plot your existing figure again if needed
figure(summaryGraph); % make sure the figure exists or create a new one

subplot(211)
plot(e_tsp(time_limit_idx), e_var_pressure_norm, 'k');
xlim([0 3000]);
ylim([0 40]);
yticks(0:10:40);
title('Pressure (normalized)');
set(gca,'XTickLabel',[]);
set(gca,'FontSize',18);
ylabel('P_v_e_s_i_c_a_l [cmH_2O]');
hold on;

subplot(212)
plot(e_tsps(time_limit_idx_scale), e_var_scale_norm, 'b');
xlim([0 3000]);
set(gca,'FontSize',18);
xlabel('Time [s]');
ylabel('V_v_o_i_d [mL]');
hold on;

% === Manual selection on pressure plot ===
subplot(211);
fprintf('Click start and end of micturition on the pressure plot.\n');
[x_sel, ~] = ginput(2);
t_start = min(x_sel);
t_end = max(x_sel);

% === Extract indices in the selected window ===
idx_pressure_window = find(e_tsp(time_limit_idx) >= t_start & e_tsp(time_limit_idx) <= t_end);
idx_scale_window = find(e_tsps(time_limit_idx_scale) >= t_start & e_tsps(time_limit_idx_scale) <= t_end);

% Check if indices are empty (common mistake)
if isempty(idx_pressure_window) || isempty(idx_scale_window)
    error('No data points found in selected window. Please select within data range.');
end

%%
% === Extract data slices ===
pressure_window = e_var_pressure_norm(idx_pressure_window);
time_pressure_window = e_tsp(time_limit_idx);
time_pressure_window = time_pressure_window(idx_pressure_window);

scale_window = e_var_scale_norm(idx_scale_window);
time_scale_window = e_tsps(time_limit_idx_scale);
time_scale_window = time_scale_window(idx_scale_window);

% === Restrict time vectors to their overlapping range to avoid NaNs in interpolation ===
t_min = max(min(time_pressure_window), min(time_scale_window));
t_max = min(max(time_pressure_window), max(time_scale_window));

valid_idx = time_pressure_window >= t_min & time_pressure_window <= t_max;

pressure_window = pressure_window(valid_idx);
time_pressure_window = time_pressure_window(valid_idx);

% Interpolate volume data onto pressure time vector within overlapping window
scale_window_interp = interp1(time_scale_window, scale_window, time_pressure_window, 'linear');

% Check for NaNs after interpolation
if any(isnan(scale_window_interp))
    error('NaNs found in interpolated volume data after restricting time window. Check time vectors.');
end

% === Calculate compliance and volume filled ===
fill_duration_sec = t_end - t_start; % duration in seconds
volume_filled = (20 / 60) * fill_duration_sec;
delta_pressure = max(pressure_window) - min(pressure_window);
compliance = volume_filled / delta_pressure;
fprintf('Compliance (Vfilling / ΔP) = %.4f µl/cmH2O\n', compliance);


% === Plot highlighted window ===
subplot(211);
plot(time_pressure_window, pressure_window, 'r', 'LineWidth', 2);

subplot(212);
plot(time_pressure_window, scale_window_interp, 'm', 'LineWidth', 2);

%% compliance
z_val_compl = z_val_fillDuration*20/z_val_nPthresh; % ul/cmH2O

%% Find the time-point when urine falls onto the scale
z_val_diff = diff(z_val_scale); 

if exist('corr','var') && ~isempty(corr)
    % Ensure lengths match
    min_len = min(length(z_val_diff), length(corr));
    z_val_scaleDiff = [z_val_diff(1:min_len), corr(1:min_len)];
else
    z_val_scaleDiff = z_val_diff;
end

% Indices of positive changes
z_idx_scaleDiff_up = find(z_val_scaleDiff > 0); 
z_val_vVoid = sum(z_val_scaleDiff(z_idx_scaleDiff_up)) * 1000;
fprintf('\n Voided volume in whole micturition cycle = %.2f µl\n', z_val_vVoid);

% --- Voiding in window around peak ---
if isempty(z_tsps_drop)
    w_val_vVoid = 0;
else
    w_idxs_drop = []; % initialize empty
    for jj = 1:length(z_tsps_drop)
        % Find positive scale indices within window around this drop
        idx_in_window = z_idx_scaleDiff_up( ...
            z_tsp(z_idx_scaleDiff_up) >= z_tsps_drop(jj)-pre & ...
            z_tsp(z_idx_scaleDiff_up) <= z_tsps_drop(jj)+post ...
        );
        w_idxs_drop = [w_idxs_drop; idx_in_window]; % collect all indices
    end
    % Sum the positive scale changes in window
    w_val_vVoid = sum(z_val_scaleDiff(w_idxs_drop)) * 1000;
end

fprintf('\n Voided volume in window around peak = %.2f µl \n', w_val_vVoid);
%% Find the time-point when urine falls onto the scale
% Calculate the change in scale

%Corrected

z_val_diff = diff(z_val_scale);  % length = length(z_val_scale)-1

% Only consider positive changes for voided volume
z_idx_scaleDiff_up = find(z_val_diff > 0); 
z_val_vVoid = sum(z_val_diff(z_idx_scaleDiff_up)) * 1000; % µl
fprintf('\n Voided volume in whole micturition cycle = %.2f µl\n', z_val_vVoid);

% === Voided volume in selected window around peak ===
if isempty(z_tsps_drop)
    w_val_vVoid = 0;
else
    w_idxs_drop = [];
    for jj = 1:length(z_tsps_drop)
        % Only consider drops within pre/post window around peak
        if (z_tsp_Pmax(1) - z_tsps_drop(jj) < pre) && (z_tsp_Pmax(1) - z_tsps_drop(jj) > -post)
            % Find the closest index in z_val_scale to this drop
            [~, idx] = min(abs(z_tsp - z_tsps_drop(jj)));
            w_idxs_drop = [w_idxs_drop, idx];
        end
    end
    w_val_vVoid = sum(z_val_diff(intersect(w_idxs_drop, z_idx_scaleDiff_up))) * 1000; % µl
end

fprintf('Voided volume in window around peak = %.2f µl\n', w_val_vVoid);

%% =========================
% Define CSV output folder
% =========================
% Parent folder = animal ID folder, e.g., "190R"
current_folder = pwd;
[parent_folder, current_name, ~] = fileparts(current_folder);

% Output folder path
output_csv_folder = fullfile(parent_folder, 'output results');

% Create folder if it doesn't exist
if ~exist(output_csv_folder, 'dir')
    mkdir(output_csv_folder);
    fprintf('Created folder: %s\n', output_csv_folder);
else
    fprintf('Folder already exists: %s\n', output_csv_folder);
end

%% =========================
% NVC Detection (threshold + percentage above threshold, mutually exclusive)
% =========================

% --- 1. Prepare signal ---
% Use original filtered signal for filling phase
signal_fill = z_val_Pfilt(1:length(z_idx_fill));  

% --- 2. Smooth signal for peak shape (optional for findpeaks) ---
z_val_Pfilt_NVC1 = smooth(signal_fill, 2500); % large smoothing window as before

% --- 3. Define thresholds ---
if ~exist('cutoff_nonvoid_contr','var') || isempty(cutoff_nonvoid_contr)
    cutoff_nonvoid_contr = w_val_Pthresh + 0.15*w_val_PthreshToPmax;  % 15% above threshold
end
cutoff_5 = w_val_Pthresh + 0.05*w_val_PthreshToPmax;  % 5% above threshold
cutoff_2 = w_val_Pthresh + 0.02*w_val_PthreshToPmax;  % 2% above threshold

% --- 4. Detect all peaks using smoothed signal ---
[all_peaks_smooth, all_idx] = findpeaks(z_val_Pfilt_NVC1, ...
    'MinPeakDistance', round(fs*0.5), ...
    'MinPeakProminence', 0.5, ...
    'MinPeakWidth', round(fs*0.2));

% --- 5. Get true peak heights from filtered signal ---
all_peaks_true = signal_fill(all_idx);  % actual heights at detected peaks

% --- 6. Classify peaks mutually exclusive ---
idx_15  = all_peaks_true >= cutoff_nonvoid_contr;
idx_5   = all_peaks_true >= cutoff_5  & all_peaks_true < cutoff_nonvoid_contr;
idx_2   = all_peaks_true >= cutoff_2  & all_peaks_true < cutoff_5;
idx_thr = all_peaks_true >= w_val_Pthresh & all_peaks_true < cutoff_2;

% --- 7. Assign values and indices ---
z_no_NVC_15 = all_peaks_true(idx_15);
z_idx_NVC_15 = all_idx(idx_15);

z_no_NVC_5 = all_peaks_true(idx_5);
z_idx_NVC_5 = all_idx(idx_5);

z_no_NVC_2 = all_peaks_true(idx_2);
z_idx_NVC_2 = all_idx(idx_2);

z_no_NVC = all_peaks_true(idx_thr);
z_idx_NVC = all_idx(idx_thr);


% --- 8. Print results ---
fprintf('NVCs (15%% above threshold): %d\n', length(z_no_NVC_15));
fprintf('NVCs (5%% above threshold): %d\n', length(z_no_NVC_5));
fprintf('NVCs (2%% above threshold): %d\n', length(z_no_NVC_2));
fprintf('NVCs at threshold: %d\n', length(z_no_NVC));

%% figure for NVC's

set(0,'DefaultFigureWindowStyle','docked')
h(4) = figure;

% Plot raw and filtered pressure
plot(z_tsp, z_val_p, z_tsp, z_val_Pfilt);
hold on;

z_val_Pfilt_NVC_tot = movmean(z_val_Pfilt, round(fs*0.2)); % e.g., 0.2 s moving average
plot_legend = plot(z_tsp, z_val_Pfilt_NVC_tot, 'k', 'LineWidth', 2);% Plot smoothed NVC signal
plot_legend = plot(z_tsp, z_val_Pfilt_NVC_tot, 'LineWidth', 2);

% Red vertical lines at Pmax
for ll = 1:length(z_tsp_Pmax)
    plot([z_tsp_Pmax(ll) z_tsp_Pmax(ll)], [min(z_val_p), max(z_val_p)], 'r', 'LineWidth', 1);
end

% Horizontal threshold lines
yline(w_val_Pthresh, 'm', 'LineWidth', 1);             % NVC threshold
yline(cutoff_nonvoid_contr, 'm');                     % 15% above threshold

% First threshold crossing
if exist('w_tsp_thresh','var') && ~isempty(w_tsp_thresh)
    xline(w_tsp_thresh(1), 'm', 'LineWidth', 1);
end

% Legend
legend(plot_legend, {'Filtered for NVC'}, 'Location', 'southwest');

%% =========================
% SAVE FIGURE 2 (After compliance/manual window selection)
% =========================
% Define subfolder for micturationcycle figures under animal ID folder
fig_folder = fullfile(parent_folder,'figures', 'micturationcycle figure');
if ~exist(fig_folder,'dir')
    mkdir(fig_folder);
    fprintf('Created folder: %s\n', fig_folder);
else
    fprintf('Folder already exists: %s\n', fig_folder);
end

% Save the main figure (current figure) as Figure 2
fig2_filename = [Measurement_Name '_fig2.png'];
saveas(gcf, fullfile(fig_folder, fig2_filename));
fprintf('Figure 2 saved: %s\n', fullfile(fig_folder, fig2_filename));

% Optional: save any additional figures stored in h array (like old h(4))
if exist('h','var') && ~isempty(h)
    for k = 1:length(h)
        if isgraphics(h(k))
            fig_name = [Measurement_Name '_fig' num2str(k+2) '.png']; % +2 to avoid conflict with fig1/fig2
            saveas(h(k), fullfile(fig_folder, fig_name));
            fprintf('Additional figure saved: %s\n', fullfile(fig_folder, fig_name));
        end
    end
end

%% =========================
% MICRO + SUB-THRESHOLD DETECTION (robust)
% =========================

% --- Define filling phase locally ---
fill_end_idx = z_idx_thresh2(1);  % Find the first threshold crossing (end of filling)

if fill_end_idx < 10
    % If filling is extremely short, just use the whole signal as baseline
    baseline_std = std(z_val_p); 
    z_val_fill_local = z_val_p;
else
    % Otherwise, take the signal up to filling end as local baseline
    z_val_fill_local = z_val_p(1:fill_end_idx);
    % Use first 30% of filling to estimate baseline noise
    baseline_std = std(z_val_fill_local(1:round(end*0.3))); 
end

%%
% --- Micro threshold: noise-adaptive ---
% Define microcontractions as small peaks above baseline noise
% Use 3x the baseline standard deviation or a small fraction of main threshold
cutoff_micro = z_val_Pbase + max(3*baseline_std, 0.05*w_val_Pthresh); 

% --- Sub-threshold threshold ---
% Define sub-threshold peaks as anything between micro and main threshold
% Weighted average to avoid overlap with micro
cutoff_subNVC = w_val_Pthresh*0.7 + cutoff_micro*0.3;  

% --- Unified peak detection ---
% Detect all peaks in the filtered signal
% MinPeakDistance ensures peaks are not too close
% MinPeakProminence avoids counting noise
% MinPeakWidth ensures peaks are wide enough to be real contractions
[all_peaks, all_idx] = findpeaks(z_val_Pfilt_NVC1, ...
    'MinPeakDistance', round(fs*0.5), ...      
    'MinPeakProminence', max(0.5, baseline_std), ...
    'MinPeakWidth', round(fs*0.2));            

% --- Classify peaks ---
% Microcontractions: small peaks above noise but below sub-threshold
idx_micro  = all_peaks >= cutoff_micro & all_peaks < cutoff_subNVC;
% Sub-threshold contractions: peaks above micro but below main threshold
idx_sub    = all_peaks >= cutoff_subNVC & all_peaks < w_val_Pthresh;

% --- Extract peaks and indices ---
z_no_micro   = all_peaks(idx_micro);     % Micro peak heights
z_idx_micro  = all_idx(idx_micro);       % Micro peak positions (indices)

z_no_subNVC  = all_peaks(idx_sub);       % Sub-threshold peak heights
z_idx_subNVC = all_idx(idx_sub);         % Sub-threshold peak positions (indices)

% --- Print results ---
fprintf('Microcontractions: %d\n', length(z_no_micro));
fprintf('Sub-threshold contractions: %d\n', length(z_no_subNVC));


%% =========================
% CLEAN NVC + MICRO PLOT (fixed counts + legend)
% =========================

set(0,'DefaultFigureWindowStyle','docked')
figure; hold on;

% === Base signals ===
y_signal = z_val_Pfilt_NVC1;

% === Base signals ===
h_raw = plot(z_tsp, z_val_p, 'Color', [0.8 0.8 0.8], 'LineWidth', 1.5);
h_filt = plot(z_tsp, z_val_Pfilt, 'b', 'LineWidth', 1.5);
h_smooth = plot(z_tsp, z_val_Pfilt_NVC_tot, 'k', 'LineWidth', 3);

%% --- Threshold lines ---
yline(w_val_Pthresh, 'm', 'LineWidth',2); % main threshold
if exist('cutoff_nonvoid_contr','var'), yline(cutoff_nonvoid_contr,'r--','LineWidth',1.5); end
if exist('cutoff_5','var'), yline(cutoff_5,'Color',[1 0.5 0],'LineStyle','--','LineWidth',1.5); end
if exist('cutoff_2','var'), yline(cutoff_2,'c--','LineWidth',1.5); end
if exist('cutoff_subNVC','var'), yline(cutoff_subNVC,'y--','LineWidth',1.5); end
if exist('cutoff_micro','var'), yline(cutoff_micro,'g--','LineWidth',1.5); end

%% --- Pmax ---
for ll = 1:length(z_tsp_Pmax)
    xline(z_tsp_Pmax(ll), 'r', 'LineWidth',1.5);
end

%% --- Plot peaks using boolean thresholds (match counts) ---
ms = 6;

% 15% peaks
if exist('z_idx_NVC_15','var') && ~isempty(z_idx_NVC_15)
    h15 = plot(z_tsp(z_idx_NVC_15), z_val_p(z_idx_NVC_15), 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', ms);
else, h15 = []; end

% Threshold peaks
if exist('z_idx_NVC','var') && ~isempty(z_idx_NVC)
    hthr = plot(z_tsp(z_idx_NVC), z_val_p(z_idx_NVC), 'mo', 'MarkerFaceColor', 'm', 'MarkerSize', ms);
else, hthr = []; end

% 5% peaks
if exist('z_idx_NVC_5','var') && ~isempty(z_idx_NVC_5)
    h5 = plot(z_tsp(z_idx_NVC_5), z_val_p(z_idx_NVC_5), 'o', 'Color',[1 0.5 0], 'MarkerFaceColor',[1 0.5 0], 'MarkerSize', ms);
else, h5 = []; end

% 2% peaks
if exist('z_idx_NVC_2','var') && ~isempty(z_idx_NVC_2)
    h2 = plot(z_tsp(z_idx_NVC_2), z_val_p(z_idx_NVC_2), 'co', 'MarkerFaceColor','c','MarkerSize',ms);
else, h2 = []; end

% Sub-threshold
if exist('z_idx_subNVC','var')
    hsub = plot(z_tsp(z_idx_subNVC), z_val_p(z_idx_subNVC), ...
        'yo','MarkerFaceColor','y','MarkerSize',ms);
else, hsub=[]; end

% Microcontractions
if exist('z_idx_micro','var')
    hmicro = plot(z_tsp(z_idx_micro), z_val_p(z_idx_micro), ...
        'go','MarkerFaceColor','none','LineWidth',1.5,'MarkerSize',ms+1);
else, hmicro=[]; end

%% --- Labels & legend ---
title(display_name)
xlabel('Time (s)')
ylabel('Pressure (cmH2O)')
set(gca,'FontSize',20)

%% --- Collect handles and labels dynamically (always show all) ---
h_legend = [];
legend_labels = {};
ms = 8; % marker size

% Base signals
if exist('h_raw','var');    h_legend(end+1) = h_raw;    else h_legend(end+1) = plot(nan,nan,'Color',[0.8 0.8 0.8],'LineWidth',1.5); end
legend_labels{end+1} = 'Raw';

if exist('h_filt','var');   h_legend(end+1) = h_filt;   else h_legend(end+1) = plot(nan,nan,'b','LineWidth',1.5); end
legend_labels{end+1} = 'Filtered';

if exist('h_smooth','var'); h_legend(end+1) = h_smooth; else h_legend(end+1) = plot(nan,nan,'k','LineWidth',2); end
legend_labels{end+1} = 'Smoothed';

% Peaks
if exist('h15','var') && ~isempty(h15);       h_legend(end+1) = h15;       else h_legend(end+1) = plot(nan,nan,'ro','MarkerFaceColor','r','MarkerSize',ms); end
legend_labels{end+1} = 'NVC 15%';

if exist('hthr','var') && ~isempty(hthr);     h_legend(end+1) = hthr;     else h_legend(end+1) = plot(nan,nan,'mo','MarkerFaceColor','m','MarkerSize',ms); end
legend_labels{end+1} = 'Threshold';

if exist('h5','var') && ~isempty(h5);         h_legend(end+1) = h5;         else h_legend(end+1) = plot(nan,nan,'o','Color',[1 0.5 0],'MarkerFaceColor',[1 0.5 0],'MarkerSize',ms); end
legend_labels{end+1} = 'NVC 5%';

if exist('h2','var') && ~isempty(h2);         h_legend(end+1) = h2;         else h_legend(end+1) = plot(nan,nan,'co','MarkerFaceColor','c','MarkerSize',ms); end
legend_labels{end+1} = 'NVC 2%';

if exist('hsub','var') && ~isempty(hsub);     h_legend(end+1) = hsub;     else h_legend(end+1) = plot(nan,nan,'yo','MarkerFaceColor','y','MarkerSize',ms); end
legend_labels{end+1} = 'Sub-threshold';

if exist('hmicro','var') && ~isempty(hmicro); h_legend(end+1) = hmicro; else h_legend(end+1) = plot(nan,nan,'go','MarkerFaceColor','none','LineWidth',1.5,'MarkerSize',ms+1); end
legend_labels{end+1} = 'Micro-peaks';

% Apply legend
legend(h_legend, legend_labels, 'Location', 'southwest');


%% =========================
% Save results CSV
% =========================
% 
% % Define folder to save CSV
% output_csv_folder = fullfile(parent_folder, 'output results');
% if ~exist(output_csv_folder, 'dir')
%     mkdir(output_csv_folder);
% end
% 
% % Use current folder name as measurement
% Measurement_Name = current_name;
% 
% % CSV file name
% csv_name = [Measurement_Name '_results.csv'];
% fileID = fopen(fullfile(output_csv_folder, csv_name), 'w');

%% =========================
% Save results CSV (TDMS-based naming)
% =========================

% Define folder
output_csv_folder = fullfile(parent_folder, 'output results');
if ~exist(output_csv_folder, 'dir')
    mkdir(output_csv_folder);
end

% --- Get TDMS filename (no extension) ---
fileList = dir('*.tdms');
if isempty(fileList)
    error('No TDMS file found for naming.');
end

[~, tdms_name_no_ext] = fileparts(fileList(1).name);
% Example: '189L_202602111046'

% --- Split ID and timestamp ---
parts = split(tdms_name_no_ext, '_');
animal_ID = parts{1};
timestamp_raw = parts{2};  % '202602111046'

% --- Convert timestamp to CSV-style ---
year  = timestamp_raw(1:4);
month = timestamp_raw(5:6);
day   = timestamp_raw(7:8);
hour  = timestamp_raw(9:10);
minu  = timestamp_raw(11:12);

Measurement_Name = sprintf('%s_%s-%s-%s_%s-%s', ...
    animal_ID, year, month, day, hour, minu);

% --- Final CSV filename ---
csv_name = [Measurement_Name '_results.csv'];

fileID = fopen(fullfile(output_csv_folder, csv_name), 'w');

fprintf('Saving CSV as: %s\n', csv_name);

% CSV header
fprintf(fileID, ['Measurement Name,Number of Peaks,Value of Peak (cmH2O),',...
    'Normalized Max Detrusor Pressure (cmH2O),Micturition Cycle Duration (min),',...
    'Normalized Threshold Detrusor Pressure (cmH2O),',...
    'Detrusor Pressure Amplitude from Threshold to Maximum (cmH2O),',...
    'Voided Volume Whole Cycle (µl),Voided Volume Window (µl),',...
    'NVC 15%% above Threshold,NVC at Threshold,NVC 5%% above Threshold,NVC 2%% above Threshold,',...
    'Sub-threshold Contractions,Microcontractions,',...
    'Bladder Compliance (µl/cmH2O),Volume filled (µl),Compliance (ΔV/ΔP)(µl/cmH2O)\n']);

%% =========================
% Prepare safe scalar values
% =========================
val_Pmax = NaN;       % peak pressure
val_nPmax = NaN;      % normalized max detrusor pressure
val_MicDur = NaN;     % micturition cycle duration
val_nPthresh = NaN;   % normalized threshold pressure
val_Pthresh2Pmax = NaN; % pressure amplitude from threshold to max
val_vVoidWhole = NaN; % voided volume whole cycle
val_vVoidWindow = NaN;% voided volume in window
val_NVC_15 = NaN;     % number of NVCs 15% above threshold
val_NVC_thresh = NaN; % number of NVCs at threshold
val_compl = NaN;      % bladder compliance
val_volFilled = NaN;  % volume filled
val_compliance = NaN; % estimated compliance (V/ΔP)
val_NVC_5 = NaN;
val_NVC_2 = NaN;
val_subNVC = NaN;
val_micro = NaN;

% Assign values if variables exist and are not empty
if exist('z_val_Pmax','var') && ~isempty(z_val_Pmax)
    val_Pmax = z_val_Pmax;
end
if exist('z_val_nPmax','var') && ~isempty(z_val_nPmax)
    val_nPmax = z_val_nPmax;
end
if exist('z_val_MicDuration','var') && ~isempty(z_val_MicDuration)
    val_MicDur = z_val_MicDuration;
elseif exist('fill_duration_sec','var') && ~isempty(fill_duration_sec)
    val_MicDur = fill_duration_sec/60; % convert seconds to minutes
end
if exist('z_val_nPthresh','var') && ~isempty(z_val_nPthresh)
    val_nPthresh = z_val_nPthresh;
end
if exist('w_val_PthreshToPmax','var') && ~isempty(w_val_PthreshToPmax)
    val_Pthresh2Pmax = w_val_PthreshToPmax;
end
if exist('z_val_vVoid','var') && ~isempty(z_val_vVoid)
    val_vVoidWhole = z_val_vVoid;
end
if exist('w_val_vVoid','var') && ~isempty(w_val_vVoid)
    val_vVoidWindow = w_val_vVoid;
end

if exist('z_no_NVC_15','var')
    val_NVC_15 = length(z_no_NVC_15);
else
    val_NVC_15 = NaN;
end

% Non-voiding contractions at threshold
if exist('z_no_NVC','var')
    val_NVC_thresh = length(z_no_NVC); % 0 if empty
else
    val_NVC_thresh = NaN;
end

% if exist('z_no_NVC_15aboveThresh','var') && ~isempty(z_no_NVC_15aboveThresh)
%     val_NVC_15 = length(z_no_NVC_15aboveThresh);
% end
% if exist('z_no_NVC','var') && ~isempty(z_no_NVC)
%     val_NVC_thresh = length(z_no_NVC);
% end
if exist('z_val_compl','var') && ~isempty(z_val_compl)
    val_compl = z_val_compl;
end
if exist('volume_filled','var') && ~isempty(volume_filled)
    val_volFilled = volume_filled;
end
if exist('compliance','var') && ~isempty(compliance)
    val_compliance = compliance;
end

if exist('z_no_NVC_5','var')
    val_NVC_5 = length(z_no_NVC_5);
end

if exist('z_no_NVC_2','var')
    val_NVC_2 = length(z_no_NVC_2);
end

if exist('z_no_subNVC','var')
    val_subNVC = length(z_no_subNVC);
end

if exist('z_no_micro','var')
    val_micro = length(z_no_micro);
end

%% =========================
% Write CSV row
% =========================
fprintf(fileID, '%s,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%d,%d,%d,%d,%d,%d,%.2f,%.2f,%.2f\n', ...
    Measurement_Name, length(z_val_Pmax), val_Pmax, val_nPmax, ...
    val_MicDur, val_nPthresh, val_Pthresh2Pmax, ...
    val_vVoidWhole, val_vVoidWindow, ...
    val_NVC_15, val_NVC_thresh, val_NVC_5, val_NVC_2, val_subNVC, val_micro, ...
    val_compl, val_volFilled, val_compliance);

% Close CSV
fclose(fileID);

disp(['CSV output saved to: ', fullfile(output_csv_folder, csv_name)]);


%% =========================
% Save latest NVC figure
% =========================

fig_folder = fullfile(parent_folder, 'figures', 'micturationcycle figure');
if ~exist(fig_folder, 'dir')
    mkdir(fig_folder);
end

% Take the **current figure** (the one being displayed)
h_latest = gcf;  % gcf = get current figure

if isgraphics(h_latest)
    fig_name = [Measurement_Name '_NVC_summary.png'];
    saveas(h_latest, fullfile(fig_folder, fig_name));
    fprintf('Latest NVC figure saved: %s\n', fullfile(fig_folder, fig_name));
end

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 6: File name: Plotting_tracings.m
% To make tracing plots with corrected scale from tdms/csv files
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pragya Nagar ,updated:01.05.2026
% Code to make plots for selected animals
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc; clear; close all;

%% ===========================
% LOAD TDMS (CSV-COMPATIBLE)
% ===========================

% Find TDMS file
fileList = dir('*.tdms');
if isempty(fileList)
    error('No TDMS file found in the current folder.');
end

% Use first file
xy = fileList(1).name;   % <-- IMPORTANT: define xy like CSV uses folder name

tdms_full = fullfile(pwd, xy);  % full path (fixes file ID error)

% Load TDMS
[output, ~] = TDMS_readTDMSFile(tdms_full);

% --- Extract channels ---
e_var_pressure = output.data{1,3};
e_var_scale    = output.data{1,4};
e_var_EMG      = output.data{1,5};

% --- Clamp EMG ---
e_var_EMG(e_var_EMG < -1) = -1;
e_var_EMG(e_var_EMG > 1)  = 1;

% --- Sampling rates ---
fs_scale = 1 / output.propValues{1,4}{4};
fs       = 1 / output.propValues{1,3}{4};

% --- Time vectors (match CSV style) ---
e_tsp  = (0:length(e_var_pressure)-1)' / fs;
e_tsps = (0:length(e_var_scale)-1)' / fs_scale;

% --- Ensure column vectors ---
e_var_pressure = e_var_pressure(:);
e_var_scale    = e_var_scale(:);
e_var_EMG      = e_var_EMG(:);

% --- Index ---
e_idx = (1:length(e_tsp))';

% --- OPTIONAL: remove .tdms extension for nicer titles ---
[~, xy_no_ext] = fileparts(xy);
xy = xy_no_ext;   % overwrite xy so title looks clean

% --- Recording time ---
e_val_RecordingTime = max(e_tsp)/60;

% --- Info ---
disp(['Loaded TDMS file: ', xy]);
fprintf('Sampling rate (pressure): %.2f Hz\n', fs);
fprintf('Sampling rate (scale): %.2f Hz\n', fs_scale);
fprintf('Recording duration: %.2f min\n', e_val_RecordingTime);
fprintf('Recording duration: %.2f sec\n', max(e_tsp));

%% ===========================
% 1. LOAD DATA (CSV with headers)- If file from new python software 
% ===========================

% % Get folder name as measurement ID
% currentFolder = pwd;
% [~, xy] = fileparts(currentFolder);
% 
% disp(['Loaded folder: ', xy]);
% 
% % Read CSV files as tables (IMPORTANT)
% df_pressure = readtable('pressure.csv');
% df_scale    = readtable('scale.csv');
% 
% % Check column names (optional but useful)
% disp('Pressure columns:');
% disp(df_pressure.Properties.VariableNames);
% 
% disp('Scale columns:');
% disp(df_scale.Properties.VariableNames);
% 
% %% ===========================
% % 2. ALIGN TIME USING UNIX (same as Python)
% % ===========================
% 
% t0 = min([min(df_pressure.t_unix_s), min(df_scale.t_unix_s)]);
% 
% df_pressure.t_rel = df_pressure.t_unix_s - t0;
% df_scale.t_rel    = df_scale.t_unix_s - t0;
% 
% %% ===========================
% % 3. EXTRACT VARIABLES (match old pipeline)
% % ===========================
% 
% e_tsp = df_pressure.t_rel;          % pressure time (seconds)
% e_var_pressure = df_pressure.pressure;
% 
% e_tsps = df_scale.t_rel;            % scale time (seconds)
% e_var_scale = df_scale.scale;
% 
% e_idx = 1:length(e_tsp);
% 
% %% ===========================
% % 4. SAMPLING RATES (auto-computed)
% % ===========================
% 
% fs = 1 / mean(diff(e_tsp));
% fs_scale = 1 / mean(diff(e_tsps));
% 
% fprintf('Sampling rate (pressure): %.2f Hz\n', fs);
% fprintf('Sampling rate (scale): %.2f Hz\n', fs_scale);
% fprintf('Recording duration: %.2f sec\n', max(e_tsp));

%% ===========================
% QUICK SANITY PLOT
% ===========================
set(0,'DefaultFigureWindowStyle','docked')
figure;

subplot(2,1,1)
plot(e_tsp, e_var_pressure)
xlabel('Time (s)')
ylabel('Pressure')
title('Pressure vs Time')
grid on

subplot(2,1,2)
plot(e_tsps, e_var_scale)
xlabel('Time (s)')
ylabel('Scale')
title('Scale vs Time')
grid on

%% ===========================
% PLOTTING SETTINGS
% ===========================

plotStart = 0;        % change this
plotEnd   = 3000;     % change this

scaleMode = "clamp";  % "clamp" = negatives become 0
                      % "offset" = shift whole trace positive
saveFigures = true;

pressure_ylim = [0 80];
font_main = 16;
font_axis = 22;


%% ===========================
% CLEAN / NORMALIZE DATA
% ===========================

% Pressure normalized to start at 0
e_var_pressure_norm = e_var_pressure - min(e_var_pressure);

switch scaleMode
    case "clamp"
        e_var_scale_plot = e_var_scale;
        e_var_scale_plot(e_var_scale_plot < 0) = 0;

    case "offset"
        min_scale = min(e_var_scale, [], 'omitnan');
        e_var_scale_plot = e_var_scale - min_scale;
        e_var_scale_plot(e_var_scale_plot < 0) = 0;

    otherwise
        error('Unknown scaleMode. Use "clamp" or "offset".')
end

%% ===========================
% SCALE CORRECTION
% ===========================

e_var_scale_plot = e_var_scale(:);

% Remove bad values
e_var_scale_plot(~isfinite(e_var_scale_plot)) = 0;

% Shift so the minimum becomes zero
e_var_scale_plot = e_var_scale_plot - min(e_var_scale_plot);

% Keep only positive increases
delta = [0; diff(e_var_scale_plot)];
delta(delta < 0) = 0;

% Reconstruct cumulative increasing scale
e_var_scale_plot = e_var_scale_plot(1) + cumsum(delta);

%% ===========================
% FIGURE 1: FULL RAW FILE
% ===========================

set(0,'DefaultFigureWindowStyle','docked')

figRawFull = figure;

subplot(2,1,1)
plot(e_tsp, e_var_pressure_norm, 'k')
xlim([0 max(e_tsp)])
ylim(pressure_ylim)
title([replace(xy, '_', '-') ' - full raw file'], 'FontSize', font_main)
set(gca,'XTickLabel',[])
set(gca,'FontSize',font_axis)
ylabel('P_v_e_s_i_c_a_l [cmH_2O]', 'FontSize', font_axis)
grid on

subplot(2,1,2)
plot(e_tsps, e_var_scale_plot, 'k')
xlim([0 max(e_tsps)])

time_limit_idx_scale = e_tsps >= plotStart & e_tsps <= plotEnd;

% Get scale values only inside plotted window
scale_window = e_var_scale_plot(time_limit_idx_scale);
scale_window_valid = scale_window(isfinite(scale_window));

if isempty(scale_window_valid) || max(scale_window_valid) <= 0
    max_scale_window = 1;
else
    max_scale_window = max(scale_window_valid);
end

ylim([0 max_scale_window * 1.05])

set(gca,'FontSize',font_axis)
xlabel('Time [s]')
ylabel('V_v_o_i_d [mL]')
grid on

%% ===========================
% FIGURE 2: SELECTED TIME WINDOW
% ===========================

set(0,'DefaultFigureWindowStyle','normal')
set(0,'DefaultAxesFontSize',font_axis)
set(0,'DefaultTextFontSize',font_main)

fig_width  = 700;
fig_height = 500;

time_limit_idx       = e_tsp  >= plotStart & e_tsp  <= plotEnd;
time_limit_idx_scale = e_tsps >= plotStart & e_tsps <= plotEnd;

figWindow = figure('Units','pixels', ...
                   'Position',[100 100 fig_width fig_height], ...
                   'WindowStyle','normal');

subplot(2,1,1)

plot(e_tsp(time_limit_idx), e_var_pressure_norm(time_limit_idx), 'k','LineWidth', 0.75)
xlim([plotStart plotEnd])
ylim(pressure_ylim)
title([replace(xy, '_', '-') ' - ' num2str(plotStart) ' to ' num2str(plotEnd) ' s'], ...
      'FontSize', font_main)

ax = gca;
ax.Title.Units = 'normalized';
ax.Title.Position(2) = ax.Title.Position(2) + 0.06;

set(gca,'XTickLabel',[])
set(gca,'FontSize',font_axis)
ylabel('P_v_e_s_i_c_a_l [cmH_2O]', 'FontSize', font_axis)
grid off

subplot(2,1,2)

plot(e_tsps(time_limit_idx_scale), e_var_scale_plot(time_limit_idx_scale), 'k', 'LineWidth', 0.75)
xlim([plotStart plotEnd])

time_limit_idx_scale = e_tsps >= plotStart & e_tsps <= plotEnd;

% Get scale values only inside plotted window
scale_window = e_var_scale_plot(time_limit_idx_scale);
scale_window_valid = scale_window(isfinite(scale_window));

if isempty(scale_window_valid) || max(scale_window_valid) <= 0
    max_scale_window = 1;
else
    max_scale_window = max(scale_window_valid);
end

ylim([0 max_scale_window * 1.05])

set(gca,'FontSize',font_axis)
xlabel('Time [s]', 'FontSize', font_axis)
ylabel('V_v_o_i_d [mL]', 'FontSize', font_axis)
grid off

%% =========================
% SAVE FIGURES- TDMS
% =========================

current_folder = pwd;
[parent_folder, ~] = fileparts(current_folder);

fileList = dir('*.tdms');
[~, Measurement_Name] = fileparts(fileList(1).name);

figures_folder = fullfile(parent_folder,'figures');
if ~exist(figures_folder,'dir')
    mkdir(figures_folder);
end

if saveFigures
    png_file = fullfile(figures_folder, ...
        [Measurement_Name '_' num2str(plotStart) '_to_' num2str(plotEnd) 's.png']);

    set(figWindow,'PaperPositionMode','auto')
    print(figWindow, png_file, '-dpng', '-r300')

    info = imfinfo(png_file);

    fprintf('\nSaved PNG:\n');
    fprintf('File: %s\n', png_file);
    fprintf('Width: %d px\n', info.Width);
    fprintf('Height: %d px\n', info.Height);
    fprintf('DPI: %.0f x %.0f\n', info.XResolution, info.YResolution);
end

%% =========================
% FOR CSV
% =========================
% 
% current_folder = pwd;
% [parent_folder, day_folder] = fileparts(current_folder);
% [~, animal_ID] = fileparts(parent_folder);
% 
% % Use current folder name as measurement name
% [~, Measurement_Name] = fileparts(current_folder);
% 
% display_name = strrep(Measurement_Name,'_','-');
% 
% fprintf('Animal ID: %s\n', animal_ID);
% fprintf('Day folder: %s\n', day_folder);
% fprintf('Measurement: %s\n', Measurement_Name);
% 
% title([replace(Measurement_Name, '_', '-') ' - ' num2str(plotStart) ' to ' num2str(plotEnd) ' s'])
% 
% 
% figures_folder = fullfile(parent_folder,'figures');
% if ~exist(figures_folder,'dir')
%     mkdir(figures_folder);
% end
% 
% if saveFigures
%     png_file = fullfile(figures_folder, ...
%         [Measurement_Name '_' num2str(plotStart) '_to_' num2str(plotEnd) 's.png']);
% 
%     set(figWindow,'PaperPositionMode','auto')
%     print(figWindow, png_file, '-dpng', '-r300')
% 
%     info = imfinfo(png_file);
% 
%     fprintf('\nSaved PNG:\n');
%     fprintf('File: %s\n', png_file);
%     fprintf('Width: %d px\n', info.Width);
%     fprintf('Height: %d px\n', info.Height);
%     fprintf('DPI: %.0f x %.0f\n', info.XResolution, info.YResolution);
% end


%% =========================
% SAVE PRESSURE ONLY 
% ==========================

figPressure = figure('Units','pixels', ...
'Position',[150 150 700 250], ...
'WindowStyle','normal');

plot(e_tsp(time_limit_idx), e_var_pressure_norm(time_limit_idx), ...
'k','LineWidth',0.75)

xlim([plotStart plotEnd])
ylim(pressure_ylim)

title([replace(xy, '_', '-') ' - ' num2str(plotStart) ' to ' num2str(plotEnd) ' s'], ...
'FontSize', font_main-15)

ax = gca;
ax.Title.Units = 'normalized';
ax.Title.Position(2) = ax.Title.Position(2) + 0.02;

set(gca,'FontSize',font_axis)
ylabel('P_v_e_s_i_c_a_l [cmH_2O]', 'FontSize', font_axis)
xlabel('Time [s]', 'FontSize', font_axis)

grid off
box off

if saveFigures
png_file_pressure = fullfile(figures_folder, ...
[Measurement_Name '*pressure*' num2str(plotStart) '*to*' num2str(plotEnd) 's.png']);

set(figPressure,'PaperPositionMode','auto')
print(figPressure, png_file_pressure, '-dpng','-r300')

end