%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 2025.4.8 Working all .sc files inside a folder

clc;
clear;
close all;

% Specify the folder containing the .sc files
folderPath = "H:\20250325\LSCI_Processing\Videos\ROI 2\20\20 V2\00001";

% Get all .sc files in the folder
files = dir(fullfile(folderPath, '*.sc'));

% Check if there are any .sc files in the folder
if isempty(files)
    error('No .sc files found in the specified folder.');
end

% Create a figure for display
figure;
colormap(flipud(jet)); % Use jet colormap for better flow visualization

% Set the display range (adjust these values based on your data)
displayRange = [0.00 0.2]; % Typical range for speckle contrast

% Create axes for main image
ax1 = axes('Position', [0.1 0.1 0.7 0.8]); % Leave space for colorbar

% Loop through each .sc file in the folder
for fileIdx = 1:length(files)
    % Get current file path
    filePath = fullfile(folderPath, files(fileIdx).name);
    
    % Read all frames from the current .sc file
    sc_data = read_subimage(dir(filePath), -1, -1, -1); % -1 means read all width, height, and frames
    
    % Get the number of frames
    numFrames = size(sc_data, 3);
    
    % Infinite loop for continuous playback of current file (optional)
    % while true
    
    % Loop through each frame in the current .sc file
    for frame = 1:numFrames
        % Display the current frame
        imagesc(ax1, sc_data(:, :, frame)', displayRange);
        axis(ax1, 'image'); % Maintain aspect ratio
        title(ax1, sprintf('File: %s | Frame %d of %d', files(fileIdx).name, frame, numFrames), ...
            'Interpreter', 'none'); % Display file name and frame info
        
        % Create and format colorbar
        h = colorbar(ax1, 'Location', 'eastoutside');
        h.Label.String = 'Speckle Contrast (K)';
        h.Label.FontSize = 12;
        h.Label.FontWeight = 'bold';
        h.Ticks = linspace(displayRange(1), displayRange(2), 10); % 5 evenly spaced ticks
        h.TickLabels = compose('%.5f', h.Ticks); % Format tick labels
        
        drawnow; % Update the display
        
        % Add a small pause between frames (adjust as needed)
        pause(0.0000001);
    end
    
    % End of infinite loop for current file (optional)
    % end
    
end

disp('Finished displaying all .sc files.');


%%

% Load all .sc files into a single variable all_sc

clc;
clear;
close all;

folderPath = 'D:\20250325\LSCI_Processing\Videos\ROI\20';
files = dir(fullfile(folderPath, 'patient_019*.sc'));

% Pre-allocate cell array to store results
all_sc = cell(1, length(files));

% Process each file separately
for i = 1:length(files)
    all_sc{i} = read_subimage(files(i)); % Read one file at a time
end


%%

% Load the .timing file for all .sc files in recording 20 into a single
% variable timevector

% timevector is the x axis

clc;
clear;
close all;

timevector = loadSpeckleTiming("H:\20250325\20250325_LSCI\20\patient_019_sc.timing")
length(timevector)


%%
clc;
clear;
close all;

a = load("H:\20250325\LSCI_Processing\Videos\ROI 2\20\20\ROI_Data\patient_019.00001_ROIs.mat") 
b = a.roiData


%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 2025.4.16 3.00pm working

% Code should save all ROI's and also save the averaged frame where the
% ROI's where applied

% Only calculate on specified frames on the .sc file

% need to change in 3 places



clc;
clear;
close all;

% Specify the folder containing the .sc files
folderPath = "H:\20250325\LSCI_Processing\Videos\ROI 2\20\20 V2\00006";

% Get the timing file (using the first .timing file found in the folder)
timingFile = dir(fullfile(folderPath, '*.timing'));
if isempty(timingFile)
    error('No .timing file found in the specified folder.');
end

% Load timing data
try
    timingFilePath = fullfile(folderPath, timingFile(1).name);
    timeValues = loadSpeckleTiming(timingFilePath);
    disp(['Successfully loaded time values from timing file: ' timingFile(1).name]);
    disp(['Number of time values loaded: ' num2str(length(timeValues))]);
catch
    error('Failed to read timing file. Please ensure a valid .timing file exists in the folder.');
end

% Get all .sc files in the folder
files = dir(fullfile(folderPath, '*.sc'));

% Check if there are any .sc files in the folder
if isempty(files)
    error('No .sc files found in the specified folder.');
end

% Create a figure for display with professional appearance
figure('Color', 'w', 'Position', [100 100 900 600]);
colormap(flipud(jet)); % Use jet colormap for better flow visualization

% Set the display range (adjust these values based on your data)
displayRange = [0.01 0.2]; % Typical range for speckle contrast

% Create axes for main image with better formatting
ax1 = axes('Position', [0.1 0.1 0.7 0.8], ...
           'FontSize', 20, ...
           'FontWeight', 'bold', ...
           'LineWidth', 1.5, ...
           'Box', 'on');
grid(ax1, 'on');

% Initialize variables
allResults = struct(); % Structure to store all results

% Create a subfolder for saving ROI data if it doesn't exist
roiSaveFolder = fullfile(folderPath, 'ROI_Data');
if ~exist(roiSaveFolder, 'dir')
    mkdir(roiSaveFolder);
end

% Frame range to process (1-49 total)
startFrame = 1;
endFrame = 5;

% Loop through each .sc file in the folder
for fileIdx = 1:length(files)
    % Get current file path and extract file number
    filePath = fullfile(folderPath, files(fileIdx).name);
    
    % Extract file number from filename
    [~, fileName, ~] = fileparts(files(fileIdx).name);
    fileNumberStr = regexp(fileName, '(\d{5})$', 'match');
    
    if isempty(fileNumberStr)
        warning('Could not extract file number from %s. Using file index instead.', files(fileIdx).name);
        fileNumber = fileIdx - 1;
    else
        fileNumber = str2double(fileNumberStr{1});
    end
    
    % Read all frames from the current .sc file
    sc_data = read_subimage(dir(filePath), -1, -1, -1);
    
    % Select only frames 30 to 45
    if size(sc_data,3) < endFrame
        endFrame = size(sc_data,3);
        warning('File has only %d frames. Processing frames %d to %d instead.', size(sc_data,3), startFrame, endFrame);
    end
    sc_data = sc_data(:,:,startFrame:endFrame);
    numFrames = size(sc_data, 3);
    
    % Calculate timing indices for these frames
    originalNumFrames = endFrame - startFrame + 1;
    timingStartIdx = 1 + (fileNumber * originalNumFrames) + (startFrame - 1);
    timingEndIdx = timingStartIdx + (endFrame - startFrame);
    
    % Verify sufficient timing data exists
    if timingEndIdx > length(timeValues)
        warning('Not enough timing values for %s. Need %d values starting from index %d, but only %d available.', ...
            files(fileIdx).name, numFrames, timingStartIdx, length(timeValues) - timingStartIdx + 1);
        
        if timingStartIdx <= length(timeValues)
            availableValues = length(timeValues) - timingStartIdx + 1;
            fileTimeValues = [timeValues(timingStartIdx:end); NaN(numFrames-availableValues, 1)];
        else
            fileTimeValues = NaN(numFrames, 1);
        end
    else
        fileTimeValues = timeValues(timingStartIdx:timingEndIdx);
    end
    
    % Calculate average frame for ROI visualization
    avgFrame = mean(sc_data, 3);
    avgFrameDisplay = avgFrame';
    
    % Display the average frame
    hImage = imagesc(ax1, avgFrameDisplay, displayRange);
    axis(ax1, 'image');
    title(ax1, sprintf('File: %s - Draw ROIs (Frames %d-%d)', files(fileIdx).name, startFrame, endFrame), ...
        'Interpreter', 'none', 'FontSize', 20, 'FontWeight', 'bold');
    
    % Create colorbar
    h = colorbar(ax1, 'Location', 'eastoutside');
    h.Label.String = 'Speckle Contrast (K)';
    h.Label.FontSize = 20;
    h.Label.FontWeight = 'bold';
    h.Ticks = linspace(displayRange(1), displayRange(2), 5);
    h.TickLabels = compose('%.2f', h.Ticks);
    h.FontSize = 20; 
    h.FontWeight = 'bold';
    h.LineWidth = 1.5;

    ax1.XTick = [];
    ax1.YTick = [];
    ax1.FontSize = 20;
    ax1.FontWeight = 'bold';
    
    % Initialize ROI variables
    roiCount = 0;
    roiMasks = {};
    roiPositions = {};
    roiObjects = {};
    roiColors = lines(7);
    
    % Allow user to draw ROIs
    while true
        roi = drawfreehand(ax1, 'Color', roiColors(mod(roiCount,7)+1,:), ...
                          'LineWidth', 3, 'FaceAlpha', 0.3, 'Closed', true);
        
        if isempty(roi.Position)
            delete(roi);
            break;
        end
        
        wait(roi);
        
        roiCount = roiCount + 1;
        roiMasks{roiCount} = createMask(roi);
        roiPositions{roiCount} = roi.Position;
        roiObjects{roiCount} = roi;
        roi.LineWidth = 5;
        roi.FaceAlpha = 0.2;
        
        choice = questdlg('Add another ROI?', 'ROI Selection', 'Yes','No','Yes');
        if strcmp(choice, 'No')
            break;
        end
    end
    
    % Save ROI data
    if roiCount > 0
        [~, baseFilename, ~] = fileparts(files(fileIdx).name);
        roiFilename = fullfile(roiSaveFolder, [baseFilename '_ROIs.mat']);
        
        roiData = struct();
        roiData.roiMasks = roiMasks;
        roiData.roiPositions = roiPositions;
        roiData.roiColors = roiColors(1:roiCount,:);
        roiData.avgFrame = avgFrame;
        roiData.displayRange = displayRange;
        
        save(roiFilename, 'roiData');
        disp(['Saved ROI data to: ' roiFilename]);
        
        % Save ROI visualization
        roiImageFilename = fullfile(roiSaveFolder, [baseFilename '_ROIs.png']);
        fig = figure('Visible', 'off', 'Color', 'w', 'Position', [100 100 900 600]);
        ax = axes('Parent', fig);
        imagesc(ax, avgFrameDisplay, displayRange);
        axis(ax, 'image');
        colormap(flipud(jet));
        colorbar;
        hold(ax, 'on');
        for r = 1:roiCount
            plot(ax, roiPositions{r}(:,1), roiPositions{r}(:,2), ...
                 'Color', roiColors(mod(r-1,7)+1,:), 'LineWidth', 3);
        end
        hold(ax, 'off');
        exportgraphics(fig, roiImageFilename, 'Resolution', 300);
        close(fig);
        disp(['Saved ROI visualization to: ' roiImageFilename]);
    end
    
    % Process frames
    K_values = zeros(roiCount, numFrames);
    invK_squared = zeros(roiCount, numFrames);
    
    for frame = 1:numFrames
        hImage.CData = sc_data(:, :, frame)';
        title(ax1, sprintf('File: %s - Frame %d/%d (Original %d)', files(fileIdx).name, frame, numFrames, frame+startFrame-1), ...
              'Interpreter', 'none', 'FontSize', 14, 'FontWeight', 'bold');
        
        for r = 1:roiCount
            roiObjects{r}.Visible = 'on';
        end
        
        currentFrame = sc_data(:, :, frame);
        
        for r = 1:roiCount
            mask = roiMasks{r}';
            roi_pixels = currentFrame(mask);
            K_values(r, frame) = mean(roi_pixels, 'omitnan');
            invK_squared(r, frame) = 1/(K_values(r, frame)^2);
        end
        
        drawnow;
        pause(0.01);
    end
    
    % Store and save results
    allResults(fileIdx).filename = files(fileIdx).name;
    allResults(fileIdx).K_values = K_values;
    allResults(fileIdx).invK_squared = invK_squared;
    allResults(fileIdx).roiCount = roiCount;
    allResults(fileIdx).timeValues = fileTimeValues;
    
    resultsFilename = fullfile(roiSaveFolder, [baseFilename '_results.mat']);
    save(resultsFilename, 'K_values', 'invK_squared', 'fileTimeValues');
    disp(['Saved analysis results to: ' resultsFilename]);
    
    % Create flow plot
    fig = figure('Color', 'w', 'Position', [100 100 1000 600]);
    ax = axes('Parent', fig, 'FontSize', 20, 'FontWeight', 'bold', 'LineWidth', 1.5, 'Box', 'on');
    hold(ax, 'on');
    grid(ax, 'on');
    
    for r = 1:roiCount
        plot(ax, fileTimeValues, invK_squared(r,:), 'LineWidth', 5.5, 'Color', roiColors(mod(r-1,7)+1,:));
    end
    
    xlabel(ax, 'Time (s)', 'FontSize', 20, 'FontWeight', 'bold');
    ylabel(ax, 'Blood Flow Units (1/K²)', 'FontSize', 20, 'FontWeight', 'bold');
    title(ax, sprintf('Blood flow (1/K²) - %s (Frames %d-%d)', files(fileIdx).name, startFrame, endFrame), ...
          'Interpreter', 'none', 'FontSize', 20, 'FontWeight', 'bold');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    roiLabels = arrayfun(@(x) sprintf('ROI%d', x+2), 1:roiCount, 'UniformOutput', false);
    legend(ax, roiLabels, 'Location', 'bestoutside', 'FontSize', 20, 'Box', 'on');
    
    annotation(fig, 'textbox', [0.65 0.01 0.3 0.05], ...
         'String', sprintf('File #%05d\nFrames %d-%d', fileNumber, startFrame, endFrame), ...
         'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', ...
         'FontSize', 14, 'FontWeight', 'bold', 'EdgeColor', 'none');
    
    xlim(ax, [min(fileTimeValues) max(fileTimeValues)]);
    
    plotFilename_png = fullfile(roiSaveFolder, [baseFilename '_flow_plot.png']);
    plotFilename_fig = fullfile(roiSaveFolder, [baseFilename '_flow_plot.fig']);
    exportgraphics(fig, plotFilename_png, 'Resolution', 300);
    savefig(fig, plotFilename_fig);
    close(fig);
    disp(['Saved flow plot to: ' plotFilename_png ' and ' plotFilename_fig]);
end

% Save all results
allResultsFilename = fullfile(roiSaveFolder, 'all_results.mat');
save(allResultsFilename, 'allResults');
disp(['Saved complete analysis results to: ' allResultsFilename]);

disp('Analysis complete for all files.');
msgbox('Analysis completed successfully!', 'LSCI Processing', 'help');



%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Print the average value of each line of .fig file

clc;
clear;
close all;

% Define the folder path
folderPath = "H:\20250325\LSCI_Processing\Videos\ROI 2\Combined graphs\2025.4.15";

% List of your figure files
figFiles = {
    'updated_14_3.fig'
    'updated_20_1.fig'
    'updated_20_6.fig'
    'updated_34_1.fig'
    'updated_47_3.fig'
};

% Process each figure file
for i = 1:length(figFiles)
    % Load the figure
    fig = openfig(fullfile(folderPath, figFiles{i}));
    
    % Get all axes in the figure
    ax = findobj(fig, 'Type', 'axes');
    
    fprintf('\nResults for %s:\n', figFiles{i});
    
    % Process each axes (in case there are multiple subplots)
    for j = 1:length(ax)
        % Get all lines in the current axes
        lines = findobj(ax(j), 'Type', 'line');
        
        % Calculate average and get X data for each line
        for k = 1:length(lines)
            yData = get(lines(k), 'YData');
            xData = get(lines(k), 'XData');
            lineAvg = mean(yData);
            
            % Display the results
            fprintf('  Line %d in axes %d:\n', k, j);
            fprintf('    Average Y value = %.4f\n', lineAvg);
            fprintf('    X values = [%s]\n', sprintf('%.4f ', xData));
        end
    end
    
    % Close the figure
    close(fig);
end


%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Print average value with legend name title

clc;
clear;
close all;

% Define the folder path
folderPath = "H:\20250325\LSCI_Processing\Videos\ROI 2\Combined graphs\2025.4.18";

% Get list of all .fig files in the folder
figFiles = dir(fullfile(folderPath, '*.fig'));

% Check if any .fig files were found
if isempty(figFiles)
    error('No .fig files found in the specified folder: %s', folderPath);
end

% Process each figure file
for i = 1:length(figFiles)
    % Load the figure
    fig = openfig(fullfile(folderPath, figFiles(i).name), 'invisible');
    
    % Get all axes in the figure
    ax = findobj(fig, 'Type', 'axes');
    
    fprintf('\nResults for %s:\n', figFiles(i).name);
    
    % Process each axes (in case there are multiple subplots)
    for j = 1:length(ax)
        % Get all lines in the current axes
        lines = findobj(ax(j), 'Type', 'line');
        
        % Get legend entries if they exist
        [leg, legObj] = legend(ax(j));
        legendEntries = {};
        if ~isempty(legObj)
            legendEntries = get(legObj, 'String');
        end
        
        % Calculate average for each line
        for k = 1:length(lines)
            yData = get(lines(k), 'YData');
            lineAvg = mean(yData);
            
            % Get the legend entry for this line if available
            lineLegend = '';
            if ~isempty(legendEntries) && k <= length(legendEntries)
                lineLegend = legendEntries{k};
            else
                lineLegend = get(lines(k), 'DisplayName');
                if isempty(lineLegend)
                    lineLegend = 'Untitled';
                end
            end
            
            % Display the results with legend as title
            fprintf('  %s:\n', lineLegend);
            fprintf('    Average value = %.4f\n', lineAvg);
        end
    end
    
    % Close the figure
    close(fig);
end

%%

















%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 2025.4.16 final correct

clc;
clear;
close all;

% Create a new figure with professional settings
figure('Name', 'Combined Data Plots', 'Position', [100 100 1400 900]);
hold on;
grid on;
set(gca, 'LineWidth', 2); % Bold axes

% Set bold fonts for all text
set(gca, 'FontSize', 20, 'FontWeight', 'bold');
set(get(gca, 'XLabel'), 'FontSize', 20, 'FontWeight', 'bold');
set(get(gca, 'YLabel'), 'FontSize', 20, 'FontWeight', 'bold');
set(get(gca, 'Title'), 'FontSize', 20, 'FontWeight', 'bold');

% Define line widths and styles
line_width = 3; % Very bold lines

% Define datetime values for each montage (April 15, 2025)
t14_3 = datetime(2025, 4, 15, 8, 26, 23); % Montage 14: 08:26:23
t20 = datetime(2025, 4, 15, 8, 41, 19);   % Montage 20: 08:41:49 (both datasets)
t34_1 = datetime(2025, 4, 15, 9, 13, 56); % Montage 34: 09:13:56
t47_3 = datetime(2025, 4, 15, 9, 51, 56); % Montage 47: 09:51:56

% Data from updated_14_3.fig (Montage 14)
y14_3_1 = 72.6433;
y14_3_2 = 179.5383;
plot(t14_3, y14_3_1, 'bo', 'MarkerSize', 12, 'LineWidth', line_width, 'DisplayName', 'Montage 14 - ROI2 (08:26:23)');
plot(t14_3, y14_3_2, 'bo', 'MarkerSize', 12, 'LineWidth', line_width, 'DisplayName', 'Montage 14 - ROI1 (08:26:23)', 'MarkerFaceColor', 'b');
h_invisible1 = plot(NaN, NaN, 'LineStyle', 'none', 'Marker', 'none', 'DisplayName', 'Low vs high perfusion region in cortex');
h_invisible1 = plot(NaN, NaN, 'LineStyle', 'none', 'Marker', 'none', 'DisplayName', '');

% Data from updated_20_1.fig (Montage 20)
y20_1_1 = 259.6669;
y20_1_2 = 269.6594;
plot(t20, y20_1_1, 'ro', 'MarkerSize', 12, 'LineWidth', line_width, 'DisplayName', 'Montage 20 - ROI4 (08:41:19)');
plot(t20, y20_1_2, 'ro', 'MarkerSize', 12, 'LineWidth', line_width, 'DisplayName', 'Montage 20 - ROI3 (08:41:19)', 'MarkerFaceColor', 'r');
h_invisible2 = plot(NaN, NaN, 'LineStyle', 'none', 'Marker', 'none', 'DisplayName', 'Before cauterization of tissues in 2 ROIs');
h_invisible1 = plot(NaN, NaN, 'LineStyle', 'none', 'Marker', 'none', 'DisplayName', '');

% Data from updated_20_6.fig (Montage 20)
y20_6_1 = 109.4437;
y20_6_2 = 83.0122;
plot(t20, y20_6_1, 'go', 'MarkerSize', 12, 'LineWidth', line_width, 'DisplayName', 'Montage 20 - ROI4 (08:41:49)');
plot(t20, y20_6_2, 'go', 'MarkerSize', 12, 'LineWidth', line_width, 'DisplayName', 'Montage 20 - ROI3 (08:41:49)', 'MarkerFaceColor', 'g');
h_invisible3 = plot(NaN, NaN, 'LineStyle', 'none', 'Marker', 'none', 'DisplayName', 'After cauterization of tissues in the above 2 ROIs');
h_invisible1 = plot(NaN, NaN, 'LineStyle', 'none', 'Marker', 'none', 'DisplayName', '');

% Data from updated_34_1.fig (Montage 34)
y34_1_1 = 36.4183;
y34_1_2 = 57.4910;
y34_1_3 = 70.3821;
y34_1_4 = 105.8227;
plot(t34_1, y34_1_1, 'mo', 'MarkerSize', 12, 'LineWidth', line_width, 'DisplayName', 'Montage 34 - ROI8 (09:13:56)');
plot(t34_1, y34_1_2, 'mo', 'MarkerSize', 12, 'LineWidth', line_width, 'DisplayName', 'Montage 34 - ROI7 (09:13:56)', 'MarkerFaceColor', 'm');
plot(t34_1, y34_1_3, 'mo', 'MarkerSize', 12, 'LineWidth', line_width, 'DisplayName', 'Montage 34 - ROI6 (09:13:56)', 'MarkerFaceColor', [0.8 0 0.8]);
plot(t34_1, y34_1_4, 'mo', 'MarkerSize', 12, 'LineWidth', line_width, 'DisplayName', 'Montage 34 - ROI5 (09:13:56)', 'MarkerFaceColor', [0.6 0 0.6]);
h_invisible4 = plot(NaN, NaN, 'LineStyle', 'none', 'Marker', 'none', 'DisplayName', 'Very low, low, medium and high blood flow regions');
h_invisible1 = plot(NaN, NaN, 'LineStyle', 'none', 'Marker', 'none', 'DisplayName', ' in the cortex');
h_invisible1 = plot(NaN, NaN, 'LineStyle', 'none', 'Marker', 'none', 'DisplayName', '');

% Data from updated_47_3.fig (Montage 47)
y47_3_1 = 362.5685;
y47_3_2 = 153.1903;
y47_3_3 = 43.7648;
plot(t47_3, y47_3_1, 'co', 'MarkerSize', 12, 'LineWidth', line_width, 'DisplayName', 'Montage 47 - ROI9 (09:51:56)');
plot(t47_3, y47_3_2, 'co', 'MarkerSize', 12, 'LineWidth', line_width, 'DisplayName', 'Montage 47 - ROI10 (09:51:56)', 'MarkerFaceColor', 'c');
plot(t47_3, y47_3_3, 'co', 'MarkerSize', 12, 'LineWidth', line_width, 'DisplayName', 'Montage 47 - ROI11 (09:51:56)', 'MarkerFaceColor', [0 0.8 0.8]);
h_invisible5 = plot(NaN, NaN, 'LineStyle', 'none', 'Marker', 'none', 'DisplayName', 'High, medium and low blood flow regions');
h_invisible1 = plot(NaN, NaN, 'LineStyle', 'none', 'Marker', 'none', 'DisplayName', 'where low blood flow region is resected');
h_invisible1 = plot(NaN, NaN, 'LineStyle', 'none', 'Marker', 'none', 'DisplayName', 'completed by Dr Graffeo');

% Customize the plot
xlabel('Time (HH:MM:SS)', 'FontWeight', 'bold');
ylabel('Blood Flow Units (1/K^2)', 'FontWeight', 'bold');
title('Combined Data from All Montages', 'FontWeight', 'bold');

% Create a legend
legend('Location', 'eastoutside', 'FontSize', 20, 'FontWeight', 'bold');
legend boxoff;

% Adjust x-axis to show all datetime values with padding
all_times = [t14_3, t20, t34_1, t47_3];
x_padding = minutes(5); % 5-minute padding for visibility
xlim([min(all_times) - x_padding, max(all_times) + x_padding]);

% Format x-axis to show time only (HH:MM:SS)
set(gca, 'XTick', all_times); % Set ticks at exact montage times
datetick('x', 'HH:MM:SS', 'keepticks', 'keeplimits');

% Set y-axis limits
ylim([0 400]); % Adjusted to accommodate the higher values

% Set grid to be more visible
grid minor;
set(gca, 'GridAlpha', 0.4, 'MinorGridAlpha', 0.2);

% Make the box around the plot bolder
box on;
set(gca, 'BoxStyle', 'full', 'LineWidth', 2);

hold off;



%%




clc;
clear;
close all;

% Create a new figure with professional settings
figure('Name', 'Combined Data Plots', 'Position', [100 100 1400 900]);
hold on;
grid on;
set(gca, 'LineWidth', 2); % Bold axes

% Set bold fonts for all text
set(gca, 'FontSize', 20, 'FontWeight', 'bold');
set(get(gca, 'XLabel'), 'FontSize', 20, 'FontWeight', 'bold');
set(get(gca, 'YLabel'), 'FontSize', 20, 'FontWeight', 'bold');
set(get(gca, 'Title'), 'FontSize', 20, 'FontWeight', 'bold');

% Define line widths and styles
line_width = 3; % Very bold lines

% Define datetime values for each montage (April 15, 2025)
t14_3 = datetime(2025, 4, 15, 8, 26, 23); % Montage 14: 08:26:23
t20 = datetime(2025, 4, 15, 8, 41, 19);   % Montage 20: 08:41:49 (both datasets)
t34_1 = datetime(2025, 4, 15, 9, 13, 56); % Montage 34: 09:13:56
t47_3 = datetime(2025, 4, 15, 9, 51, 56); % Montage 47: 09:51:56

% Data from updated_14_3.fig (Montage 14)
y14_3_1 = 72.6433;
y14_3_2 = 179.5383;
plot(t14_3, y14_3_1, 'bo', 'MarkerSize', 12, 'LineWidth', line_width, 'DisplayName', 'Montage 14 - ROI2 (08:26:23)');
plot(t14_3, y14_3_2, 'bo', 'MarkerSize', 12, 'LineWidth', line_width, 'DisplayName', 'Montage 14 - ROI1 (08:26:23)', 'MarkerFaceColor', 'b');
h_invisible1 = plot(NaN, NaN, 'LineStyle', 'none', 'Marker', 'none', 'DisplayName', 'Low vs high perfusion region in cortex');
h_invisible1 = plot(NaN, NaN, 'LineStyle', 'none', 'Marker', 'none', 'DisplayName', '');

% Data from updated_20_1.fig (Montage 20)
y20_1_1 = 176.9047;  % Updated value
y20_1_2 = 265.8664;  % Updated value
plot(t20, y20_1_1, 'ro', 'MarkerSize', 12, 'LineWidth', line_width, 'DisplayName', 'Montage 20 - ROI4 (08:41:19)');
plot(t20, y20_1_2, 'ro', 'MarkerSize', 12, 'LineWidth', line_width, 'DisplayName', 'Montage 20 - ROI3 (08:41:19)', 'MarkerFaceColor', 'r');
h_invisible2 = plot(NaN, NaN, 'LineStyle', 'none', 'Marker', 'none', 'DisplayName', 'Before cauterization of tissues in 2 ROIs');
h_invisible1 = plot(NaN, NaN, 'LineStyle', 'none', 'Marker', 'none', 'DisplayName', '');

% Data from updated_20_6.fig (Montage 20)
y20_6_1 = 152.0437;  % Updated value
y20_6_2 = 72.1486;   % Updated value
plot(t20, y20_6_1, 'go', 'MarkerSize', 12, 'LineWidth', line_width, 'DisplayName', 'Montage 20 - ROI4 (08:41:49)');
plot(t20, y20_6_2, 'go', 'MarkerSize', 12, 'LineWidth', line_width, 'DisplayName', 'Montage 20 - ROI3 (08:41:49)', 'MarkerFaceColor', 'g');
h_invisible3 = plot(NaN, NaN, 'LineStyle', 'none', 'Marker', 'none', 'DisplayName', 'After cauterization of tissues in the above 2 ROIs');
h_invisible1 = plot(NaN, NaN, 'LineStyle', 'none', 'Marker', 'none', 'DisplayName', '');

% Data from updated_34_1.fig (Montage 34)
y34_1_1 = 36.4183;
y34_1_2 = 57.4910;
y34_1_3 = 70.3821;
y34_1_4 = 105.8227;
plot(t34_1, y34_1_1, 'mo', 'MarkerSize', 12, 'LineWidth', line_width, 'DisplayName', 'Montage 34 - ROI8 (09:13:56)');
plot(t34_1, y34_1_2, 'mo', 'MarkerSize', 12, 'LineWidth', line_width, 'DisplayName', 'Montage 34 - ROI7 (09:13:56)', 'MarkerFaceColor', 'm');
plot(t34_1, y34_1_3, 'mo', 'MarkerSize', 12, 'LineWidth', line_width, 'DisplayName', 'Montage 34 - ROI6 (09:13:56)', 'MarkerFaceColor', [0.8 0 0.8]);
plot(t34_1, y34_1_4, 'mo', 'MarkerSize', 12, 'LineWidth', line_width, 'DisplayName', 'Montage 34 - ROI5 (09:13:56)', 'MarkerFaceColor', [0.6 0 0.6]);
h_invisible4 = plot(NaN, NaN, 'LineStyle', 'none', 'Marker', 'none', 'DisplayName', 'Very low, low, medium and high blood flow regions');
h_invisible1 = plot(NaN, NaN, 'LineStyle', 'none', 'Marker', 'none', 'DisplayName', ' in the cortex');
h_invisible1 = plot(NaN, NaN, 'LineStyle', 'none', 'Marker', 'none', 'DisplayName', '');

% Data from updated_47_3.fig (Montage 47)
y47_3_1 = 362.5685;
y47_3_2 = 153.1903;
y47_3_3 = 43.7648;
plot(t47_3, y47_3_1, 'co', 'MarkerSize', 12, 'LineWidth', line_width, 'DisplayName', 'Montage 47 - ROI9 (09:51:56)');
plot(t47_3, y47_3_2, 'co', 'MarkerSize', 12, 'LineWidth', line_width, 'DisplayName', 'Montage 47 - ROI10 (09:51:56)', 'MarkerFaceColor', 'c');
plot(t47_3, y47_3_3, 'co', 'MarkerSize', 12, 'LineWidth', line_width, 'DisplayName', 'Montage 47 - ROI11 (09:51:56)', 'MarkerFaceColor', [0 0.8 0.8]);
h_invisible5 = plot(NaN, NaN, 'LineStyle', 'none', 'Marker', 'none', 'DisplayName', 'High, medium and low blood flow regions');
h_invisible1 = plot(NaN, NaN, 'LineStyle', 'none', 'Marker', 'none', 'DisplayName', 'where low blood flow region is resected');
h_invisible1 = plot(NaN, NaN, 'LineStyle', 'none', 'Marker', 'none', 'DisplayName', 'completed by Dr Graffeo');

% Customize the plot
xlabel('Time (HH:MM:SS)', 'FontWeight', 'bold');
ylabel('Blood Flow Units (1/K^2)', 'FontWeight', 'bold');
title('Combined Data from All Montages', 'FontWeight', 'bold');

% Create a legend
legend('Location', 'eastoutside', 'FontSize', 20, 'FontWeight', 'bold');
legend boxoff;

% Adjust x-axis to show all datetime values with padding
all_times = [t14_3, t20, t34_1, t47_3];
x_padding = minutes(5); % 5-minute padding for visibility
xlim([min(all_times) - x_padding, max(all_times) + x_padding]);

% Format x-axis to show time only (HH:MM:SS)
set(gca, 'XTick', all_times); % Set ticks at exact montage times
datetick('x', 'HH:MM:SS', 'keepticks', 'keeplimits');

% Set y-axis limits
ylim([0 400]); % Adjusted to accommodate the higher values

% Set grid to be more visible
grid minor;
set(gca, 'GridAlpha', 0.4, 'MinorGridAlpha', 0.2);

% Make the box around the plot bolder
box on;
set(gca, 'BoxStyle', 'full', 'LineWidth', 2);

hold off;