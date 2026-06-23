%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Pragya Nagar updated:13.05.2026
% Code to make plots for selected animals
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc; clear; close all;

%%
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
%%
% % ===========================
% %1. LOAD DATA (CSV with headers)- If file from new python software 
% %===========================
% 
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

%% ===========================
% 2. ALIGN TIME USING UNIX (same as Python)
% ===========================

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

%% ===========================
% 4. SAMPLING RATES (auto-computed)
% ===========================

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

plotStart = 500;        % change this
plotEnd   = 35000;     % change this

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

% title([replace(xy, '_', '-') ' - ' num2str(plotStart) ' to ' num2str(plotEnd) ' s'], ...
%       'FontSize', font_main)
% 
% ax = gca;
% ax.Title.Units = 'normalized';
% ax.Title.Position(2) = ax.Title.Position(2) + 0.06;


set(gca,'XTickLabel',[])
set(gca,'FontSize',font_axis)
ylabel('P_v_e_s_i_c_a_l [cmH20]', 'FontSize', font_axis)
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


sgtitle([replace(xy, '_', '-') ' - ' ...
         num2str(plotStart) ' to ' ...
         num2str(plotEnd) ' s'], ...
         'FontSize', font_main)

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

%%
% % =========================
% %FOR CSV
% %=========================
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
% % title([replace(Measurement_Name, '_', '-') ' - ' num2str(plotStart) ' to ' num2str(plotEnd) ' s'])
% % Figure-level title only
% sgtitle([replace(Measurement_Name, '_', '-') ' - ' ...
%          num2str(plotStart) ' to ' ...
%          num2str(plotEnd) ' s'], ...
%          'FontSize',font_main)
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
% 
% if saveFigures
%     % ---------- Save PDF ----------
%     % Custom PDF size (inches)
%     pdfWidth  = 12;
%     pdfHeight = 8;
% 
%     set(figWindow, 'PaperUnits', 'inches');
%     set(figWindow, 'PaperSize', [pdfWidth pdfHeight]);
%     set(figWindow, 'PaperPosition', [0 0 pdfWidth pdfHeight]);
%     set(figWindow, 'PaperPositionMode', 'manual');
% 
%     pdf_file = fullfile(figures_folder, ...
%         [Measurement_Name '_' num2str(plotStart) ...
%         '_to_' num2str(plotEnd) 's.pdf']);
% 
%     print(figWindow, pdf_file, '-dpdf', '-painters');
% 
%     fprintf('\nSaved PDF:\n');
%     fprintf('File: %s\n', pdf_file);
% 
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
ylabel('P_v_e_s_i_c_a_l [cmH20]', 'FontSize', font_axis)
xlabel('Time [s]', 'FontSize', font_axis)

grid off
box off

if saveFigures
png_file_pressure = fullfile(figures_folder, ...
[Measurement_Name '*pressure*' num2str(plotStart) '*to*' num2str(plotEnd) 's.png']);

set(figPressure,'PaperPositionMode','auto')
print(figPressure, png_file_pressure, '-dpng','-r300')

end
