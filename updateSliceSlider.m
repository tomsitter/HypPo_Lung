function updateSliceSlider(hObject, handles)

if not(isempty(handles.patient))
    if not(isempty(handles.patient(1).lung))
        num_lungSlices = size(handles.patient(1).lung, 3);
    else
        num_lungSlices = 1000;
    end
    if not(isempty(handles.patient(1).body))
        num_bodySlices = size(handles.patient(1).body, 3);
    else
        num_bodySlices = 1000;
    end
end

if num_lungSlices == num_bodySlices
    numSlices = num_lungSlices;
else
    updateStatusBox(handles, 'Error: different number of lung and body slices');
    numSlices = min(num_lungSlices, num_bodySlices);
end

set(handles.slider_slice, 'val', 1);
set(handles.slider_slice, 'min', 1);
set(handles.slider_slice, 'max', numSlices)
set(handles.slider_slice, 'sliderstep', [1/(numSlices-1), ...
                                         1/(numSlices-1)] );
set(handles.slider_slice, 'Visible', 'on');

% Update handles structure
guidata(hObject, handles)
