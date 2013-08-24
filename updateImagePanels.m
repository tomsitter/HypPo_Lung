function handles = updateImagePanels(handles, sliderUpdatePntr)

if nargin<2
	sliderUpdatePntr = [];
end

if ~isempty(sliderUpdatePntr)
	%%%%%%sliderUpdatePntr.Value = sliderUpdatePntr.Value+1;
	%%%%%%thisPntrValue = sliderUpdatePntr.Value;
	if sliderUpdatePntr.Value
		return
	else
		sliderUpdatePntr.Value = 1;
	end
	% the purpose of the pointer is to make sure that the slices are not
	% overwritten (an explanation is given in maingui.m in the OpeningFcn)
else
	%%%%%%thisPntrValue = [];
end

slice = round(max(get(handles.slider_slice, 'Value'), 1));
slice_str = sprintf('Slice: %d', slice);
set(handles.text_slice, 'String', slice_str);

set(handles.figure1, 'HandleVisibility', 'on');
% need this line for axes to work while dragging the slider (not sure why)

pat_index = handles.pat_index;

%Check if there are are any patients
%If not, set checkerboard images and return
if isempty(handles.patient)
    axes(handles.axes1);
    imagesc(gray);
	colormap(gray);
    axes(handles.axes2);
    imagesc(gray);
	colormap(gray);
    return;
end

% patient = handles.patient(pat_index);

% the following code keeps the same panel if it exists in the patient data,
% if not, it sets the panel to empty
patient = handles.patient(pat_index);
panels = cell(1);
panels{1} = {handles.leftpanel,'L'};
panels{2} = {handles.rightpanel,'B'};
% the second element is the default if the panel is blank
a = 1;
while a<=size(panels,2)
	% used a while loop instead so that we can go backwards in the loop if
	% we need to
	switch panels{a}{1}
		case 'L'
			if sum(patient.lungs(:))<=0
				panels{a}{1} = '';
			end
		case 'LM'
			if sum(patient.lungmask(:))<=0
				panels{a}{1} = '';
			end
		case 'B'
			if sum(patient.body(:))<=0
				panels{a}{1} = '';
			end
		case 'BM'
			if sum(patient.bodymask(:))<=0
				panels{a}{1} = '';
			end
		case 'C'
			if sum(patient.lungmask(:))<=0&&sum(patient.bodymask(:))<=0
				panels{a}{1} = '';
			end
		case 'H'
			if nansum(patient.hetero_images(:))<=0
				panels{a}{1} = '';
			end
		case 'O'
			if sum(patient.lungs(:))<=0&&sum(patient.body(:))<=0
				panels{a}{1} = '';
			end
		case ''
			% if the panel is empty, set it to the default view and
			% decrease the loop counter to repeat this panel. This will
			% allow the loop to validate and make sure that it is possible
			% to show the default panel
			panels{a}{1} = panels{a}{2};
			a = a-1;
		otherwise
			error('Unknown image state for panel: %s', panels{a}{1});
	end
	a = a+1;
end
handles.leftpanel = panels{1}{1};
handles.rightpanel = panels{2}{1};

leftpanel = handles.leftpanel;
rightpanel = handles.rightpanel;

panels = cell(1,1);
panels{1} = {leftpanel,handles.axes1,~(handles.overridepanelnocoreg||~handles.leftpanelcoreg)};
panels{2} = {rightpanel,handles.axes2,~(handles.overridepanelnocoreg||~handles.rightpanelcoreg)};
% determines whether or not to show the coregistration depending on if
% there is an override

axesChanged = 0;

for a=1:size(panels,2)
	axes(panels{a}{2});
	initData = get(imhandles(panels{a}{2}),'CData');
	
	switch panels{a}{1}
		case ''
			imagesc(gray);
			title('');
		case 'L'
			numslices = size(handles.patient(pat_index).lungs, 3);
			if slice>numslices || slice<=0
				imagesc(gray);
			else
				if not(isempty(handles.patient(pat_index).lungs))
					% if there are lung images
					currentSlice = handles.patient(pat_index).lungs(:, :, slice);
					if ~isequal(currentSlice,get(imhandles(panels{a}{2}),'CData'))
						% if the data has changed
						%{
						if ~isempty(sliderUpdatePntr)
							% if the pointer was given as a parameter
							if sliderUpdatePntr.Value==thisPntrValue
								% if the pointer value was not changed
								updateSlice = 1;
							else
								% if the pointer value was changed, don't
								% update the image or you'll overwite the
								% change
								updateSlice = 0;
							end
						else
							% the pointer was not given, so always update
							% the image slice
							updateSlice = 1;
						end
						%}
						updateSlice = 1;
						if updateSlice
							% if the above is true
							imagesc(currentSlice);
							if sum(currentSlice(:))==0
								% if the slice is completely black
								set(panels{a}{2}, 'clim', [0,1]);
							end
						end
					end
				else
					updateStatusBox(handles, 'No lung images loaded', 0);
					imagesc(gray);
				end
			end
			title('Lungs');
		case 'LM'
			numslices = size(handles.patient(pat_index).lungmask, 3);
			if slice>numslices || slice<=0
				imagesc(gray);
			else
				if not(isempty(handles.patient(pat_index).lungmask))
					% if there are lung mask images
					lungs = handles.patient(pat_index).lungs(:, :, slice);
					lungs = double(lungs);
					lungs = (lungs-min(lungs(:)))/(max(lungs(:))-min(lungs(:)));
					lungmask = handles.patient(pat_index).lungmask(:, :, slice);
					currentSlice = maskOverlay(lungs, lungmask);
					if ~isequal(currentSlice,get(imhandles(panels{a}{2}),'CData'))
						% if the data has changed
						%{
						if ~isempty(sliderUpdatePntr)
							% if the pointer was given as a parameter
							if sliderUpdatePntr.Value==thisPntrValue
								% if the pointer value was not changed
								updateSlice = 1;
							else
								% if the pointer value was changed, don't
								% update the image or you'll overwite the
								% change
								updateSlice = 0;
							end
						else
							% the pointer was not given, so always update
							% the image slice
							updateSlice = 1;
						end
						%}
						updateSlice = 1;
						if updateSlice
							% if the above is true
							imagesc(currentSlice);
							if sum(currentSlice(:))==0
								% if the slice is completely black
								set(panels{a}{2}, 'clim', [0,1]);
							end
						end
					end
				else
					updateStatusBox(handles, 'No lung mask found', 0);
					imagesc(gray);
				end
			end
			title('Lung Mask');
		case 'B'
			coregisteredTitle = 0;
			numslices = size(handles.patient(pat_index).body, 3);
			if slice>numslices || slice<=0
				imagesc(gray);
			else
				if not(isempty(handles.patient(pat_index).body))
					% if there are body images
					if panels{a}{3}&&sum(sum(handles.patient(pat_index).body_coreg(:, :, slice)))
						currentSlice = handles.patient(pat_index).body_coreg(:, :, slice);
						coregisteredTitle = 1;
					else
						currentSlice = handles.patient(pat_index).body(:, :, slice);
					end
					%{
					if panels{a}{3}&&slice<=size(patient(pat_index).tform,2)&&~isempty(patient(pat_index).tform{slice})
						% if the panel is set to show coregistered images and the tform exists
						height = size(currentSlice,1);
						width = size(currentSlice,2);
						currentSlice = imtransform(currentSlice, patient(pat_index).tform{slice}, 'XYScale', 1, 'XData',[1 width],'YData',[1 height]);
					end
					%}
					if ~isequal(currentSlice,get(imhandles(panels{a}{2}),'CData'))
						% if the data has changed
						%{
						if ~isempty(sliderUpdatePntr)
							% if the pointer was given as a parameter
							if sliderUpdatePntr.Value==thisPntrValue
								% if the pointer value was not changed
								updateSlice = 1;
							else
								% if the pointer value was changed, don't
								% update the image or you'll overwite the
								% change
								updateSlice = 0;
							end
						else
							% the pointer was not given, so always update
							% the image slice
							updateSlice = 1;
						end
						%}
						updateSlice = 1;
						if updateSlice
							% if the above is true
							imagesc(currentSlice);
							if sum(currentSlice(:))==0
								% if the slice is completely black
								set(panels{a}{2}, 'clim', [0,1]);
							end
						end
					end
				else
					updateStatusBox(handles, 'No body images loaded', 0);
					imagesc(gray);
				end
			end
			if coregisteredTitle
				title('Coregistered Proton');
			else
				title('Proton');
			end
		case 'BM'
			coregisteredTitle = 0;
			numslices = size(handles.patient(pat_index).bodymask, 3);
			if slice>numslices || slice<=0
				imagesc(gray);
			else
				if not(isempty(handles.patient(pat_index).bodymask))
					% if there are body mask images
					if panels{a}{3}&&sum(sum(handles.patient(pat_index).body_coreg(:, :, slice)))
						body = handles.patient(pat_index).body_coreg(:, :, slice);
						bodymask = handles.patient(pat_index).bodymask_coreg(:, :, slice);
						coregisteredTitle = 1;
					else
						body = handles.patient(pat_index).body(:, :, slice);
						bodymask = handles.patient(pat_index).bodymask(:, :, slice);
					end
					body = double(body);
					body = (body-min(body(:)))/(max(body(:))-min(body(:)));
					currentSlice = maskOverlay(body, bodymask);
					%{
					if panels{a}{3}&&slice<=size(patient(pat_index).tform,2)&&~isempty(patient(pat_index).tform{slice})
						% if the panel is set to show coregistered images and the tform exists
						height = size(currentSlice,1);
						width = size(currentSlice,2);
						currentSlice = imtransform(currentSlice, patient(pat_index).tform{slice}, 'XYScale', 1, 'XData',[1 width],'YData',[1 height]);
					end
					%}
					if ~isequal(currentSlice,get(imhandles(panels{a}{2}),'CData'))
						% if the data has changed
						%{
						if ~isempty(sliderUpdatePntr)
							% if the pointer was given as a parameter
							if sliderUpdatePntr.Value==thisPntrValue
								% if the pointer value was not changed
								updateSlice = 1;
							else
								% if the pointer value was changed, don't
								% update the image or you'll overwite the
								% change
								updateSlice = 0;
							end
						else
							% the pointer was not given, so always update
							% the image slice
							updateSlice = 1;
						end
						%}
						updateSlice = 1;
						if updateSlice
							% if the above is true
							imagesc(currentSlice);
							if sum(currentSlice(:))==0
								% if the slice is completely black
								set(panels{a}{2}, 'clim', [0,1]);
							end
						end
					end
				else
					updateStatusBox(handles, 'No body mask found', 0);
					imagesc(gray);
				end
			end
			if coregisteredTitle
				title('Coregistered Proton Mask');
			else
				title('Proton Mask');
			end
		case 'C'
			coregisteredTitle = 0;
			if slice>size(handles.patient(pat_index).bodymask, 3) || slice<=0
				imagesc(gray);
			else
				if slice>size(handles.patient(pat_index).lungmask, 3) || slice<=0
					imagesc(gray);
				else
					% if there are body mask and lung mask images
					lungmask = handles.patient(pat_index).lungmask(:, :, slice);
					if panels{a}{3}&&sum(sum(handles.patient(pat_index).body_coreg(:, :, slice)))
						body = handles.patient(pat_index).body_coreg(:, :, slice);
						bodymask = handles.patient(pat_index).bodymask_coreg(:, :, slice);
						coregisteredTitle = 1;
					else
						body = handles.patient(pat_index).body(:, :, slice);
						bodymask = handles.patient(pat_index).bodymask(:, :, slice);
					end
					body = double(body);
					body = (body-min(body(:)))/(max(body(:))-min(body(:)));
					%{
					if panels{a}{3}&&slice<=size(patient(pat_index).tform,2)&&~isempty(patient(pat_index).tform{slice})
						% if the panel is set to show coregistered images and the tform exists
						height = size(currentSlice,1);
						width = size(currentSlice,2);
						body = imtransform(body, patient(pat_index).tform{slice}, 'XYScale', 1, 'XData',[1 width],'YData',[1 height]);
						bodymask = imtransform(bodymask, patient(pat_index).tform{slice}, 'XYScale', 1, 'XData',[1 width],'YData',[1 height]);
					end
					%}
					currentSlice = viewCoregistration(body, bodymask, imresize(lungmask, size(body)));
					if ~isequal(currentSlice,get(imhandles(panels{a}{2}),'CData'))
						% if the data has changed
						%{
						if ~isempty(sliderUpdatePntr)
							% if the pointer was given as a parameter
							if sliderUpdatePntr.Value==thisPntrValue
								% if the pointer value was not changed
								updateSlice = 1;
							else
								% if the pointer value was changed, don't
								% update the image or you'll overwite the
								% change
								updateSlice = 0;
							end
						else
							% the pointer was not given, so always update
							% the image slice
							updateSlice = 1;
						end
						%}
						updateSlice = 1;
						if updateSlice
							% if the above is true
							imagesc(currentSlice);
							if sum(currentSlice(:))==0
								% if the slice is completely black
								set(panels{a}{2}, 'clim', [0,1]);
							end
						end
					end
				end
			end
			if coregisteredTitle
				title('Coregistered Coregistration');
			else
				title('Coregistration');
			end
		case 'H'
			numslices = size(handles.patient(pat_index).hetero_images, 3);
			if slice>numslices || slice<=0
				imagesc(gray);
			else
				if not(isempty(handles.patient(pat_index).hetero_images(:, :, slice)));
					currentSlice = handles.patient(pat_index).hetero_images(:, :, slice);
					currentSlice = applyColormapToImage(currentSlice, heteroColormap());
					if ~isequal(currentSlice,get(imhandles(panels{a}{2}),'CData'))
						% if the data has changed
						%{
						if ~isempty(sliderUpdatePntr)
							% if the pointer was given as a parameter
							if sliderUpdatePntr.Value==thisPntrValue
								% if the pointer value was not changed
								updateSlice = 1;
							else
								% if the pointer value was changed, don't
								% update the image or you'll overwite the
								% change
								updateSlice = 0;
							end
						else
							% the pointer was not given, so always update
							% the image slice
							updateSlice = 1;
						end
						%}
						updateSlice = 1;
						if updateSlice
							% if the above is true
							imagesc(currentSlice);
							if sum(currentSlice(:))==0
								% if the slice is completely black
								set(panels{a}{2}, 'clim', [0,1]);
							end
						end
					end
				else
					updateStatusBox(handles, 'No heterogeneity map', 0);
					imagesc(gray);          
				end
			end
			title('Heterogeneity');
		case 'O'
			coregisteredTitle = 0;
			if isempty(handles.patient(pat_index).lungs)
				imagesc(gray);
			else
				if isempty(handles.patient(pat_index).body)
					imagesc(gray);
				else
					if slice>size(handles.patient(pat_index).body, 3) || slice<=0
						imagesc(gray);
					else
						if slice>size(handles.patient(pat_index).lungs, 3) || slice<=0
							imagesc(gray);
						else
							% if there are body and lung images
							lungs = handles.patient(pat_index).lungs(:, :, slice);
							if panels{a}{3}&&sum(sum(handles.patient(pat_index).body_coreg(:, :, slice)))
								body = handles.patient(pat_index).body_coreg(:, :, slice);
								coregisteredTitle = 1;
							else
								body = handles.patient(pat_index).body(:, :, slice);
							end
							body = double(body);
							body = (body-min(body(:)))/(max(body(:))-min(body(:)));
							lungs = double(lungs);
							lungs = (lungs-min(lungs(:)))/(max(lungs(:))-min(lungs(:)));
							%{
							if panels{a}{3}&&slice<=size(patient(pat_index).tform,2)&&~isempty(patient(pat_index).tform{slice})
								% if the panel is set to show coregistered images and the tform exists
								height = size(currentSlice,1);
								width = size(currentSlice,2);
								body = imtransform(body, patient(pat_index).tform{slice}, 'XYScale', 1, 'XData',[1 width],'YData',[1 height]);
							end
							%}
							currentSlice = viewOverlay(body, imresize(lungs, size(body)), handles.patient(pat_index).overlayColor);
							if ~isequal(currentSlice,get(imhandles(panels{a}{2}),'CData'))
								% if the data has changed
								%{
								if ~isempty(sliderUpdatePntr)
									% if the pointer was given as a parameter
									if sliderUpdatePntr.Value==thisPntrValue
										% if the pointer value was not changed
										updateSlice = 1;
									else
										% if the pointer value was changed, don't
										% update the image or you'll overwite the
										% change
										updateSlice = 0;
									end
								else
									% the pointer was not given, so always update
									% the image slice
									updateSlice = 1;
								end
								%}
								updateSlice = 1;
								if updateSlice
									% if the above is true
									imagesc(currentSlice);
									if sum(currentSlice(:))==0
										% if the slice is completely black
										set(panels{a}{2}, 'clim', [0,1]);
									end
								end
							end
						end
					end
				end
			end
			if coregisteredTitle
				title('Coregistered Overlay');
			else
				title('Overlay');
			end
		otherwise
			msg = sprintf('Unknown image state for panel: %s', panels(a,1));
			updateStatusBox(handles,msg, 1);
			title('');
	end
	%
	finalData = get(imhandles(panels{a}{2}),'CData');
	if ~isequal(initData, finalData)
		axesChanged = 1;
	end
end
%
sliderUpdatePntr.Value = 0;
%
if axesChanged
	%handles = updatePanelOverlay(handles);
	% this will cause the double imrect boxes to appear sometimes if it is
	% enabled
end