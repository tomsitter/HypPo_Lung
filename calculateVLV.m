function VLV = calculateVLV(lungParms, lungMaskSlice)
	%voxelVolume = (lungParms.fov(3)/lungParms.reconstruction_res(2))*(lungParms.fov(2)/lungParms.reconstruction_res(1))*(lungParms.slice_thickness+lungParms.slice_gap);
	fov = getFOV(lungParms, size(lungMaskSlice,3));
	voxelVolume = (fov(2)/size(lungMaskSlice,1))*(fov(3)/size(lungMaskSlice,2))*(getSliceSpacing(lungParms));
	voxelVolume = voxelVolume/10^3;
	% converting to mL
	VLV = sum(sum(lungMaskSlice*voxelVolume));
end