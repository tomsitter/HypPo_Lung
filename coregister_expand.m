function tform = coregister_expand(baseImg, imgToRegister)
	
	if sum(baseImg(:))==0||sum(imgToRegister(:))==0
		tform = [];
		return;
	end
	
	%global N;
	%if isempty(N)
	N = 5;
	%end
	baseImg = imdilate(baseImg, ones(2*N + 1, 2*N + 1));
	imgToRegister = imdilate(imgToRegister, ones(2*N + 1, 2*N + 1));
	% expand the mask
	
	%global F;
	%global A;
	A = 8;
	%if F
	G = fspecial('average',[A A]);%8 is best for average filter
	baseImg = imfilter(baseImg,G);
	imgToRegister = imfilter(imgToRegister,G);
	% blur the edges to remove weighting from the edges
	%end
	
	tform = coregister_DFTcrosscorrelation(baseImg, imgToRegister);
	
	%{
	height = size(imgToRegister,1);
	width = size(imgToRegister,2);
	imgToRegister = imtransform(imgToRegister, tform, 'xdata', [1 width], 'ydata', [1, height]);
	figure
	imshowpair(imgToRegister, baseImg);
	%}
end