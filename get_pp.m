% Get the projection profile for input image
% two types of projection profile : Horizontal PP, and Vertical PP
function pp = get_pp(img, type, order)

    if strcmp(type, 'hpp')
        pp = sum(img, 2);
    elseif strcmp(type, 'vpp')
        pp = sum(img, 1);
    else
        error('Invalid projection profile ! Valid : hpp or vpp')
    end
    
    pp = reshape(pp, 1, length(pp));
    
    win = gausswin(4);
    pp = filter(win, 1, pp);
    
    % subtract the mean
    pp = pp - mean(pp);
    
    % normalize the projection profile
    peaks = sort(pp, 'descend');
    pp = pp / median(peaks(1: min(10, length(peaks))));
    
    % by default the vpp starts from left and hpp starts from top
    % that is, not reversed
    if nargin > 2
        if strcmp(order, 'reversed')
            pp = fliplr(pp);  
        end
    end
end
