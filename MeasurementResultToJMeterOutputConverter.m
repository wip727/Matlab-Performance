classdef MeasurementResultToJMeterOutputConverter < handle

    % This is undocumented
    % Copyright 2018 The MathWorks, Inc. 
    
    properties(Hidden, SetAccess=private)
        Filename;
    end
    
    methods (Hidden, Access = protected)
        function converter = MeasurementResultToJMeterOutputConverter(varargin)
            
        end
    end
    
    methods(Static)
        function toXMLFormat(result, filename)
            validateattributes(result, {'matlab.unittest.measurement.MeasurementResult'}, {});
            
            docNode = com.mathworks.xml.XMLUtils.createDocument('testResults');
            testResultsNode = docNode.getDocumentElement;
            testResultsNode.setAttribute('version','1.2');
            
            for idx = 1:length(result)
                currTest = result(idx); % TODO
                sampleTable = currTest.Samples;
                nrows = size(sampleTable,1);
                for idr = 1:nrows
                    curr_node = docNode.createElement('sample');
                    
                    measuredValue = string(floor(sampleTable{idr, 'MeasuredTime'}*1000)); % TODO
                    name = string(sampleTable{idr, 'Name'});
                    timestamp = string(posixtime(sampleTable{idr, 'Timestamp'})*1000);
                    status = string(currTest.Valid);
                    
                    curr_node.setAttribute('t', measuredValue);
                    curr_node.setAttribute('lb', name);
                    curr_node.setAttribute('ts', timestamp);
                    curr_node.setAttribute('s', status);
                    testResultsNode.appendChild(curr_node);
                end
            end
            
            xmlwrite(filename, docNode);
        end
    end
end
