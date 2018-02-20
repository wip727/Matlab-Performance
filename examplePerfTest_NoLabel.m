classdef examplePerfTest_NoLabel < matlab.perftest.TestCase
    methods(Test)
        function testSVD1(testCase)
            testCase.startMeasuring()
            X = rand(1000);
            testCase.stopMeasuring()
        end
        function testSVD2(testCase)
            sz = 732;
            X = rand(sz);
            testCase.startMeasuring()
            [U,S,V] = svd(X);
            testCase.stopMeasuring()
            testCase.verifyTrue(isdiag(S))
            testCase.verifyTrue(issorted(diag(S),'descend'))
            testCase.verifySize(S,[sz sz])
        end
    end
end