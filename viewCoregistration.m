function outputImage = viewCoregistration(body, bodymask, lungmask)
%VIEWCOREGISTRATION Displays overlap of lung and proton mask on proton image

if max(body(:))>1||min(body(:))<0
	error('The body image must have values between 0 and 1.');
end

outputImage = body;
%outputImage = double(outputImage);
outputImage = repmat(outputImage,[1 1 3]);
%outputImage = (outputImage-min(outputImage(:)))/(max(outputImage(:))-min(outputImage(:)));

outputImage = overlayColorOnImageByMask(outputImage, bodymask, [NaN,1,NaN], 0.5);
outputImage = overlayColorOnImageByMask(outputImage, lungmask, [1,NaN,1], 0.5);

%{
imagesc(body);
colormap(gray);
hold on;
overlap = imshowpair(bodymask, lungmask);
alpha(overlap, .4);
hold off;
%}

end