function convertMeasurementResultToJMeterXML(result, filename)
%CONVERTMEASUREMENTRESULTTOJMETERXML Convert and save MeasurementResult to a JMeter XML file.
% CONVERTMEASUREMENTRESULTTOJMETERXML(RESULT, FILENAME) converts and writes
% the MeasurementResult RESULT to an XML file FILENAME in JMeter output format.
%
% Copyright 2018 The MathWorks, Inc.

import matlab.unittest.internal.newFileResolver;

% Validate inputs
outputFile = newFileResolver(filename, '.xml');

% Initialize xml DOM
docNode = com.mathworks.xml.XMLUtils.createDocument('testResults');
testResultsNode = docNode.getDocumentElement;
testResultsNode.setAttribute('version','1.2');

for idx = 1:length(result)
    currTest = result(idx);
    sampleTable = currTest.Samples;
    nrows = size(sampleTable,1);
    for idr = 1:nrows
        currElem = createSampleElement(docNode, sampleTable(idr,:));
        
        % Add test valid/invalid information as status
        currElem.setAttribute('s', string(currTest.Valid));
        
        % Append sample node
        testResultsNode.appendChild(currElem);
    end
end

xmlwrite(outputFile, docNode);
end

function element = createSampleElement(docNode, sample)
% Create XML element for each sample.
element = docNode.createElement('sample');

measuredValue = num2str(floor(sample.MeasuredTime*1000));
name = string(sample.Name);
timestamp = num2str(posixtime(sample.Timestamp)*1000);

element.setAttribute('t', measuredValue);
element.setAttribute('lb', name);
element.setAttribute('ts', timestamp);
end
