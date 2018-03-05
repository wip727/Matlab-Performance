classdef MeasurementResultToJMeterXMLOutputConverter < MeasurementResultConverter
    
    % This is undocumented
    % Copyright 2018 The MathWorks, Inc.
    
    properties(Hidden, SetAccess=private)
        Filename;
        MeasResult;
    end
    
    methods
        function set.Filename(plugin, filename)
            plugin.Filename = filename;
        end
        
        function set.MeasResult(converter, result)
            validateattributes(result, {'matlab.unittest.measurement.MeasurementResult'}, {});
            converter.MeasResult = result;
        end
    end
    
    methods(Access=?MeasurementResultConverter)
        function converter = MeasurementResultToJMeterXMLOutputConverter(result, filename)
            converter = converter@MeasurementResultConverter;
            converter.MeasResult = result;
            converter.Filename = filename;
        end
    end
    
    methods
        function run(converter)
            result = converter.MeasResult;
            file = converter.Filename;
            
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
                    
                    testResultsNode.appendChild(currElem);
                end
            end
            
            xmlwrite(file, docNode);
        end
    end
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
