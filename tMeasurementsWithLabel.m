classdef tMeasurementsWithLabel < matlab.perftest.TestCase & matlabtest.measurement.MeasurementLoggable
    % Copyright 2017 The MathWorks, Inc.
    
    properties(TestParameter)
        Size = {2000,4000};
        N = {50,1e6};
    end
    
    methods(TestClassSetup)
        function setup(testCase)
            testCase.assumeFalse(false);
        end
    end
    
    methods(Test)
        function testImplicit123(~)
            % not self-measured
            pause(.0123);
        end
        
        function test0333(testCase)
            % self-measured
            testCase.startMeasuring();
            pause(.0333);
            testCase.stopMeasuring();
        end
        
        function test0444(testCase)
            % log-measured
            import matlabtest.perftest.TimeMeasurement;
            testCase.logMeasurement(TimeMeasurement(.0444));
        end
        
        function testNatick_456(testCase)
            % self-measured, with tag
            testCase.startMeasuring("Natick");
            pause(.0456);
            testCase.stopMeasuring("Natick");
        end
        
        function testNatick_2017(testCase)
            % log-measured, with tag
            import matlabtest.perftest.TimeMeasurement;
            testCase.logMeasurement(TimeMeasurement(.2017),"Framingham");
        end
        
        function testPi_31416(testCase)
            % multiple measurements, one tag
            testCase.startMeasuring('Pi');
            pause(.3);
            testCase.stopMeasuring('Pi');
            
            testCase.startMeasuring('Pi');
            pause(.01);
            testCase.stopMeasuring('Pi');
            
            testCase.startMeasuring('Pi');
            pause(.00416);
            testCase.stopMeasuring('Pi');
        end
        
        function testOlympic(testCase)
            % multiple measurements, multiple tags
            import matlabtest.perftest.TimeMeasurement;
            
            % Usain Bolt's record
            t100 = 9.58;
            t200 = 19.19;
            
            testCase.logMeasurement(TimeMeasurement(t100),'UB_100m');
            testCase.logMeasurement(TimeMeasurement(t200),'UB_200m');
            
            % Ratio, nearly 2:1
            testCase.logMeasurement(TimeMeasurement(t200/t100),'Ratio');
        end
        
        function testMean(testCase,Size)
            % comparing different algorithms with default
            M = rand(Size);    
            
            % default implementation, no tag
            testCase.startMeasuring;
            m = mean(M(:)); %#ok<NASGU>
            testCase.stopMeasuring;
            
            % new algorithm, append author's Name
            testCase.startMeasuring('ChangQingsAlgorithm');
            m = myMean(M); %#ok<NASGU>
            testCase.stopMeasuring('ChangQingsAlgorithm');
        end
        
        function testLoop(testCase)
            % multiple measurements, multiple tags
            for i = 1:10
                tag = ['L',num2str(i)];
                testCase.startMeasuring(tag);
                pause(i/1000);
                testCase.stopMeasuring(tag);
            end
        end
        
        function testPrecision(testCase,N)
            % filter whole testpoint if one measurement is too fast
            import matlabtest.perftest.TimeMeasurement;
            testCase.logMeasurement(TimeMeasurement(1));
            
            testCase.startMeasuring('fast');
            for i = 1 : N
                1+1; %#ok<VUNUS>
            end
            testCase.stopMeasuring('fast');
            
            testCase.startMeasuring('faster');
            % Do Nothing
            for i = 1 : N/2
                1+1; %#ok<VUNUS>
            end
            testCase.stopMeasuring('faster');
            
            testCase.startMeasuring('fastest');
            % Do Nothing
            for i = 1 : N/4
                1+1; %#ok<VUNUS>
            end
            testCase.stopMeasuring('fastest');
        end
        
        function testIllegalTag(testCase)
            testCase.startMeasuring('tag');
            testCase.stopMeasuring('_tag');
        end
        
        function testLogIllegalTag(testCase)
            import matlabtest.perftest.TimeMeasurement;
            testCase.logMeasurement(TimeMeasurement(42),42);
        end
        
        function testUnmatchingTag(testCase)
            testCase.startMeasuring('a');
            testCase.stopMeasuring('b');
        end
        
        function testFrequentist(testCase)
            import matlabtest.perftest.TimeMeasurement
            testCase.startMeasuring();
            pause(.001);
            testCase.stopMeasuring();
            testCase.logMeasurement(TimeMeasurement(1),'logged');
        end
        
        function testdiff(testCase)
            import matlabtest.perftest.TimeMeasurement
            on = 0.5;
            off = 0.5;
            testCase.logMeasurement(TimeMeasurement(on-off),'diff');
        end
    end
    
end

function out = myMean(in)

runningSum = 0;
row = size(in,1);
col = size(in,2);

for i = 1:row
    for j = 1:col
        x = in(i,j);
        runningSum = x + runningSum;
    end
end
out = runningSum/(row*col);
end