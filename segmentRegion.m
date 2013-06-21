function Phi = segmentRegion(tolerance,image,x,y)
%% segmentRegion performs a seeded region growing with a given tolerance and set of intial seeds
    

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
image = imfilter(image,gauss,'replicate');


if(x == 0 || y == 0)
    imshow(image,[0 255]);
    [x,y] = ginput(1);
end
Phi = false(size(image,1),size(image,2));
ref = true(size(image,1),size(image,2));
PhiOld = Phi;
Phi(x,y) = 1;
while(sum(Phi(:)) ~= sum(PhiOld(:)))
    PhiOld = Phi;
    segm_val = image(Phi);
    meanSeg = mean(segm_val);
    posVoisinsPhi = imdilate(Phi,strel('disk',1,0)) - Phi;
    voisins = find(posVoisinsPhi);
    valeursVoisins = image(voisins);
    Phi(voisins(valeursVoisins > meanSeg - tolerance & valeursVoisins < meanSeg + tolerance)) = 1;
end

Phi = imclose(Phi,se); % Applying closing function on mask2

% closeMask = oldmask | closeBW2; % Union of both mask
Phi = uint8(imfill(Phi, 'holes')); % Filling holes in the final mask

% Uncomment this if you only want to get the region boundaries
% SE = strel('disk',1,0);
% ImErd = imerode(Phi,SE);
% Phi = Phi - ImErd;