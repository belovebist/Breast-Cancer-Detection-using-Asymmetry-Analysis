% test script
clear all;
clc;

% -------------------------------------------------------------------------
% Load all the images
image_dir = 'images';
[images, labels, n_images] = load_images(image_dir);


% -------------------------------------------------------------------------
% To do segmentation test run code, and comment everything below
 test_segmentation(images, labels);
% -------------------------------------------------------------------------

%{
for i = 2: 13
    disp(['For ', num2str(i), ' Principal Components...']) 
%}

% -------------------------------------------------------------------------
% -------------------------- Feature Extraction ---------------------------
% -------------------------------------------------------------------------
% Please remove curly bracket after '%' to use this block
%{
% Extract features from all the images
disp('Extracting all the features...');
%image_features = extract_features(images, 'relevant');
image_features = extract_features(images, 'all');
disp('Features extracted successfully !');
disp(' ');
%}

% Please remove curly bracket after '%' to use this block
%{
% Extract PCA features from given images
pca = struct();
pca(:).name = 'pca';
pca(:).nComps = i;
disp('Extracting PCA features...');
[image_features, pca] = extract_features(images, pca);
disp('Features extracted successfully !');
disp(' ');
%}


% -------------------------------------------------------------------------
% ------- Cross Validation Test using Leave-One-Out  ---------
% -------------------------------------------------------------------------
% To do cross validation test of the classifier to test overall accuracy,
% run the following line of code
 res = cross_validation_test_SVM(image_features, labels)
%


% -------------------------------------------------------------------------
% ------------------- Model Training and Testing ------------------
% -------------------------------------------------------------------------
% Please remove curly bracket after '%' to use this block
%{
% Train Support Vector Machine Classifier
disp('Training Support Vector Machine Classifier...');
%SVM = svmtrain(image_features, labels);
SVM = fitcsvm(image_features, labels, 'KernelFunction', 'rbf','Standardize', true, 'ClassNames', {'Healthy', 'Sick'});
disp('SVM trained successfully !');
disp(' ');

%
% Test the Classifier
disp('Testing the Classifier...');
result = test_SVM(SVM, image_features, labels)
disp(' ');

%}

%end