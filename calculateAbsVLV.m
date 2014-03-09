function aVLV = calculateAbsVLV(signalFull, lungParms, lungImageSlice, lungMaskSlice)
	%voxelVolume = (lungParms.fov(3)/lungParms.reconstruction_res(2))*(lungParms.fov(2)/lungParms.reconstruction_res(1))*(lungParms.slice_thickness+lungParms.slice_gap);
	fov = getFOV(lungParms, size(lungImageSlice,3));
	voxelVolume = (fov(2)/size(lungImageSlice,1))*(fov(3)/size(lungImageSlice,2))*(getSliceSpacing(lungParms));
	voxelVolume = voxelVolume/10^3;
	% converting to mL
	vlvRatios = lungImageSlice(logical(lungMaskSlice))/signalFull;
	vlvRatios(vlvRatios>1) = 1;
	aVLV = sum(sum(vlvRatios))*voxelVolume;
end