function updateMenuOptions(handles)

p = size(handles.patient,2)~=0;

if p
	index = handles.pat_index;
	patient = handles.patient(index);
	l = sum(patient.lungs(:)) > 0;
	b = sum(patient.body(:)) > 0;
	lm = sum(patient.lungmask(:)) > 0;
	bm = sum(patient.bodymask(:)) > 0;
	h = nansum(patient.hetero_images(:)) > 0;
else
	l = 0;
	b = 0;
	lm = 0;
	bm = 0;
	h = 0;
end

if ~strcmp(handles.leftpanel,'')
	set(handles.export_left, 'Enable', 'on');
else
	set(handles.export_left, 'Enable', 'off');
end

if ~strcmp(handles.rightpanel,'')
	set(handles.export_right, 'Enable', 'on');
else
	set(handles.export_right, 'Enable', 'off');
end

if p
	set(handles.file_savepatientas, 'Enable', 'on');
	set(handles.file_changepatient, 'Enable', 'on');
	set(handles.view_lungparams, 'Enable', 'on');
	set(handles.file_loadlung, 'Enable', 'on');
	set(handles.file_loadbody, 'Enable', 'on');
else
	set(handles.file_savepatientas, 'Enable', 'off');
	set(handles.file_changepatient, 'Enable', 'off');
	set(handles.view_lungparams, 'Enable', 'off');
	set(handles.file_loadlung, 'Enable', 'off');
	set(handles.file_loadbody, 'Enable', 'off');
end

if l
    set(handles.analyze_seglungs, 'Enable', 'on');
    set(handles.analyze_seglungs_contour, 'Enable', 'on');
	set(handles.calculate_lung_SNR_bounding_box, 'Enable', 'on');
	set(handles.slice_lung_add_beginning, 'Enable', 'on');
	set(handles.slice_lung_add_end, 'Enable', 'on');
	set(handles.slice_lung_remove_beginning, 'Enable', 'on');
	set(handles.slice_lung_remove_end, 'Enable', 'on');
else
    set(handles.analyze_seglungs, 'Enable', 'off');
    set(handles.analyze_seglungs_contour, 'Enable', 'off');
	set(handles.calculate_lung_SNR_bounding_box, 'Enable', 'off');
	set(handles.slice_lung_add_beginning, 'Enable', 'off');
	set(handles.slice_lung_add_end, 'Enable', 'off');
	set(handles.slice_lung_remove_beginning, 'Enable', 'off');
	set(handles.slice_lung_remove_end, 'Enable', 'off');
end

if b
    set(handles.analyze_segbody, 'Enable', 'on');
    set(handles.manual_addseed, 'Enable', 'on');
	set(handles.calculate_body_SNR_bounding_box, 'Enable', 'on');
	set(handles.slice_body_add_beginning, 'Enable', 'on');
	set(handles.slice_body_add_end, 'Enable', 'on');
	set(handles.slice_body_remove_beginning, 'Enable', 'on');
	set(handles.slice_body_remove_end, 'Enable', 'on');
else
    set(handles.analyze_segbody, 'Enable', 'off');
    set(handles.manual_addseed, 'Enable', 'off');
	set(handles.calculate_body_SNR_bounding_box, 'Enable', 'off');
	set(handles.slice_body_add_beginning, 'Enable', 'off');
	set(handles.slice_body_add_end, 'Enable', 'off');
	set(handles.slice_body_remove_beginning, 'Enable', 'off');
	set(handles.slice_body_remove_end, 'Enable', 'off');
end

if l && b
    set(handles.viewleft_overlay, 'Enable', 'on');
    set(handles.viewright_overlay, 'Enable', 'on');
else
    set(handles.viewleft_overlay, 'Enable', 'off');
    set(handles.viewright_overlay, 'Enable', 'off');
end

if lm
    set(handles.manual_lungmask, 'Enable', 'on');
	set(handles.calculate_lung_SNR_segmentation, 'Enable', 'on');
	set(handles.analyze_LV_aVLV, 'Enable', 'on');
	set(handles.analyze_LV_VLV, 'Enable', 'on');
    set(handles.analyze_hetero, 'Enable', 'on');
    set(handles.viewleft_lungmask, 'Enable', 'on');
    set(handles.viewright_lungmask, 'Enable', 'on');
else
    set(handles.manual_lungmask, 'Enable', 'off');
	set(handles.calculate_lung_SNR_segmentation, 'Enable', 'off');
	set(handles.analyze_LV_aVLV, 'Enable', 'off');
	set(handles.analyze_LV_VLV, 'Enable', 'off');
    set(handles.analyze_hetero, 'Enable', 'off');
    set(handles.viewleft_lungmask, 'Enable', 'off');
    set(handles.viewright_lungmask, 'Enable', 'off');
end

if bm
    set(handles.manual_bodymask, 'Enable', 'on');
	set(handles.calculate_body_SNR_segmentation, 'Enable', 'on');
	set(handles.analyze_LV_aTLV, 'Enable', 'on');
	set(handles.analyze_LV_TLV, 'Enable', 'on');
    set(handles.viewleft_bodymask, 'Enable', 'on');
    set(handles.viewright_bodymask, 'Enable', 'on');
else
    set(handles.manual_bodymask, 'Enable', 'off');
	set(handles.calculate_body_SNR_segmentation, 'Enable', 'off');
	set(handles.analyze_LV_aTLV, 'Enable', 'off');
	set(handles.analyze_LV_TLV, 'Enable', 'off');
    set(handles.viewleft_bodymask, 'Enable', 'off');
    set(handles.viewright_bodymask, 'Enable', 'off');
end

if lm && bm
    set(handles.analyze_coreg_lm, 'Enable', 'on');
    set(handles.analyze_coreg_cc, 'Enable', 'on');
    set(handles.analyze_coreg_DFTcc, 'Enable', 'on');
    set(handles.analyze_coreg_remove, 'Enable', 'on');
    set(handles.analyze_coreg_invert, 'Enable', 'on');
    set(handles.analyze_coreg_expand, 'Enable', 'on');
    set(handles.viewleft_coreg, 'Enable', 'on');
    set(handles.viewright_coreg, 'Enable', 'on');
else
    set(handles.analyze_coreg_lm, 'Enable', 'off');
    set(handles.analyze_coreg_cc, 'Enable', 'off');
    set(handles.analyze_coreg_DFTcc, 'Enable', 'off');
    set(handles.analyze_coreg_remove, 'Enable', 'off');
    set(handles.analyze_coreg_invert, 'Enable', 'off');
    set(handles.analyze_coreg_expand, 'Enable', 'off');
    set(handles.viewleft_coreg, 'Enable', 'off');
    set(handles.viewright_coreg, 'Enable', 'off');
end

if h
    set(handles.viewleft_hetero, 'Enable', 'on');
    set(handles.viewright_hetero, 'Enable', 'on');
else
    set(handles.viewleft_hetero, 'Enable', 'off');
    set(handles.viewright_hetero, 'Enable', 'off');
end

if handles.leftpanelcoreg==1
    set(handles.view_left_showcoregistered_yes, 'Checked', 'on');
    set(handles.view_left_showcoregistered_no, 'Checked', 'off');
else
    set(handles.view_left_showcoregistered_yes, 'Checked', 'off');
    set(handles.view_left_showcoregistered_no, 'Checked', 'on');
end

if handles.rightpanelcoreg==1
    set(handles.view_right_showcoregistered_yes, 'Checked', 'on');
    set(handles.view_right_showcoregistered_no, 'Checked', 'off');
else
    set(handles.view_right_showcoregistered_yes, 'Checked', 'off');
    set(handles.view_right_showcoregistered_no, 'Checked', 'on');
end

