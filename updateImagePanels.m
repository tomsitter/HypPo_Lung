function handles = updateImagePanels(handles)

%correct slider to integer number
sliderValue = get(handles.slider_slice,'Value');
sliderValue = round(sliderValue);
set(handles.slider_slice,'Value',sliderValue);

slice = max(get(handles.slider_slice, 'Value'), 1);

slice_str = sprintf('Slice: %d', slice);

set(handles.text_slice, 'String', slice_str);

colormap(gray);
pat_index = handles.pat_index;

lungSliceOffset = 0;
bodySliceOffset = 0;
bothSliceOffset = 0;

if isempty(handles.patient)==0
	if strcmp(getappdata(handles.slice_offset, 'position'),'beginning')
		if size(handles.patient(pat_index).lungs, 3)>size(handles.patient(pat_index).bodymask, 3)
			lungSliceOffset = 0;
			bodySliceOffset = abs(size(handles.patient(pat_index).lungs, 3)-size(handles.patient(pat_index).bodymask, 3));
		else
			lungSliceOffset = abs(size(handles.patient(pat_index).lungs, 3)-size(handles.patient(pat_index).bodymask, 3));
			bodySliceOffset = 0;
		end
		%
		if strcmp(getappdata(handles.extra_slices, 'show'),'true')
			bothSliceOffset = 0;
		else
			bothSliceOffset = abs(size(handles.patient(pat_index).lungs, 3)-size(handles.patient(pat_index).bodymask, 3));
		end
	end
end
%Check if there are are any patients
%If not, set checkerboard images and return
if isempty(handles.patient)
    axes(handles.axes1);
    imagesc(gray);
    axes(handles.axes2);
    imagesc(gray);
    return;
end

patient = handles.patient(pat_index);

% the following code keeps the same panel if it exists in the patient data,
% if not, it sets the panel to empty
switch handles.leftpanel
	case 'L'
		if sum(patient.lungs(:))<=0
			handles.leftpanel = '';
		end
	case 'LM'
		if sum(patient.lungmask(:))<=0
			handles.leftpanel = '';
		end
	case 'B'
		if sum(patient.body(:))<=0
			handles.leftpanel = '';
		end
	case 'BM'
		if sum(patient.bodymask(:))<=0
			handles.leftpanel = '';
		end
	case 'C'
		if sum(patient.lungmask(:))<=0&&sum(patient.bodymask(:))<=0
			handles.leftpanel = '';
		end
	case 'H'
		if sum(patient.hetero_images(:))<=0||isnan(sum(patient.hetero_images(:)))==1
			handles.leftpanel = '';
		end
	case ''
		if sum(patient.lungs(:))>0
			handles.leftpanel = 'L';
		end
	otherwise
		error('Unknown image state for left panel: %s', handles.leftpanel);
end

switch handles.rightpanel
	case 'L'
		if sum(patient.lungs(:))<=0
			handles.rightpanel = '';
		end
	case 'LM'
		if sum(patient.lungmask(:))<=0
			handles.rightpanel = '';
		end
	case 'B'
		if sum(patient.body(:))<=0
			handles.rightpanel = '';
		end
	case 'BM'
		if sum(patient.bodymask(:))<=0
			handles.rightpanel = '';
		end
	case 'C'
		if sum(patient.lungmask(:))<=0&&sum(patient.bodymask(:))<=0
			handles.rightpanel = '';
		end
	case 'H'
		if sum(patient.hetero_images(:))<=0||isnan(sum(patient.hetero_images(:)))==1
			handles.rightpanel = '';
		end
	case ''
		if sum(patient.body(:))>0
			handles.rightpanel = 'B';
		end
	otherwise
		error('Unknown image state for right panel: %s', handles.rightpanel);
end

leftpanel = handles.leftpanel;
rightpanel = handles.rightpanel;

axes(handles.axes1);
switch leftpanel
	case ''
		imagesc(gray);
		title('');
    case 'L'
        numslices = size(handles.patient(pat_index).lungs, 3);
		tslice = slice-lungSliceOffset+bothSliceOffset;
        %tslice = min(slice, numslices);
		if tslice>numslices || tslice<=0
			imagesc(gray);
		else
			if not(isempty(handles.patient(pat_index).lungs))
				imagesc(handles.patient(pat_index).lungs(:, :, tslice));
			else
				updateStatusBox(handles, 'No lung images loaded', 0);
				imagesc(gray);
			end
		end
        title('Lungs');
    case 'LM'
        numslices = size(handles.patient(pat_index).lungmask, 3);
		tslice = slice-lungSliceOffset+bothSliceOffset;
        %tslice = min(slice, numslices);
		if tslice>numslices || tslice<=0
			imagesc(gray);
		else
			if not(isempty(handles.patient(pat_index).lungmask))
				lungs = handles.patient(pat_index).lungs(:, :, tslice);
				lungmask = handles.patient(pat_index).lungmask(:, :, tslice);
				maskOverlay(lungs, lungmask);
				%imagesc(handles.patient(pat_index).lungmask(:, :, val));
			else
				updateStatusBox(handles, 'No lung mask found', 0);
				imagesc(gray);
			end
		end
        title('Lung Mask');
    case 'B'
        numslices = size(handles.patient(pat_index).body, 3);
		tslice = slice-bodySliceOffset+bothSliceOffset;
        %tslice = min(slice, numslices);
		if tslice>numslices || tslice<=0
			imagesc(gray);
		else
			if not(isempty(handles.patient(pat_index).body))
				imagesc(handles.patient(pat_index).body(:, :, tslice));
			else
				updateStatusBox(handles, 'No body images loaded', 0);
				imagesc(gray);
			end
		end
        title('Proton');
    case 'BM'
        numslices = size(handles.patient(pat_index).bodymask, 3);
		tslice = slice-bodySliceOffset+bothSliceOffset;
        %tslice = min(slice, numslices);
		if tslice>numslices || tslice<=0
			imagesc(gray);
		else
			if not(isempty(handles.patient(pat_index).bodymask))
	%             imagesc(handles.patient(pat_index).bodymask(:, :, val));
				body = handles.patient(pat_index).body(:, :, tslice);
				bodymask = handles.patient(pat_index).bodymask(:, :, tslice);
				maskOverlay(body, bodymask);
			else
				updateStatusBox(handles, 'No body mask found', 0);
				imagesc(gray);
			end
		end
        title('Proton Mask');
    case 'C'
        body = handles.patient(pat_index).body(:, :, slice);
        bodymask = handles.patient(pat_index).bodymask(:, :, slice);
        lungmask = handles.patient(pat_index).lungmask(:, :, slice);
        viewCoregistration(body, bodymask, lungmask);
        title('Coregistration');
    case 'H'
        numslices = size(handles.patient(pat_index).hetero_images, 3);
        tslice = min(slice, numslices);  
        if not(isempty(handles.patient(pat_index).hetero_images(:, :, tslice)));
            imshow(handles.patient(pat_index).hetero_images(:, :, tslice));
        else
            updateStatusBox(handles, 'No heterogeneity map', 0);
            imagesc(gray);          
        end
        title('Heterogeneity');
    otherwise
        msg = sprintf('Unknown image state for left panel: %s', leftpanel);
        updateStatusBox(handles,msg, 1);
        title('');
end

axes(handles.axes2);
switch rightpanel
	case ''
		imagesc(gray);
		title('');
    case 'L'
        numslices = size(handles.patient(pat_index).lungs, 3);
        tslice = slice-lungSliceOffset+bothSliceOffset;
		%tslice = min(slice, numslices);
		if tslice>numslices || tslice<=0
			imagesc(gray);
		else
			if not(isempty(handles.patient(pat_index).lungs))
				imagesc(handles.patient(pat_index).lungs(:, :, tslice));
			else
				updateStatusBox(handles, 'No lung images loaded', 0);
				imagesc(gray);
			end
		end
        title('Lungs');
    case 'LM'
        numslices = size(handles.patient(pat_index).lungmask, 3);
        tslice = slice-lungSliceOffset+bothSliceOffset;
		%tslice = min(slice, numslices);
		if tslice>numslices || tslice<=0
			imagesc(gray);
		else
			if not(isempty(handles.patient(pat_index).lungmask))
	%                 imagesc(handles.patient(pat_index).lungmask(:, :, val));
				lungs = handles.patient(pat_index).lungs(:, :, tslice);
				lungmask = handles.patient(pat_index).lungmask(:, :, tslice);
				maskOverlay(lungs, lungmask);
			else
				updateStatusBox(handles, 'No lung mask', 0);
				imagesc(gray);
			end
		end
        title('Lung Mask');
    case 'B'
        numslices = size(handles.patient(pat_index).body, 3);
        tslice = slice-bodySliceOffset+bothSliceOffset;
		%tslice = min(slice, numslices);
		if tslice>numslices || tslice<=0
			imagesc(gray);
		else
			if not(isempty(handles.patient(pat_index).body))
				imagesc(handles.patient(pat_index).body(:, :, tslice));
			else
				updateStatusBox(handles, 'No body images loaded', 0);
				imagesc(gray);
			end
		end
        title('Proton');
    case 'BM'
        numslices = size(handles.patient(pat_index).bodymask, 3);
        tslice = slice-bodySliceOffset+bothSliceOffset;
        %tslice = min(slice, numslices);
		if tslice>numslices || tslice<=0
			imagesc(gray);
		else
			if not(isempty(handles.patient(pat_index).bodymask))
	%             imagesc(handles.patient(pat_index).bodymask(:, :, val));
				body = handles.patient(pat_index).body(:, :, tslice);
				bodymask = handles.patient(pat_index).bodymask(:, :, tslice);
				maskOverlay(body, bodymask);
			else
				updateStatusBox(handles, 'No body mask', 0);
				imagesc(gray);
			end
		end
        title('Proton Mask');
    case 'C'
        body = handles.patient(pat_index).body(:, :, slice);
        bodymask = handles.patient(pat_index).bodymask(:, :, slice);
        lungmask = handles.patient(pat_index).lungmask(:, :, slice);
        viewCoregistration(body, bodymask, lungmask);
        title('Coregistration');
    case 'H'
        numslices = size(handles.patient(pat_index).hetero_images, 3);
        tslice = min(slice, numslices);  
        if not(isempty(handles.patient(pat_index).hetero_images(:, :, tslice)));
            imshow(handles.patient(pat_index).hetero_images(:, :, tslice));
            bw = 0;
            if bw==1
                map = [1 1 1; 0.92 0.92 0.92; 0.84 0.84 0.84; 0.76 0.76 0.76; 0.68 0.68 0.68; 0.6 0.6 0.6; ...
                       0.52 0.52 0.52; 0.44 0.44 0.44; 0.36 0.36 0.36; 0.28 0.28 0.28; 0.2 0.2 0.2; 0 0 0];
            else
                map = [0 0 0; 1/3 0 1/2; 0 0 1; 0 1/2 1; 0 1 1; 0 1 0; ...
                       2/3 1 0; 1 1 0; 1 3/4 0; 1 1/2 0; 1 0 0; 0.85 0 0];
            end
            colormap(map);
        else
            updateStatusBox(handles, 'No heterogeneity map', 0);
            imagesc(gray);          
        end
        title('Heterogeneity');
    otherwise
        msg = sprintf('Unknown image state for right panel: %s', rightpanel);
        updateStatusBox(handles,msg, 1);
        title('');
end