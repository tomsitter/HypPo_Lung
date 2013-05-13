function updateSliceSlider(hObject, handles)

%Get current patient
pat_index = handles.pat_index;

if not(isempty(handles.patient))
    if not(isempty(handles.patient(pat_index).lungs))
        num_lungSlices = size(handles.patient(pat_index).lungs, 3);
    else
        num_lungSlices = nan;
    end
    if not(isempty(handles.patient(pat_index).body))
        num_bodySlices = size(handles.patient(pat_index).body, 3);
    else
        num_bodySlices = nan;
    end
else
    return;
end

if num_lungSlices == num_bodySlices
    numSlices = num_lungSlices;
%     msg = sprintf('Found %d slices', numSlices);
%    updateStatusBox(handles, msg, 0);
else
    if not(isnan(num_bodySlices)) && not(isnan(num_lungSlices))
        updateStatusBox(handles, 'Error: different number of lung and body slices', 0);
    end
    %numSlices = min(num_lungSlices, num_bodySlices);
	numSlices = max(num_lungSlices, num_bodySlices);
    if isnan(numSlices)
        numSlices = 0;
    end
    
%     msg = sprintf('Found %d slices', numSlices);
%    updateStatusBox(handles, msg, 0);
end

%TPS, this will likely be user defined
%set(handles.slider_slice, 'val', 1);
%val = 1;

updateImagePanels(handles);

curSlice = max(1, get(handles.slider_slice, 'Value'));
curSlice = min(curSlice, numSlices);

if numSlices < 2
    set(handles.slider_slice, 'sliderstep', [1, 1]);
    set(handles.slider_slice, 'min', 0);
    set(handles.slider_slice, 'max', 1);
    set(handles.slider_slice, 'value', 1);
    set(handles.slider_slice, 'Visible', 'off');
else
    set(handles.slider_slice, 'sliderstep', [1/(numSlices-1), ...
                                             1/(numSlices-1)] );
    set(handles.slider_slice, 'max', numSlices)
    set(handles.slider_slice, 'Value', curSlice); 
    set(handles.slider_slice, 'min', 1);
    set(handles.slider_slice, 'Visible', 'on');
end

% handles.slice_index = currentSlice;

% Update handles structure
guidata(hObject, handles)
