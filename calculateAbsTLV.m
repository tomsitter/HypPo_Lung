function aTLV = calculateAbsTLV(maxSignalH, bodyParms, bodyImageSlice, bodyMaskSlice)
	maxSignalH = double(maxSignalH);
	voxelVolume = (bodyParms.fov(3)/bodyParms.reconstruction_res(2))*(bodyParms.fov(2)/bodyParms.reconstruction_res(1))*(bodyParms.slice_thickness+bodyParms.slice_gap);
	voxelVolume = voxelVolume/10^3;
	% converting to mL
	tlvRatios = (maxSignalH-double(bodyImageSlice(logical(bodyMaskSlice))))/maxSignalH;
	tlvRatios(tlvRatios>1) = 1;
	aTLV = sum(sum(tlvRatios))*voxelVolume;
end