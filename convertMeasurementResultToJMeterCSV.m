function convertMeasurementResultToJMeterCSV(result, filename)
%CONVERTMEASUREMENTRESULTTOJMETERCSV Convert and save MeasurementResult to a JMeter CSV file.
% CONVERTMEASUREMENTRESULTTOJMETERCSV(RESULT, FILENAME) converts and writes
% the MeasurementResult RESULT to a comma-delimited text CSV file FILENAME
% in JMeter output format.
%
% Copyright 2018 The MathWorks, Inc.

import matlab.unittest.internal.newFileResolver;

% Validate inputs
outputFile = newFileResolver(filename, '.csv');

samplesTable = vertcat(result.Samples);
nrows = size(samplesTable, 1);

% Trim the table and change variable names to comply with JMeter CSV format
measuredVariableName = result.MeasuredVariableName;
samplesTable = samplesTable(:, {'Timestamp', measuredVariableName, 'Name'});
samplesTable.Properties.VariableNames{'Name'} = 'label';
samplesTable.Properties.VariableNames{measuredVariableName} = 'elapsed';
samplesTable.Properties.VariableNames{'Timestamp'} = 'timeStamp';

% Replace angle brackets in the label
samplesTable.label = strrep(string(samplesTable.label),'<','&lt');
samplesTable.label = strrep(string(samplesTable.label),'>','&gt');

% Convert timestamp and measuredValue to ms format, and fill NaN/NaT
samplesTable.timeStamp = fillmissing(samplesTable.timeStamp,'previous');
samplesTable.timeStamp = posixtime(samplesTable.timeStamp)*1000;
samplesTable.elapsed = fillmissing(samplesTable.elapsed,'constant',0);
samplesTable.elapsed = floor(samplesTable.elapsed*1000);

% Generate additional columns required in JMeter CSV format
responseCode = zeros(nrows, 1);
responseMessage = strings(nrows, 1);
threadName = strings(nrows, 1);
dataType = strings(nrows, 1);
success = convertValidToStr(result);
failureMessage = strings(nrows, 1);
bytes = zeros(nrows, 1);
sentBytes = zeros(nrows, 1);
grpThreads = ones(nrows, 1);
allThreads = ones(nrows, 1);
latency = zeros(nrows, 1);
idleTime = zeros(nrows, 1);
connect = zeros(nrows, 1);

auxTable = table(responseCode, responseMessage, threadName, dataType, ...
    success, failureMessage, bytes, sentBytes, grpThreads, allThreads, ...
    latency, idleTime, connect);

JMeterTable = [samplesTable, auxTable];

writetable(JMeterTable, outputFile);
end

function out = convertValidToStr(result)
validCellStr = arrayfun(@(r)repmat(string(r.Valid), size(r.Samples, 1), 1), result, 'UniformOutput', false);
out = vertcat(validCellStr{:});
end
