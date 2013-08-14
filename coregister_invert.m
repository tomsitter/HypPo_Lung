function tform = coregister_invert(baseImg, imgToRegister, baseMask, maskToRegister)
	
	if sum(baseMask(:))==0||sum(maskToRegister(:))==0
		tform = [];
		return;
	end
	
	baseImg = double(baseImg);
	imgToRegister = double(imgToRegister);
	
	baseImg = (baseImg-min(baseImg(:)))/(max(baseImg(:))-min(baseImg(:)));
	imgToRegister = (imgToRegister-min(imgToRegister(:)))/(max(imgToRegister(:))-min(imgToRegister(:)));
	imgToRegister = 1-imgToRegister;
	
	N = 15;
	dilatedMask = logical(imdilate(maskToRegister, ones(2*N + 1, 2*N + 1)));
	if ~isempty(min(min(imgToRegister(dilatedMask))))
		imgToRegister(logical(1-dilatedMask)) = min(min(imgToRegister(dilatedMask)));
		imgToRegister = (imgToRegister-min(imgToRegister(:)))/(max(imgToRegister(:))-min(imgToRegister(:)));
		imgToRegister(imgToRegister<0.3) = 0.3;%0.8
		imgToRegister = (imgToRegister-min(imgToRegister(:)))/(max(imgToRegister(:))-min(imgToRegister(:)));
	end
	
	filterUnsharp = fspecial('unsharp');
	baseImg = imfilter(baseImg,filterUnsharp);
	imgToRegister = imfilter(imgToRegister,filterUnsharp);
	baseImg = imfilter(baseImg,filterUnsharp);
	
	baseImg(logical(1-baseMask)) = 0;
	%baseImg(baseImg<0.2) = 0;
	
	%{
	%%%% Can experiment with modifying the histogram to make the images
	%%%% more similar
	%imtool(imgToRegister);
	%imtool(baseImg);
	imgToRegister = histeq(imgToRegister);
	baseImg = histeq(baseImg);
	imgToRegister = (imgToRegister-min(imgToRegister(:)))/(max(imgToRegister(:))-min(imgToRegister(:)));
	baseImg = (baseImg-min(baseImg(:)))/(max(baseImg(:))-min(baseImg(:)));
	%imtool(imgToRegister);
	%imtool(baseImg);
	%}
	
	tform = coregister_DFTcrosscorrelation(baseImg, imgToRegister);
	
	%{
	figure
	imshow(baseImg)
	figure
	imshow(imgToRegister)
	%}
	%{
	height = size(imgToRegister,1);
	width = size(imgToRegister,2);
	imgToRegister = imtransform(imgToRegister, tform, 'xdata', [1 width], 'ydata', [1, height]);
	figure
	imshowpair(imgToRegister, baseImg);
	%}
end