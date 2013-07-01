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
		if nansum(patient.hetero_images(:))<=0
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

panels = cell(1,1);
panels{1} = {leftpanel,handles.axes1};
panels{2} = {rightpanel,handles.axes2};

for a=1:size(panels,2)
	axes(panels{a}{2});
	switch panels{a}{1}
		case ''
			imagesc(gray);
			title('');
		case 'L'
			numslices = size(handles.patient(pat_index).lungs, 3);
			tslice = slice;
			if tslice>numslices || tslice<=0
				imagesc(gray);
			else
				if not(isempty(handles.patient(pat_index).lungs))
					imSlice = handles.patient(pat_index).lungs(:, :, tslice);
					if sum(imSlice(:))~=0
						imagesc(imSlice);
					else
						imagesc(imSlice,[0,1]);
					end
				else
					updateStatusBox(handles, 'No lung images loaded', 0);
					imagesc(gray);
				end
			end
			title('Lungs');
		case 'LM'
			numslices = size(handles.patient(pat_index).lungmask, 3);
			tslice = slice;
			if tslice>numslices || tslice<=0
				imagesc(gray);
			else
				if not(isempty(handles.patient(pat_index).lungmask))
					imSlice = handles.patient(pat_index).lungs(:, :, tslice);
					if sum(imSlice(:))~=0
						lungs = handles.patient(pat_index).lungs(:, :, tslice);
						lungmask = handles.patient(pat_index).lungmask(:, :, tslice);
						maskOverlay(lungs, lungmask);
						%imagesc(handles.patient(pat_index).lungmask(:, :, val));
					else
						imagesc(imSlice,[0,1]);
					end
				else
					updateStatusBox(handles, 'No lung mask found', 0);
					imagesc(gray);
				end
			end
			title('Lung Mask');
		case 'B'
			numslices = size(handles.patient(pat_index).body, 3);
			tslice = slice;
			if tslice>numslices || tslice<=0
				imagesc(gray);
			else
				if not(isempty(handles.patient(pat_index).body))
					imSlice = handles.patient(pat_index).body(:, :, tslice);
					if sum(imSlice(:))~=0
						imagesc(imSlice);
					else
						imagesc(imSlice,[0,1]);
					end
				else
					updateStatusBox(handles, 'No body images loaded', 0);
					imagesc(gray);
				end
			end
			title('Proton');
		case 'BM'
			numslices = size(handles.patient(pat_index).bodymask, 3);
			tslice = slice;
			if tslice>numslices || tslice<=0
				imagesc(gray);
			else
				if not(isempty(handles.patient(pat_index).bodymask))
					imSlice = handles.patient(pat_index).body(:, :, tslice);
					if sum(imSlice(:))~=0
						body = handles.patient(pat_index).body(:, :, tslice);
						bodymask = handles.patient(pat_index).bodymask(:, :, tslice);
						maskOverlay(body, bodymask);
						%imagesc(handles.patient(pat_index).bodymask(:, :, val));
					else
						imagesc(imSlice,[0,1]);
					end
				else
					updateStatusBox(handles, 'No body mask found', 0);
					imagesc(gray);
				end
			end
			title('Proton Mask');
		case 'C'
			if slice>size(handles.patient(pat_index).bodymask, 3) || slice<=0
				imagesc(gray);
			else
				if slice>size(handles.patient(pat_index).lungmask, 3) || slice<=0
					imagesc(gray);
				else
					body = handles.patient(pat_index).body(:, :, slice);
					bodymask = handles.patient(pat_index).bodymask(:, :, slice);
					lungmask = handles.patient(pat_index).lungmask(:, :, slice);
					viewCoregistration(body, bodymask, lungmask);
				end
			end
				title('Coregistration');
		case 'H'
			numslices = size(handles.patient(pat_index).hetero_images, 3);
			tslice = slice;
			if tslice>numslices || tslice<=0
				imagesc(gray);
			else
				if not(isempty(handles.patient(pat_index).hetero_images(:, :, tslice)));
					imSlice = handles.patient(pat_index).hetero_images(:, :, tslice);
					if sum(imSlice(:))~=0
						imshow(imSlice);
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
						imagesc(imSlice,[0,1]);
					end
				else
					updateStatusBox(handles, 'No heterogeneity map', 0);
					imagesc(gray);          
				end
			end
			title('Heterogeneity');
		otherwise
			msg = sprintf('Unknown image state for panel: %s', panels(a,1));
			updateStatusBox(handles,msg, 1);
			title('');
	end
end