function outputImage = maskOverlay(image, mask)
%MASKOVERLAY Overlay mask as contour on image.

if nargin ~= 2
    error('Wrong number of arguments; two expected.')
end

%imagesc(image);

if (sum(image(:)) == 0)||(sum(mask(:)) == 0)
	outputImage = image;
    return;
end

%hold on
%contour(mask,'g','LineWidth',1);
%hold off

filterOutline = fspecial('laplacian');
maskOutline = filter2(filterOutline,mask);
maskOutline = (maskOutline-min(maskOutline(:)))/(max(maskOutline(:))-min(maskOutline(:)));
imgAverage = mean(maskOutline(:));
maskOutline(maskOutline<imgAverage-imgAverage*0.3|maskOutline>imgAverage+imgAverage*0.3) = 1;
maskOutline(maskOutline>=imgAverage-imgAverage*0.3&maskOutline<=imgAverage+imgAverage*0.3) = 0;

outputImage = repmat(image,[1 1 3]);
outputImage = double(outputImage);
outputImage = (outputImage-min(outputImage(:)))/(max(outputImage(:))-min(outputImage(:)));
outputImage(logical([zeros(size(maskOutline)),maskOutline==1,zeros(size(maskOutline))])) = 1;

%imagesc(outputImg);







