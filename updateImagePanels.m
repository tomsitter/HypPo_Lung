function updateImagePanels(handles)

val = max(get(handles.slider_slice, 'Value'), 1);

colormap(gray)
pat_index = handles.pat_index;
viewmode = handles.viewmode;

if strcmp(viewmode, 'LnB')
    %Lung and Body
    %Display lungs on left, body on right
    axes(handles.axes1);
    if not(isempty(handles.patient(pat_index).lung))
        imagesc(handles.patient(pat_index).lung(:, :, val));
    elseif not(isempty(handles.patient(pat_index).body))
        imagesc(handles.patient(pat_index).body(:, :, val));
    else
        updateStatusBox(handles, 'No images loaded', 0);
        return;
    end
    
    axes(handles.axes2);
    if not(isempty(handles.patient(pat_index).body))
        imagesc(handles.patient(pat_index).body(:, :, val));
    else
        imagesc(handles.patient(pat_index).lung(:, :, val));
    end
    
elseif strcmp(viewmode, 'LO')
    %Lungs Only
    %Display lungs on both panels
    if not(isempty(handles.patient(pat_index).lung))
        axes(handles.axes1);
        imagesc(handles.patient(pat_index).lung(:, :, val));

        axes(handles.axes2);
        imagesc(handles.patient(pat_index).lung(:, :, val));
    end
end