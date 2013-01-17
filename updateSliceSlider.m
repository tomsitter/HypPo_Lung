function updateSliceSlider(hObject, handles)

%Get current patient
pat_index = handles.pat_index;

if not(isempty(handles.patient))
    if not(isempty(handles.patient(pat_index).lung))
        num_lungSlices = size(handles.patient(pat_index).lung, 3);
    else
        num_lungSlices = nan;
    end
    if not(isempty(handles.patient(pat_index).body))
        num_bodySlices = size(handles.patient(pat_index).body, 3);
    else
        num_bodySlices = nan;
    end
end

if num_lungSlices == num_bodySlices
    numSlices = num_lungSlices;
    msg = sprintf('Found %d slices', numSlices);
    updateStatusBox(handles, msg);
else
    if not(isnan(num_bodySlices)) && not(isnan(num_lungSlices))
        updateStatusBox(handles, 'Error: different number of lung and body slices');
    end
    numSlices = min(num_lungSlices, num_bodySlices);
    
    msg = sprintf('Found %d slices', numSlices);
    updateStatusBox(handles, msg);
end

set(handles.slider_slice, 'val', 1);
if numSlices < 2
    set(handles.slider_slice, 'sliderstep', [0, 0]);
    set(handles.slider_slice, 'min', 0);
    set(handles.slider_slice, 'max', 1)
else
    set(handles.slider_slice, 'sliderstep', [1/(numSlices-1), ...
                                             1/(numSlices-1)] );
    set(handles.slider_slice, 'min', 1);
    set(handles.slider_slice, 'max', numSlices)
end
set(handles.slider_slice, 'Visible', 'on');

val = 1;

%Display image
if not(isempty(handles.patient(pat_index).body)) && strcmp(handles.viewmode, 'LnB')
    axes(handles.axes1);
    imagesc(handles.patient(pat_index).lung(:, :, val));

    axes(handles.axes2);
    imagesc(handles.patient(pat_index).body(:, :, val));
else
    axes(handles.axes1);
    imagesc(handles.patient(pat_index).lung(:, :, val));

    axes(handles.axes2);
    imagesc(handles.patient(pat_index).lung(:, :, val));
end

% Update handles structure
guidata(hObject, handles)
