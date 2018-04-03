classdef tMeasurementsWithLabel < matlab.perftest.TestCase
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
            testCase.startMeasuring();
            pause(.0456);
            testCase.stopMeasuring();
        end
        
        function testPi_31416(testCase)
            % multiple measurements, one tag
            testCase.startMeasuring();
            pause(.3);
            testCase.stopMeasuring();
        end
        
        function testMean(testCase,Size)
            % comparing different algorithms with default
            M = rand(Size);    
            
            % default implementation, no tag
            testCase.startMeasuring;
            m = mean(M(:)); %#ok<NASGU>
            testCase.stopMeasuring;
            
            % new algorithm, append author's Name
            testCase.startMeasuring();
            m = myMean(M); %#ok<NASGU>
            testCase.stopMeasuring();
        end
        
        function testIllegalTag(testCase)
            testCase.startMeasuring('tag');
            testCase.stopMeasuring('_tag');
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
