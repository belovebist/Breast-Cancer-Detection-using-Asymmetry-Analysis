% segment the ROI into left and right regions by find the bifurcation point
% that is the intersection of two infra-mammary curves

function [left, right, bflines] = get_segments_lr(src)
   
    %src = adapthisteq(src);
    img = src;
    
    % apply gaussian filter with sigma = 1.4 to filter noise
    h = fspecial('gaussian', [3, 3], 2.0);
    img = imfilter(img, h, 'replicate');
    
    % use canny edge detector to find the edges
    [~, threshOut] = edge(img, 'canny');
    threshold = [2.0 4.0] .* threshOut;
    %threshold = [0.10 0.3]
    img = edge(img, 'Canny', threshold);

    % use morphological dilation
    sel = ones(2, 2, 'uint8');
    img = imdilate(img, sel);
    
    % use morphological closing using flat disc-shaped structuring element with
    % radius 4
    se = strel('disk', 4);
    img = imclose(img, se);
    
    %subplot(121), imshow(src);
    %subplot(122), imshow(img);
    % select the middle region of the image to trace the infra-mammary
    % curves
    [y_img, x_img] = size(img);
    img(1: round(y_img / 4), :) = 0;
    img(:, 1: round(x_img / 5)) = 0;
    img(:, round(4 * x_img / 5): x_img) = 0;
    
    %img = bwareaopen(img, 200);
    % trace all the boundaries and select longest two segments near the
    % center
    [b, l, n, a] = bwboundaries(img, 'noholes');
    
    % If there are 2 or more lines then choose longest two
    if n >= 2
        b_lengths = zeros(n);
        for i = 1: n
            b_lengths(i) = length(b{i});
        end
        [b_lengths, I] = sort(b_lengths, 'descend');
        b1 = b{I(1)};
        b2 = b{I(2)};

        % apply polynomial curve fitting on b1 and b2 and find the intersection
        % point bi
        p1 = polyfit(b1(:, 2), b1(:, 1), 2);
        p2 = polyfit(b2(:, 2), b2(:, 1), 2);

        x = 1: x_img;   
        y1 = polyval(p1, x);
        y2 = polyval(p2, x);
        
        bflines = cell(1, 3);
        bflines = {x, y1, y2};
        
        [bi_x, bi_y] = polyxpoly(x, y1, x, y2, 'unique');
    else
        % When there are no infra-mammary curves, then choose default
        % values for bi_x, and bi_y
        bi_x = x_img / 2;
        bi_y = y_img / 2;
    end;

    new_top = int64(min(y_img / 3, bi_y));
    
    left = src(new_top: y_img, 1: floor(bi_x));
    right = src(new_top: y_img, floor(bi_x) + 1: x_img);
    
    if ~exist('bflines', 'var')
        bflines = [];
    end
    
end
