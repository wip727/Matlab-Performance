function convertToJUnitXML(result, filename)
%CONVERTTOJUNITXML Convert and save MeasurementResult to a JUNIT XML file.
% CONVERTTOJUNITXML(RESULT, FILENAME) converts and writes
% the MeasurementResult RESULT to an XML file FILENAME in JUNIT output format.
%
% Copyright 2018 The MathWorks, Inc.

import matlab.unittest.internal.newFileResolver;
import matlab.unittest.measurement.internal.validateMeasuredVariable;

% Validate inputs
validateattributes(result, {'matlab.unittest.measurement.MeasurementResult'}, {});
outputFile = newFileResolver(filename, '.xml');

validateMeasuredVariable(result, {'MeasuredTime'});

% Initialize xml DOM
docNode = com.mathworks.xml.XMLUtils.createDocument('testsuites');
testResultsNode = docNode.getDocumentElement;

for idx = 1:length(result)
    testSuiteNode = docNode.createElement('testsuite');
    testResultsNode.appendChild(testSuiteNode);
    
    % reset counters
    counters = resetCounters;
    
    currTest = result(idx);
    activity = currTest.TestActivity;
    activityTable = activity(activity.Objective == categorical({'sample'}), :);
    nrows = size(activityTable,1);
    if nrows > 0
        timestamp = activityTable{1, 'Timestamp'};
    end
    counters.NumTests = nrows;
    for idr = 1:nrows
        currElem = createTestCaseElement(docNode, activityTable(idr,:));
        currTestResult = activityTable{idr, 'TestResult'};
        counters.TestSuiteDuration = counters.TestSuiteDuration + currTestResult.Duration;
        
        % Add classname attribute
        currElem.setAttribute('classname', currTest.Name);
        
        % Append sample node
        if currTestResult.FatalAssertionFailed
            counters = addFailureNode(counters, docNode, testSuiteNode, currElem, 'FatalAssertionFailure', currTestResult);
        elseif currTestResult.Errored
            counters = addErrorNode(counters, docNode, testSuiteNode, currElem, currTestResult);
        elseif currTestResult.AssertionFailed
            counters = addFailureNode(counters, docNode, testSuiteNode, currElem, 'AssertionFailure', currTestResult);
        elseif currTestResult.VerificationFailed
            counters = addFailureNode(counters, docNode, testSuiteNode, currElem, 'VerificationFailure', currTestResult);
        elseif currTestResult.AssumptionFailed
            counters = addSkippedNode(counters, docNode, testSuiteNode, currElem, currTestResult);
        else
            testSuiteNode.appendChild(currElem);
        end
        
    end
    testSuiteNode.setAttribute('name',     currTest.Name);
    testSuiteNode.setAttribute('tests',    num2str(counters.NumTests));
    testSuiteNode.setAttribute('failures', num2str(counters.NumFailures));
    testSuiteNode.setAttribute('errors',   num2str(counters.NumErrors));
    testSuiteNode.setAttribute('skipped',  num2str(counters.NumSkipped));
    testSuiteNode.setAttribute('time',     num2str(counters.TestSuiteDuration));
    testSuiteNode.setAttribute('timestamp',string(datetime(timestamp, 'Format', 'uuuu-MM-dd''T''HH:mm:ss')));
end

xmlwrite(outputFile, docNode);
end

function s = resetCounters
s.NumTests = 0;
s.NumFailures = 0;
s.NumErrors = 0;
s.NumSkipped = 0;
s.TestSuiteDuration = 0;
end

function element = createTestCaseElement(docNode, sample)
% Create XML element for each sample.
element = docNode.createElement('testcase');
element.setAttribute('time', num2str(sample.MeasuredTime));
element.setAttribute('name', string(sample.Name));
end

function counters = addFailureNode(counters, docNode, testResultsNode, testcaseElement, failureType, testResult)
failureNode = appendDiagnotiscsToTestCaseElement(docNode, testcaseElement, 'failure', testResult);
failureNode.setAttribute('type', failureType);

testResultsNode.appendChild(testcaseElement);
counters.NumFailures = counters.NumFailures + 1;
end

function counters = addSkippedNode(counters, docNode, testResultsNode, testcaseElement, testResult)
appendDiagnotiscsToTestCaseElement(docNode, testcaseElement, 'skipped', testResult);

testResultsNode.appendChild(testcaseElement);
counters.NumSkipped = counters.NumSkipped + 1;
end

function counters = addErrorNode(counters, docNode, testResultsNode, testcaseElement, testResult)
appendDiagnotiscsToTestCaseElement(docNode, testcaseElement, 'error', testResult);
testResultsNode.appendChild(testcaseElement);
counters.NumErrors = counters.NumErrors + 1;
end

function childNode = appendDiagnotiscsToTestCaseElement(docNode, testcaseElement, typeOfNode, testResult)
childNode = docNode.createElement(typeOfNode);

diagnosticsDetails = testResult.Details.DiagnosticRecord.Report;
diagnosticsNode = docNode.createTextNode(diagnosticsDetails);
childNode.appendChild(diagnosticsNode);

testcaseElement.appendChild(childNode);
end