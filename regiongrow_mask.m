function [ closeMask ] = regiongrow_mask( image )
%REGIONGROW_MASK Summary of this function goes here
%   Detailed explanation goes here

%Initial parameters
sigma = 2;
%percent = 5;
k = 4;
%flag = 2;

[height, width] = size(image);
halfHeight = floor(height/2);
halfWidth = floor(width/2);

if height < 256 % e.g. image size = 128x128
    blockSize = 10; %Size for Gaussian mask - 10
    se = strel('disk',10); % structural element to be used by closing function imclose() 
    minSeedlength = 10; % minimum length of connected pixels with intensity smaller than threshold
    loopStep = 5; % step for tracing columns 
elseif height < 512
    blockSize = 15; 
    se = strel('disk',15); 
    minSeedlength = 20;
    loopStep = 8;
else
    blockSize = 20; 
    se = strel('disk',20);  
    minSeedlength = 30;
    loopStep = 12;
end

lowerBorder = height-minSeedlength-floor(0.10 * height);


%Gaussian filter
gauss = fspecial('gaussian', blockSize, sigma);
%Smooth image
filter = imfilter(image,gauss,'replicate');

[~,clusters] = kmeansModified(filter, k);

tempVector = filter(clusters == 1);
firstClusterThreshold = double(max(tempVector));

% Finding a threshold to segment throcic cavity basd on K-means
%if flag == 1
threshold = round((firstClusterThreshold)*2/3); 
%else
%    threshold = round((firstClusterThreshold-firstClusterThreshold*0.01*(percentage+(abs(slice-middleNumber))))/2);
%end

tempMask = false(size(filter));
if ~isempty(threshold)
    tempMask(filter<threshold) = 1;
else
%         save protonMaskResult.mat protonMask proton
    return;
end
mask = tempMask;

% Finding two seed for SRGA to find left and right lung after thresholding 
seed1 = [1,1];
for column1 = floor(width/3) : loopStep : floor(width/2)-2*minSeedlength % tracing columns
    for traking = halfHeight - floor(0.15*halfHeight) : lowerBorder % tracing rows
        if sum(mask(traking:traking+minSeedlength-1,column1)) == minSeedlength %to find a seed on the right lung
            seed1 = [traking, column1];
            break;
        end
    end
    if traking ~= lowerBorder
        break;
    end
end
seed2 = [1,1];
for column2 =  floor(width/2)+2*minSeedlength : loopStep : width-floor(width/5)
    for traking = halfHeight - floor(0.15*halfHeight) : lowerBorder 
        if sum(mask(traking:traking+minSeedlength-1,column2)) == minSeedlength %to find a seed on the left lung
            seed2 = [traking, column2];
            break;
        end
    end
    if traking ~= lowerBorder
        break;
    end
end

if seed1(1) ~= 1  %seed1(1)==1 means the seed was not found
    mask1 = BWregionGrowing(mask,seed1(1),seed1(2));
    [~,Y] = find(mask1);
    if (max(round(Y)) > (width-10))
        disp('Body background was segmented as the lung mask1')
        mask1 = false(size(mask));
    end
else
    mask1 = false(size(mask));
end

if seed2(1) ~= 1  %seed2(1)==1 means the seed was not found 
    mask2 =  BWregionGrowing(mask,seed2(1),seed2(2));
    [~,Y] = find(mask2);
    if (max(round(Y)) > (width-10))
        disp('Body-background was segmented as the lung mask2')
        mask2 = false(size(mask));
    end
else
    mask2 = false(size(mask));
end

% Before applying closing algorithm, we need to check if masks of the
% left and right lung are connected to each other. If yes, we need to 
% seperate them in order to avoid filling the area between them. 
[~,Y] = find(mask1);
if (max(round(Y)) > (halfWidth+20))
    disp('Masks of left and right lungs are connected!!')
    mask1(1:height , floor(width/2)-1:width) = 0; % removing right (half) part of the mask1
    mask2(1:height,1:floor(width/2)+1) = 0; % removing left (half) part of the mask2
end

closeBW1 = imclose(mask1,se); % Applying closing function on mask1
closeBW2 = imclose(mask2,se); % Applying closing function on mask2
closeMask = closeBW1 | closeBW2; % Union of both mask
closeMask = imfill(closeMask, 'holes'); % Filling holes in the final mask

