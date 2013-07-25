function patient = applyImageTransformationToPatientData(patient, tform, slice)
	if tform.tdata.T == eye(3);
		patient.tform{slice} = [];
		patient.body_coreg(:,:,slice) = 0;
		patient.bodymask_coreg(:,:,slice) = 0;
	else
		patient.tform{slice} = tform;
		height = size(patient.body,1);
		width = size(patient.body,2);
		patient.body_coreg(:,:,slice) = imtransform(patient.body(:,:,slice), tform, 'xdata', [1 width], 'ydata', [1, height]);
		patient.bodymask_coreg(:,:,slice) = round(imtransform(patient.bodymask(:,:,slice), tform, 'xdata', [1 width], 'ydata', [1, height]));
	end
end