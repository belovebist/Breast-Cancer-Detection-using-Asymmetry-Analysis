% test SVM model
function result = test_SVM(SVM, feats, labels)

    classes = svmclassify(SVM, feats);
    %classes = predict(SVM, feats);
    
    result = gen_test_parameters(labels, classes, 'Sick', 'Healthy');
    
end
