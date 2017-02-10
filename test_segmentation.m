% utility function for viewing segmentations
function [] = test_segmentation(images, labels)

    disp('Image segmentation test...');
    
    HealthyCount = sum(strcmp(labels, 'Healthy'));
    SickCount = length(labels) - HealthyCount;
    
    disp(['Healthy Count : ' num2str(HealthyCount)]);
    disp(['Sick Count    : ' num2str(SickCount)]);
    disp(' ');
    
    % number of images in cell array
    n_images = length(images);
    
    for i = 1: n_images

        disp(['Image Number : ', num2str(i)]);
        disp(['Image Label  : ', labels(i)]);

        % Find the ROI
        img = images{i};
        gray = rgb2gray(img);
        seg = get_segment_ROI(gray);
        
        % Segment the images and get bflines
        [left, right, bflines] = get_segments_lr(seg);
        %
        % Display all the images
        subplot(221), imshow(gray);
        subplot(222), imshow(seg);
        
        if ~isempty(bflines)
            x = bflines{1}; y1 = bflines{2}; y2 = bflines{3};
            hold on;
            subplot(222), plot(x, y1, 'b', 'LineWidth', 2);
            subplot(222), plot(x, y2, 'b', 'LineWidth', 2);

            % find and plot the bifurcation point
            [bi_x, bi_y] = polyxpoly(x, y1, x, y2, 'unique');
            plot(bi_x, bi_y, 'o', 'MarkerEdgeColor', 'r', 'MarkerSize', 12, 'LineWidth', 3);
            hold off;
        else
            disp('Sorry, Cannot find bufurcation line !');
            disp(' ');
        end
        
        subplot(223), imshow(left);
        subplot(224), imshow(right);
        %}
        k = waitforbuttonpress;
        
    end
    
    disp('Image segmentation test completed !');
end