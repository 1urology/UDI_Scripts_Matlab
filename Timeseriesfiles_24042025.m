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
