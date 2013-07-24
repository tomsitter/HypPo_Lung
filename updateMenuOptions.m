function updateMenuOptions(handles)

if size(handles.patient,2)~=0
	index = handles.pat_index;
	patient = handles.patient(index);
	l = sum(patient.lungs(:)) > 0;
	b = sum(patient.body(:)) > 0;
	lm = sum(patient.lungmask(:)) > 0;
	bm = sum(patient.bodymask(:)) > 0;
	h = sum(patient.hetero_images(:)) > 0 && isnan(sum(patient.hetero_images(:))) == 0;
else
	l = 0;
	b = 0;
	lm = 0;
	bm = 0;
	h = 0;
end

if l
    set(handles.analyze_seglungs, 'Enable', 'on');
	set(handles.calculate_lung_SNR_bounding_box, 'Enable', 'on');
else
    set(handles.analyze_seglungs, 'Enable', 'off');
	set(handles.calculate_lung_SNR_bounding_box, 'Enable', 'off');
end

if b
    set(handles.analyze_segbody, 'Enable', 'on');
    set(handles.manual_addseed, 'Enable', 'on');
	set(handles.calculate_body_SNR_bounding_box, 'Enable', 'on');
else
    set(handles.analyze_segbody, 'Enable', 'off');
    set(handles.manual_addseed, 'Enable', 'off');
	set(handles.calculate_body_SNR_bounding_box, 'Enable', 'off');
end

if lm
    set(handles.manual_lungmask, 'Enable', 'on');
	set(handles.calculate_lung_SNR_segmentation, 'Enable', 'on');
    set(handles.analyze_hetero, 'Enable', 'on');
    set(handles.viewleft_lungmask, 'Enable', 'on');
    set(handles.viewright_lungmask, 'Enable', 'on');
else
    set(handles.manual_lungmask, 'Enable', 'off');
	set(handles.calculate_lung_SNR_segmentation, 'Enable', 'off');
    set(handles.analyze_hetero, 'Enable', 'off');
    set(handles.viewleft_lungmask, 'Enable', 'off');
    set(handles.viewright_lungmask, 'Enable', 'off');
end

if bm
    set(handles.manual_bodymask, 'Enable', 'on');
	set(handles.calculate_body_SNR_segmentation, 'Enable', 'on');
    set(handles.viewleft_bodymask, 'Enable', 'on');
    set(handles.viewright_bodymask, 'Enable', 'on');
else
    set(handles.manual_bodymask, 'Enable', 'off');
	set(handles.calculate_body_SNR_segmentation, 'Enable', 'off');
    set(handles.viewleft_bodymask, 'Enable', 'off');
    set(handles.viewright_bodymask, 'Enable', 'off');
end

if lm && bm
    set(handles.analyze_coreg_lm, 'Enable', 'on');
    set(handles.analyze_coreg_cc, 'Enable', 'on');
    set(handles.analyze_coreg_DFTcc, 'Enable', 'on');
    set(handles.viewleft_coreg, 'Enable', 'on');
    set(handles.viewright_coreg, 'Enable', 'on');
    set(handles.viewleft_overlay, 'Enable', 'on');
    set(handles.viewright_overlay, 'Enable', 'on');
else
    set(handles.analyze_coreg_lm, 'Enable', 'off');
    set(handles.analyze_coreg_cc, 'Enable', 'off');
    set(handles.analyze_coreg_DFTcc, 'Enable', 'off');
    set(handles.viewleft_coreg, 'Enable', 'off');
    set(handles.viewright_coreg, 'Enable', 'off');
    set(handles.viewleft_overlay, 'Enable', 'off');
    set(handles.viewright_overlay, 'Enable', 'off');
end

if h
    set(handles.viewleft_hetero, 'Enable', 'on');
    set(handles.viewright_hetero, 'Enable', 'on');
else
    set(handles.viewleft_hetero, 'Enable', 'off');
    set(handles.viewright_hetero, 'Enable', 'off');
end


    

