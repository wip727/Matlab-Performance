classdef examplePerfTest < matlab.perftest.TestCase
    methods(Test)
        function testSVD1(testCase)
            testCase.startMeasuring('arrayGen')
            X = rand(1000);
            testCase.stopMeasuring('arrayGen')
            testCase.startMeasuring('SVD_1out')
            S = svd(X);
            testCase.stopMeasuring('SVD_1out')
            testCase.startMeasuring("SVD_3out")
            [U2,S2,V2] = svd(X);
            testCase.stopMeasuring("SVD_3out")
            testCase.verifyEqual(S,diag(S2),'RelTol',1e-14)
        end
        function testSVD2(testCase)
            sz = 732;
            X = rand(sz);
            testCase.startMeasuring()
            [U,S,V] = svd(X);
            testCase.stopMeasuring()
            testCase.verifyTrue(isdiag(S))
            testCase.verifyTrue(issorted(diag(S),'descend'))
            testCase.verifySize(S,[sz sz 1])
        end
    end
end