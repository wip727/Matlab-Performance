classdef MeasurementResultConverter < handle

    % This is undocumented
    % Copyright 2018 The MathWorks, Inc. 
    
    methods(Abstract)
        run(converter)
    end
    
    methods(Static)
        function converter = toXMLFormat(result, filename)
            converter = MeasurementResultToJMeterXMLOutputConverter(result, filename);
        end
    end
end
