function aVLV = calculateAbsVLV(signalFull, lungParms, lungImageSlice, lungMaskSlice)
	voxelVolume = (lungParms.fov(3)/lungParms.reconstruction_res(2))*(lungParms.fov(2)/lungParms.reconstruction_res(1))*(lungParms.slice_thickness+lungParms.slice_gap);
	voxelVolume = voxelVolume/10^3;
	% converting to mL
	vlvRatios = lungImageSlice(logical(lungMaskSlice))/signalFull;
	vlvRatios(vlvRatios>1) = 1;
	aVLV = sum(sum(vlvRatios))*voxelVolume;
end