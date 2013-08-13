function outputImage = viewOverlay(body, lungs, color)
	outputImage = body;
	outputImage = double(outputImage);
	
	outputImage = repmat(outputImage,[1 1 3]);
	outputImage = (outputImage-min(outputImage(:)))/(max(outputImage(:))-min(outputImage(:)));
	
	lungs = double(lungs);
	if sum(lungs(:))>0
		lungs = (lungs-min(lungs(:)))/(max(lungs(:))-min(lungs(:)));
	end
	
	outputImage(logical([ones(size(lungs)),zeros(size(lungs)),zeros(size(lungs))])) = outputImage(logical([ones(size(lungs)),zeros(size(lungs)),zeros(size(lungs))]))+lungs(:)*color(1);
	outputImage(logical([zeros(size(lungs)),ones(size(lungs)),zeros(size(lungs))])) = outputImage(logical([zeros(size(lungs)),ones(size(lungs)),zeros(size(lungs))]))+lungs(:)*color(2);
	outputImage(logical([zeros(size(lungs)),zeros(size(lungs)),ones(size(lungs))])) = outputImage(logical([zeros(size(lungs)),zeros(size(lungs)),ones(size(lungs))]))+lungs(:)*color(3);
	
	%outputImage(logical([zeros(size(lungs)),zeros(size(lungs)),ones(size(lungs))])) = lungs(:)*color(3);
	
	outputImage = (outputImage-min(outputImage(:)))/(max(outputImage(:))-min(outputImage(:)));
end