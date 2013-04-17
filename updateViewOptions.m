function updateViewOptions(handles)

if isempty(handles.patient)
    return
end

pat_index = handles.pat_index;
patient = handles.patient(pat_index);

if not(isempty(patient.lungs))
    set(handles.viewright_lungs, 'Enable', 'on');
    set(handles.viewleft_lungs, 'Enable', 'on');
else
    set(handles.viewright_lungs, 'Enable', 'off');
    set(handles.viewleft_lungs, 'Enable', 'off');
end

if not(isempty(patient.body))
    set(handles.viewright_body, 'Enable', 'on');
    set(handles.viewleft_body, 'Enable', 'on');
else
    set(handles.viewright_body, 'Enable', 'off');
    set(handles.viewleft_body, 'Enable', 'off');
end
if not(isempty(patient.lungmask))
    set(handles.viewright_lungmask, 'Enable', 'on');
    set(handles.viewleft_lungmask, 'Enable', 'on');
else
    set(handles.viewright_lungmask, 'Enable', 'off');
    set(handles.viewleft_lungmask, 'Enable', 'off');
end
if not(isempty(patient.bodymask))
    set(handles.viewright_bodymask, 'Enable', 'on');
    set(handles.viewleft_bodymask, 'Enable', 'on');
else
    set(handles.viewright_bodymask, 'Enable', 'off');
    set(handles.viewleft_bodymask, 'Enable', 'off');
end