function sliceSpacing = getSliceSpacing(parms)
% separation = thickness + gap
	sliceSpacing = [];
	if isfield(parms,'slice_gap')
		sliceSpacing = parms.slice_thickness+parms.slice_gap;
	elseif isfield(parms,'SpacingBetweenSlices')
		sliceSpacing = parms.SpacingBetweenSlices;
	end
end