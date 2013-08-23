function handles = updateSliceSlider(handles)

%correct slider to integer number
sliderValue = get(handles.slider_slice,'Value');
sliderValue = round(sliderValue);
set(handles.slider_slice,'Value',sliderValue);

%Get current patient
pat_index = handles.pat_index;

if isempty(handles.patient)
	return;
end

handles = updateImagePanels(handles);

patient = handles.patient(pat_index);
panels = cell(1,1);
panels{1} = {handles.leftpanel,nan};
panels{2} = {handles.rightpanel,nan};
%
for a=1:size(panels,2)
	panels{a}{2} = getNumOfSlices(patient, panels{a}{1});
end
%
num_slices_left = panels{1}{2};
num_slices_right = panels{2}{2};

numSlices = max(num_slices_left, num_slices_right);
if isnan(numSlices)
	numSlices = 0;
end

%TPS, this will likely be user defined
%set(handles.slider_slice, 'val', 1);
%val = 1;

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

handles = updateImagePanels(handles);

% handles.slice_index = currentSlice;

% Update handles structure
%guidata(hObject, handles)
