function continueAnyways = displayWarningsAboutBodyMasks(patient)
	continueAnyways = 1;
	if ~isempty(patient.TLV)||~isempty(patient.aTLV)||~isempty(patient.TLV_coreg)||~isempty(patient.aTLV_coreg)
		button = questdlg('If you apply this transformation, your total lung volume calculations will be deleted. Do you want to continue?', 'Warning', 'Continue', 'Cancel', 'Continue');
		if strcmp(button,'Cancel')
			continueAnyways = 0;
		end
	end
end