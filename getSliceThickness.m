function sliceThickness = getSliceThickness(parms)
	sliceThickness = [];
	if isfield(parms,'slice_thickness')
		sliceThickness = parms.slice_thickness;
	elseif isfield(parms,'SliceThickness')
		sliceThickness = parms.SliceThickness;
	end
end