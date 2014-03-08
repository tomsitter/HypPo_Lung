function fov = getFOV(parms, numOfSlices)
% NOTE, the order of the dimensions for FOV for coronal slices is not the
% same and this function will not work!!!!!
% For Par/Rec, the fov is [x,y,x], which gives a different orientation
% depending on whether the slices are top-down or from the side
% Need to come up with a way to fix this
	fov = [];
	if isfield(parms,'fov')
		fov = parms.fov;
	elseif isfield(parms,'PixelSpacing')
		width = double(parms.Width); %image width (e.g. 512)
		height = double(parms.Height); %image height (e.g. 512)
		resolution = double(parms.PixelSpacing);
		depth = parms.SliceThickness+(numOfSlices-1)*parms.SpacingBetweenSlices;
		% thickness example
		% ||| ||| ||| |||
		% if every 3 lines are are a slice (with thickness), then the spacing would be the distance between every center line
		% therefore, depth = spacing*(slices-1)+2*(thickness/2)
		fov = [depth, width.*resolution(1), height.*resolution(2)];
		% to match Par/Rec fov order
	end
end