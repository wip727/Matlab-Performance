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
        
        function testNatick_456(testCase)
            % self-measured, with tag
            testCase.startMeasuring("Natick");
            pause(.0456);
            testCase.stopMeasuring("Natick");
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
        
        function testUnmatchingTag(testCase)
            testCase.startMeasuring('a');
            testCase.stopMeasuring('b');
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
