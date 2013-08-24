function numOfSlices = getNumOfSlices(patient, imageType)
	numOfSlices = NaN;
	switch imageType
		case 'L'
			if sum(patient.lungs(:))>0
				numOfSlices = size(patient.lungs, 3);
			end
		case 'LM'
			if sum(patient.lungmask(:))>0
				numOfSlices = size(patient.lungmask, 3);
			end
		case 'B'
			if sum(patient.body(:))>0
				numOfSlices = size(patient.body, 3);
			end
		case 'BM'
			if sum(patient.bodymask(:))>0
				numOfSlices = size(patient.bodymask, 3);
			end
		case 'C'
			if sum(patient.lungmask(:))>0||sum(patient.bodymask(:))>0
				numOfSlices = min(size(patient.lungmask, 3),size(patient.bodymask, 3));
			end
		case 'H'
			if nansum(patient.hetero_images(:))>0
				numOfSlices = size(patient.hetero_images, 3);
			end
		case 'O'
			if sum(patient.lungs(:))>0||sum(patient.body(:))>0
				numOfSlices = min(size(patient.lungs, 3),size(patient.body, 3));
			end
		case ''
		otherwise
			error('Unknown image state for panel: %s', imageType);
	end
end