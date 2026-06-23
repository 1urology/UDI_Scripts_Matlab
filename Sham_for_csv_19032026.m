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
max_time = 3200;
time_limit_idx = e_tsp <= max_time;
time_limit_idx_scale = e_tsps <= max_time;

% Plot the data up to the 3000-second timestamp
subplot 211
plot(e_tsp(time_limit_idx), e_var_pressure(time_limit_idx));
xlim([0 3200])
title(replace(xy, '_', '-'))
set(gca,'XTickLabel',[])
set(gca,'FontSize',18)
ylabel('P_v_e_s_i_c_a_l [cmH_2O]')

subplot 212
plot(e_tsps(time_limit_idx_scale), e_var_scale(time_limit_idx_scale))   %original data, 5Hz
xlim([0 3200])
set(gca,'FontSize',18)
xlabel('Time [s]')
ylabel('V_v_o_i_d [mL]')

%% Figure 1 = raw data
set(0,'DefaultFigureWindowStyle','docked')
summaryGraph = figure;

% Limit the data to the first 3000 seconds
max_time = 3200;
time_limit_idx = e_tsp <= max_time;
time_limit_idx_scale = e_tsps <= max_time;

% Normalizing pressure data
e_var_pressure_norm = e_var_pressure(time_limit_idx) - min(e_var_pressure(time_limit_idx));

% Plot the normalized pressure data up to the 3000-second timestamp
subplot(211)
plot(e_tsp(time_limit_idx), e_var_pressure_norm);
xlim([0 3200])
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
xlim([0 3200])
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
target_folder_fig = fullfile(figures_folder)
if ~exist(target_folder_fig,'dir')
    mkdir(target_folder_fig);
end


%% =========================
% SAVE FIGURE 1 (Before compliance/manual window selection)
% =========================
% if exist('summaryGraph','var') && isgraphics(summaryGraph)
%     fig1_filename = [Measurement_Name '_fig1.png'];
%     saveas(summaryGraph, fullfile(target_folder_fig, fig1_filename));
%     disp(['Figure 1 saved: ', fullfile(target_folder_fig, fig1_filename)]);
% end

fig1_filename = [Measurement_Name '_fig1.png'];
saveas(gcf, fullfile(target_folder_fig, fig1_filename));
fprintf('Figure 1 saved: %s\n', fullfile(target_folder_fig, fig1_filename));

% fig_folder = fullfile(parent_folder,'figures');
% if ~exist(fig_folder,'dir')
%     mkdir(fig_folder);
% end
% fig1_filename = [Measurement_Name '_fig1.png'];
% saveas(figure1, fullfile(fig_folder, fig1_filename));
% 
% fprintf('Figure 1 saved: %s\n', fullfile(fig_folder, fig1_filename));

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
% for ll = 1:length(z_tsp_Pmax)
%     xline(z_tsp_Pmax(ll), 'r', 'LineWidth',1.5);
% end

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

% % 5% peaks
% if exist('z_idx_NVC_5','var') && ~isempty(z_idx_NVC_5)
%     h5 = plot(z_tsp(z_idx_NVC_5), z_val_p(z_idx_NVC_5), 'o', 'Color',[1 0.5 0], 'MarkerFaceColor',[1 0.5 0], 'MarkerSize', ms);
% else, h5 = []; end
% 
% % 2% peaks
% if exist('z_idx_NVC_2','var') && ~isempty(z_idx_NVC_2)
%     h2 = plot(z_tsp(z_idx_NVC_2), z_val_p(z_idx_NVC_2), 'co', 'MarkerFaceColor','c','MarkerSize',ms);
% else, h2 = []; end
% 
% % Sub-threshold
% if exist('z_idx_subNVC','var')
%     hsub = plot(z_tsp(z_idx_subNVC), z_val_p(z_idx_subNVC), ...
%         'yo','MarkerFaceColor','y','MarkerSize',ms);
% else, hsub=[]; end

% Microcontractions
if exist('z_idx_micro','var')
    hmicro = plot(z_tsp(z_idx_micro), z_val_p(z_idx_micro), ...
        'go','MarkerFaceColor','none','LineWidth',1.5,'MarkerSize',ms+1);
else, hmicro=[]; end

%% --- Labels & legend ---
title(display_name)
xlabel('Time [s]')
ylabel('P_v_e_s_i_c_a_l [mmHg]')
set(gca,'FontSize',10)

% legend([h_raw, h_filt, h_smooth, h15, hthr, h5, h2, hsub, hmicro], ...
%        {'Raw','Filtered','Smoothed', ...
%         'NVC 15%','Threshold','NVC 5%','NVC 2%',...
%         'Sub-threshold','Micro'}, ...
%        'Location','southwest');
% %%
% % --- Collect handles and labels dynamically ---
% h_legend = [];
% legend_labels = {};
% 
% if exist('h_raw','var');    h_legend(end+1) = h_raw;    legend_labels{end+1} = 'Raw'; end
% if exist('h_filt','var');   h_legend(end+1) = h_filt;   legend_labels{end+1} = 'Filtered'; end
% if exist('h_smooth','var'); h_legend(end+1) = h_smooth; legend_labels{end+1} = 'Smoothed'; end
% 
% if exist('h15','var') && ~isempty(h15);       h_legend(end+1) = h15;       legend_labels{end+1} = 'NVC 15%'; end
% if exist('hthr','var') && ~isempty(hthr);     h_legend(end+1) = hthr;     legend_labels{end+1} = 'Threshold'; end
% if exist('h5','var') && ~isempty(h5);         h_legend(end+1) = h5;         legend_labels{end+1} = 'NVC 5%'; end
% if exist('h2','var') && ~isempty(h2);         h_legend(end+1) = h2;         legend_labels{end+1} = 'NVC 2%'; end
% if exist('hsub','var') && ~isempty(hsub);     h_legend(end+1) = hsub;     legend_labels{end+1} = 'Sub-threshold'; end
% if exist('hmicro','var') && ~isempty(hmicro); h_legend(end+1) = hmicro; legend_labels{end+1} = 'Micro-peaks'; end
% 
% % --- Apply legend ---
% legend(h_legend, legend_labels, 'Location', 'southwest');
% 

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
% 
% if exist('h5','var') && ~isempty(h5);         h_legend(end+1) = h5;         else h_legend(end+1) = plot(nan,nan,'o','Color',[1 0.5 0],'MarkerFaceColor',[1 0.5 0],'MarkerSize',ms); end
% legend_labels{end+1} = 'NVC 5%';
% 
% if exist('h2','var') && ~isempty(h2);         h_legend(end+1) = h2;         else h_legend(end+1) = plot(nan,nan,'co','MarkerFaceColor','c','MarkerSize',ms); end
% legend_labels{end+1} = 'NVC 2%';
% 
% if exist('hsub','var') && ~isempty(hsub);     h_legend(end+1) = hsub;     else h_legend(end+1) = plot(nan,nan,'yo','MarkerFaceColor','y','MarkerSize',ms); end
% legend_labels{end+1} = 'Sub-threshold';

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

