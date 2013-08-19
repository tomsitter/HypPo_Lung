function continueAnyways = displayWarningsAboutLungMasks(patient)
	continueAnyways = 1;
	if ~isempty(patient.VLV)||~isempty(patient.aVLV)
		button = questdlg('If you apply this transformation, your ventilated lung volume calculations will be deleted. Do you want to continue?', 'Warning', 'Continue', 'Cancel', 'Continue');
		if strcmp(button,'Cancel')
			continueAnyways = 0;
		end
	end
end