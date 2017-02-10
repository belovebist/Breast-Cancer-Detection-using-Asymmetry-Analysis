% Get list of all jpg images in provided directory

function [images, labels, n_images] = load_images(image_dir)

    if ~isdir(image_dir)
        error('Invalid image directory')
    end
    
    % list all files with extension '.jpg'
    imagefiles = dir(strcat(image_dir, '/*.jpg'));
    n_images = length(imagefiles);
    
    images = cell(1, n_images);
    labels = cell(1, n_images);
    
    disp(['Loading images from ', image_dir, '...']);
    
    for i = 1: n_images
        filename = strcat(image_dir, '/', imagefiles(i).name);
        image = imread(filename);
        images{i} = image;
        
        if strcmp(filename(end - 10: end - 4), 'Healthy') == 1
            labels{i} = 'Healthy';
        else
            labels{i} = 'Sick';
        end
        %images{i} = strip(image, 0.05, 0.12, 0.15, 0.05);
    end
    
    disp('Images loaded successfully !');
    disp(' ');
end

function ret = strip(img, left, right, top, bottom)
    [y, x, d] = size(img);
    ret = img(int64(top * y): y - int64(bottom * y), int64(left * x): x - int64(right * x), :);
end
    