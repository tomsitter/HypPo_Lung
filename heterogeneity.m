function [ hetero ] = heterogeneity( image, mask, thresh )
%HETEROGENEITY Summary of this function goes here
%   Detailed explanation goes here

% horz = sum(mask, 1);
% left = find(horz, 1, 'first');
% right = find(horz, 1, 'last');
% 
% vert = sum(mask, 2)
% top = find(vert, 1, 'first');
% bottom = find(vert, 1, 'last');
% 
% width = right - left;
% height = bottom - top;

% bb = regionprops(mask, 'BoundingBox');

% x = round(bb.BoundingBox(1));
% y = round(bb.BoundingBox(2));
% width = round(bb.BoundingBox(3)); 
% height = round(bb.BoundingBox(4));

% cropped_mask = mask(y:y+height, x:x+width);
% cropped_img = image(y:y+height, x:x+width);

mask = imclose(mask, strel('disk', 3));

erode_mask = imerode(mask, strel('ball', 5,5));
m = max(erode_mask(:));
mask = erode_mask == m;

mask_inv = not(mask);

% avg_signal = sum(image) ./ sum(mask);

% avg_signal = mean2(double(image) .* mask);

%Make background have intensity of average of lung region
image_noedge = image;
image_noedge(mask_inv) = thresh;



% lung_only = uint8(mask) .* image;

% padded_lung = padarray(lung_only, [1 1], 'symmetric', 'both');

hetero = stdfilt(image_noedge);

hetero = mask .* hetero;

% glcm = graycomatrix(lung_only);
% stats = graycoprops(glcm, {'Contrast', 'Homogeneity'});

% hetero = hetero(2:end-1, 2:end-1);

% imagesc(hetero);

% regions = bwlabel(cropped_mask);
% 
% bb_regions = regionprops(regions, 'BoundingBox');
% 
% for i = 1:length(bb_regions)
%     
% y = round(bb_regions.BoundingBox(1));
% x = round(bb_regions.BoundingBox(2));
% height = round(bb_regions.BoundingBox(3)); 
% width = round(bb_regions.BoundingBox(4));
% 
% roi = image(y:y+height, x:x+width);
% 
% hetero = imfilter(f,w, 'corr', 'symmetric', 'same')
% 
%     
% end


end

