% Leave One Out Cross Validation test for the SVM classifier
function result = cross_validation_test_SVM(features, labels)

    % size of the feature set
    size_features = length(features);
    
    % For every iteration, train the SVM Classifier model using all
    % features and leave one out for testing the model. For 45 images in
    % our case, we will use 44 images for training the model, and use the
    % left out one, to test the classifier. This will be repeated until all
    % the images are tested at least ones.
    
    disp('Training and Testing Support Vector Machine Classifier using Leave-One-Out Cross Validation...');
    
    % cell array to store the results of the prediction
    test_results = cell(1, size_features);
    
    for k = 1: size_features
        
        % leave one feature out for testing
        test_feature = features(k, :);
        
        % use all the remaining features for training the model
        training_features = [features(1: k-1, :); features(k+1: size_features, :)];
        training_labels = [labels(1: k-1), labels(k+1: size_features)];
        
        % Train Support Vector Machine Classifier using training_features
        %disp(['Training Classifier for feature set ', int2str(k), '...']);
        %SVM = svmtrain(training_features, training_labels);        
        SVM = fitcsvm(training_features, training_labels, 'KernelFunction', ...
            'linear', 'Standardize', true, 'KernelScale', 'auto', 'ClassNames', ...
            {'Healthy', 'Sick'});
        
        % Test the Classifier using test_feature
        test_results{k} = cell2mat(predict(SVM, test_feature));
        
    end
    
    result = gen_test_parameters(labels, test_results, 'Sick', 'Healthy');
    
end