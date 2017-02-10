function seg = get_segment_ROI(src)
    
    %img = adapthisteq(src);
    img = src;

    % apply gaussian filter with sigma = 1.4 to filter noise
    h = fspecial('gaussian', [3, 3], 1.4);
    img = imfilter(img, h, 'replicate');
    
    % use canny edge detector to find the edges
    img = edge(img, 'canny', [0.15 0.20]);
    
    % use morphological dilation
    se = ones(3, 3, 'uint8');
    img = imdilate(img, se);
    
    %get the ROI
    [left, right, top, bottom] = get_bounding_rect(img);
    
    seg = src(top: bottom, left: right);
    
end

% return a bounding region for the Region of Interest
function [left, right, top, bottom] = get_bounding_rect(img)
    
    [y_img, x_img] = size(img);

    % strip off the bottom part of the image
    hpp = get_pp(img, 'hpp', 'reversed');
    %subplot(321), plot(hpp)
  
    % find the peaks and their respective locations
    [pks, locs] = findpeaks(hpp, 'MinPeakHeight', 0.5);
    if length(locs > 0)
        bottom = y_img - locs(1) + 1;
    else
        bottom = y_img;
    end
    img = img(1: bottom, :);
    
    %subplot(121), imshow(img);

    % strip off the image above neck region
    tmp = img(1: int64(bottom / 3), :);
    hpp = get_pp(tmp, 'hpp', 'reversed');
    %subplot(223), plot(hpp)
    
    % find the peaks and their respective locations
    [pks, locs] = findpeaks(hpp, 'MinPeakHeight', 0.5);
    if length(locs > 0)
        top = int64(bottom / 3) - locs(1);
    else
        top = 1;
    end
    img = img(top: bottom, :);
    
    % strip off the left and right side of breasts in given image
    vpp = get_pp(img, 'vpp');
    %subplot(322), plot(vpp)

    % find the peaks and their respective locations
    [pks, locs] = findpeaks(vpp, 'MinPeakHeight', 0.5);
    
    if length(locs > 0)
        left = locs(1);
    else
        left = 1;
    end
    if length(locs > 1)
        right = locs(end);
    else
        right = x_img;
    end
    
end
    