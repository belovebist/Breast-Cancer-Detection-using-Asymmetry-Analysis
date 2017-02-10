% Generate a confusion matrix along with all the test parameters, using
% true data, predicted data, and positive and negative class labels
function result = gen_test_parameters(true_classes, pred_classes, positive_label, negative_label)
    
    
    % Here accuracy is tested based correct predictions (TruePositive,
    % TrueNegative) and wrong predictions (FalseNegative, FalsePositive)
    % matrix
    
    % Actual data
    P = strcmp(true_classes, positive_label);    
    N = strcmp(true_classes, negative_label);
        
    % Predictions
    predP = strcmp(pred_classes, positive_label);
    predN = strcmp(pred_classes, negative_label);
    
    % Build confusion matrix
    
    % actually positive, predicted positive       (True Positive)
    TP = P .* predP;
    % actually negative, predicted negative (True Negative)
    TN = N .* predN;
    % actually negative, predicted positive    (False Positive)
    FP = N .* predP;
    % actually positive, predicted negative    (False Negative)
    FN = P .* predN;
    
    % Confusion matrix
    result(:).ConfusionMatrix(:).TruePositive = sum(TP);
    result(:).ConfusionMatrix(:).TrueNegative = sum(TN);
    result(:).ConfusionMatrix(:).FalsePositive = sum(FP);
    result(:).ConfusionMatrix(:).FalseNegative = sum(FN);
   
    result.ConfusionMatrix
    % Accuracy
    result(:).Accuracy = (sum(TP) + sum(TN)) / (sum(N) + sum(P));
    
    % Sensitivity, recall, hit rate or true positive rate (TPR)
    result(:).Sensitivity = sum(TP) / sum(P);
    
    % Specificity or true negative rate (TNR)
    result(:).Specificity = sum(TN) / sum(N);
    
    % Precision or positive prective value (PPV)
    result(:).Precision = sum(TP) / (sum(TP) + sum(FP));
    
    % Prevalance, how often Yes condition occur in our sample
    result(:).Prevalence = sum(P) / (sum(P) + sum(N));
    
    % Error Rate or misclassification rate
    result(:).ErrorRate = 1 - result.Accuracy;
    
    % Positive Predictive Value (PPV)
    result(:).PositivePredictiveValue = result.Sensitivity * result.Prevalence / ...
                (result.Sensitivity * result.Prevalence + (1 - result.Specificity) * (1 - result.Prevalence));
            
    % Negative predictive value (NPV)
    result(:).NegativePredictiveValue = sum(TN) / (sum(TN) + sum(FN));
    
    % Null Error Rate
    result(:).NullErrorRate = min(sum(predP), sum(predN)) / (sum(P) + sum(N));
    
    % Fall out or false positive rate (FPR)
    result(:).FallOut = 1 - result.Specificity;
    
    % False discovery rate (FDR)
    result(:).FalseDiscoveryRate = 1 - result.PositivePredictiveValue;

    % False ommision rate (FOR)
    result(:).FalseOmissionRate = 1 - result.NegativePredictiveValue;
    
    % Miss rate or false negative rate (FNR)
    result(:).FalseNegativeRate = 1 - result.Sensitivity;
    
    % F1 score, harmonic mean of precision and sensitivity
    result(:).F1Score = 2 * sum(TP) / (2 * sum(TP) + sum(FP) + sum(FN));
    
end