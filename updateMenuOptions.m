function updateMenuOptions(handles)

index = handles.pat_index;
patient = handles.patient(index);


l = sum(patient.lungs(:)) > 0;
b = sum(patient.body(:)) > 0;
lm = sum(patient.lungmask(:)) > 0;
bm = sum(patient.bodymask(:)) > 0;

if l
    set(handles.analyze_seglungs, 'Enable', 'on');
else
    set(handles.analyze_seglungs, 'Enable', 'off');
end

if b
    set(handles.analyze_segbody, 'Enable', 'on');
else
    set(handles.analyze_segbody, 'Enable', 'off');
end

if lm
    set(handles.manual_lungmask, 'Enable', 'on');
else
    set(handles.manual_lungmask, 'Enable', 'off');    
end

if bm
    set(handles.manual_bodymask, 'Enable', 'on');
else
    set(handles.manual_bodymask, 'Enable', 'off');
end

if lm && bm
    set(handles.analyze_coreglm, 'Enable', 'on');
    set(handles.viewleft_coreg, 'Enable', 'on');
    set(handles.viewright_coreg, 'Enable', 'on');
else
    set(handles.analyze_coreglm, 'Enable', 'off');
    set(handles.viewleft_coreg, 'Enable', 'off');
    set(handles.viewright_coreg, 'Enable', 'off');
end


    

