% ptbdb_ecg_analysis.m
% Projekt: ECG Signal aus PTBDB (Kaggle) laden und R-Peaks detektieren
% Autor: (Dein Name) - für Bewerbung Signalverarbeitung

clear; close all; clc;


% CSV-Datei laden
filename = fullfile('ptbdb_data','ptbdb_normal.csv');
data = readmatrix("ptbdb_normal.csv");

[numRows, numCols] = size(data);
fprintf('Gelesen: %d Zeilen (Beats), %d Spalten (Samples+Label)\n', numRows, numCols);

% Jede Zeile: 187 Samples (ein Herzschlag) + Label
% Wähle z. B. Beat Nr. 1
row = 1;
ecg_raw = data(row,1:end-1)';  % Spalte, ohne Label
label   = data(row,end);       % 0=normal, 1=abnormal

N = length(ecg_raw);
fs = 125;                      % Kaggle PTBDB Samplingfrequenz ~125 Hz
t = (0:N-1)/fs;

f_low = 0.5; f_high = 40; % typische ECG-Bandbreite
[b_bp, a_bp] = butter(4, [f_low f_high]/(fs/2), 'bandpass');
ecg_filt = filtfilt(b_bp, a_bp, ecg_raw);


% 1) Ableitung
deriv = gradient(ecg_filt) * fs;

% 2) Quadrat
squared = deriv .^ 2;

% 3) Moving Window Integration (150 ms)
mwi_window = round(0.15 * fs);
mwi = conv(squared, ones(mwi_window,1)/mwi_window, 'same');

% 4) Peak Detection auf MWI
thresh = mean(mwi) + 0.4*std(mwi);
minPeakDist = round(0.25 * fs); % min. Abstand 250 ms
[~, locs_mwi] = findpeaks(mwi, 'MinPeakHeight', thresh, ...
    'MinPeakDistance', minPeakDist);

% 5) Suche max im gefilterten Signal um MWI-Peaks
search_radius = round(0.06 * fs); % 60 ms
locs_r = [];
for i = 1:length(locs_mwi)
    window_start = max(1, locs_mwi(i) - search_radius);
    window_end   = min(length(ecg_filt), locs_mwi(i) + search_radius);
    [~, local_max_idx] = max(ecg_filt(window_start:window_end));
    locs_r(end+1) = window_start + local_max_idx - 1; %#ok<SAGROW>
end
locs_r = unique(locs_r);

R_times = locs_r / fs;
RR_intervals = diff(R_times);
if ~isempty(RR_intervals)
    instHR = 60 ./ RR_intervals;
    meanHR = mean(instHR);
else
    instHR = [];
    meanHR = NaN;
end


figure('Units','normalized','Position',[0.1 0.1 0.8 0.8]);

subplot(4,1,1);
plot(t, ecg_raw); grid on;
title('Rohsignal (PTBDB Beat)');
xlabel('Zeit [s]'); ylabel('Amplitude');

subplot(4,1,2);
plot(t, ecg_filt); hold on;
plot(R_times, ecg_filt(locs_r), 'ro','MarkerFaceColor','r');
grid on;
title(['Gefiltert + R-Peaks, mittl. HR = ' num2str(round(meanHR,1)) ' bpm']);
xlabel('Zeit [s]'); ylabel('Amplitude');

subplot(4,1,3);
plot(t, deriv); grid on;
title('Ableitung');
xlabel('Zeit [s]'); ylabel('d/dt');

subplot(4,1,4);
plot(t, mwi); hold on;
plot(locs_mwi/fs, mwi(locs_mwi), 'kx');
yline(thresh,'r--','Schwelle');
grid on;
title('Moving Window Integration & Schwelle');
xlabel('Zeit [s]'); ylabel('MWI');


save('ptbdb_ecg_results.mat','ecg_raw','ecg_filt','t','locs_r','R_times','RR_intervals','instHR','meanHR');
csv_data = table((locs_r'/fs)', locs_r', 'VariableNames', {'R_time_s','R_sample'});
writetable(csv_data, 'Rpeaks_ptbdb.csv');

