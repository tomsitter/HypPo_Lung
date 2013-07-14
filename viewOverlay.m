function outputImage = viewOverlay(body, lungs)
	outputImage = body;
	outputImage = double(outputImage);
	
	outputImage = repmat(outputImage,[1 1 3]);
	outputImage = (outputImage-min(outputImage(:)))/(max(outputImage(:))-min(outputImage(:)));
	
	lungs = double(lungs);
	if sum(lungs(:))>0
		lungs = (lungs-min(lungs(:)))/(max(lungs(:))-min(lungs(:)));
	end
	
	outputImage(logical([zeros(size(lungs)),zeros(size(lungs)),ones(size(lungs))])) = outputImage(logical([zeros(size(lungs)),zeros(size(lungs)),ones(size(lungs))]))+lungs(:);
	
	outputImage = (outputImage-min(outputImage(:)))/(max(outputImage(:))-min(outputImage(:)));
end