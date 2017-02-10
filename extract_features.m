% extracts features from given image 
% First, convert given image to grayscale if necessary
% Then, Find the Region of Interest in the grayscale image
% Then, segment the ROI into left and right breasts by finding the
% bifurcation point, i.e, intersection of two inframammary curves near the
% center of the ROI.
% Find the Asymmetry features, i.e, absolute difference between left and
% right breast features

function [features, feat] = extract_features(src, feat)

    if isstruct(feat)
        feat_type = feat.name;
    elseif ischar(feat)
        feat_type = feat;
    end;
    
    % if img is images cell array, the extract all the features from all 
    % images else returns the feature of individual image
    if iscell(src)
        n_images = length(src);
        feats = cell(n_images, 1);
        for i = 1: n_images
            feats{i} = extract_feat(src{i}, feat_type);
        end
        
        features = cell2mat(feats);
        
        if isstruct(feat) && strcmp(feat.name, 'pca')
            [coeff, scores, latent] = princomp(features);
            feat(:).coeff = coeff;
            feat(:).scores = scores;
            feat(:).latent = latent;
            feat(:).mean = mean(features);
            feat(:).std = std(features);
            features = scores(:, 1: feat.nComps);
        end
    else
        features = extract_feat(src, feat_type);
    
        if isstruct(feat) && strcmp(feat.name, 'pca')
            features = bsxfun(@rdivide, bsxfun(@minus, features - feat.mean), feat.std);
            features = features * feat.coeff;
        end
    end
    
end

function feat = extract_feat(img, feat)

    % Convert to grayscale
    gray = rgb2gray(img);
    
    % Get the ROI segment
    seg = get_segment_ROI(gray);

    % Get bifurcation point and segment into left and right sides
    [left, right] = get_segments_lr(seg); 
    
    % Apply nonlinear sharpening filter to both left and right images
    h = fspecial('unsharp');
    left = imfilter(left, h, 'replicate');
    right = imfilter(right, h, 'replicate');
    
    % extract features
    feat = get_featsAsymmetry(left, right, feat);

end

% Extract the features required for asymmetriy analysis of breast
% thermograms. Both left and right side breast images are required for
% feature extraction
function featVector = get_featsAsymmetry(left, right, feat)
    
    lhist = get_fof_hist(left);
    lglcm = get_GLCM(left);

    rhist = get_fof_hist(right);
    rglcm = get_GLCM(right);
    
    % The absolute difference of histogram extracted mean, skewness,
    % kurtosis, entropy and GLCM extracted variance, correlation and energy
    % are significant in detection of breast cancer. So, we'll use these
    % features to train a SVM model for classification

    if strcmp(feat, 'relevant')
        
        lfeats = [lhist.Mean, lhist.Skewness, lhist.Kurtosis,        ...
                  lhist.Entropy, lglcm.Variance, lglcm.Correlation,  ...
                  lglcm.Energy];
        rfeats = [rhist.Mean, rhist.Skewness, rhist.Kurtosis,        ...
                  rhist.Entropy, rglcm.Variance, rglcm.Correlation,  ...
                  rglcm.Energy];
    else
        
        lfeats = [struct2array(lhist) struct2array(lglcm)];
        rfeats = [struct2array(rhist) struct2array(rglcm)];
        
    end
  
    featVector = abs(lfeats - rfeats);
                  
end

% Extracts the first order features for texture analysis using the
% histogram of that image for intensity distribution
% For gray images, the number of distinct bins are 256, for each grayscale 
% intensity values
function stats = get_fof_hist(img)
    
    [pixelCounts, graylevels] = imhist(img);
    totalPixelCount = sum(pixelCounts);   % total number of pixels in given image
    
    % approximate probability density of occurance of each gray level
    Probs = pixelCounts / totalPixelCount;
    
    % normalize gray levels
    graylevels = graylevels / (max(graylevels) - min(graylevels) + 1);
    
    % Mean
    Mean = sum(Probs .* graylevels);
    
    % graylevels-mean difference
    diff = graylevels - Mean;
    
    % Variance
    diffSquared = diff .^ 2;
    Variance = sum(Probs .* diffSquared);
    
    % Skewness
    diffThird = diff .^ 3;
    Skewness = sqrt(Variance) ^ (-3) * sum(Probs .* diffThird);
    
    % Kurtosis
    diffFourth = diff .^ 4;
    Kurtosis = sqrt(Variance) ^ (-4) * sum(Probs .* diffFourth);
    
    % Energy
    Energy = sum(Probs .* Probs);
    
    % Entropy
    Entropy = entropy(img);
    
    % result
    stats = struct('Mean', Mean, 'Variance', Variance,          ...
                   'Skewness', Skewness, 'Kurtosis', Kurtosis,  ...
                   'Energy', Energy, 'Entropy', Entropy);
    
end

% Extract the gray level co-occurence matrix (GLCM) features
% It is also known as the gray-level spatial dependence matrix
function stats = get_GLCM(img)
    
    % GLCM matrices are computed for four directions horizontal, left
    % diagonal, vertical, right diagonal at a distance of 1 pixel.
    % offsets is a 4x2 dimensional array with 4 directions mentioned above,
    % with respect to the point of interest. All GLCM texture is second-order
    % (concerning the relationship between two pixels).
    offsets = [1 0; 1 1; 0 1; 1 -1];
    glcm = graycomatrix(img, 'Offset', offsets);
    
    % GLCM is 8 * 8 * n_glcms dimensional matrix where n_glcms is the 
    % number of directions mentioned in the offset
    n_glcms = size(offsets, 1);
    
    % total point count in each GLCM matrix
    glcm_sum = sum(sum(glcm, 2), 1);    
    
    % Normalize the glcms
    glcm_norm = bsxfun(@rdivide, glcm, glcm_sum);
    
    % calculate the mean, variance and entropy for each glcm 
    % (i.e. each direction). Since, the paper doesn't present proper
    % definition of glcm mean, mean of normalized glcm is taken, which is
    % same of every glcm i.e. 0.0156 ( 1 / (8*8))
    Mean = zeros(1, n_glcms);
    Variance = zeros(1, n_glcms);
    Entropy = zeros(1, n_glcms);
    for i = 1: n_glcms 
        Mean(i) = mean2(glcm_norm(:, :, i));
        Variance(i) = std2(glcm_norm(:, :, i)) ^ 2;
        Entropy(i) = entropy(glcm(:, :, i));
    end
    
    % calculate Energy, Contrast, Correlation, and Homogeneity for glcm
    glcm_stats = graycoprops(glcm);

    % return all of required GLCM features
    stats(:).Mean = mean(Mean);
    stats(:).Variance = mean(Variance);
    stats(:).Entropy = mean(Entropy);
    stats(:).Energy = mean(glcm_stats.Energy);
    stats(:).Contrast = mean(glcm_stats.Contrast);
    stats(:).Correlation = mean(glcm_stats.Correlation);
    stats(:).Homogeneity = mean(glcm_stats.Homogeneity);
       
end
   