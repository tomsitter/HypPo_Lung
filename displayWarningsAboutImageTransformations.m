function continueAnyways = displayWarningsAboutImageTransformations(patient)
	continueAnyways = 1;
	if ~isempty(patient.TLV_coreg)||~isempty(patient.aTLV_coreg)
		button = questdlg('If you apply this transformation, your lung volume calculations for coregistered images will be deleted. Do you want to continue?', 'Warning', 'Continue', 'Cancel', 'Continue');
		if strcmp(button,'Cancel')
			continueAnyways = 0;
		end
	end
end