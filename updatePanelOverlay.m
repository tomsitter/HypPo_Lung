function handles = updatePanelOverlay(handles)
	if ~isfield(handles, 'panelOverlayData')
		handles.panelOverlayData = struct();
	end
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	if strcmp(handles.state, 'def_lung_signal_and_noise_region')
		if handles.leftpanel == 'L'
			lungAxes = handles.axes1;
		elseif handles.rightpanel == 'L'
			lungAxes = handles.axes2;
		else
			handles.leftpanel = 'L';
			lungAxes = handles.axes1;
			handles = updateSliceSlider(handles);
		end
		%
		if get(handles.slider_slice, 'value')>size(handles.patient(handles.pat_index).lungs,3)
			set(handles.slider_slice, 'value', round(size(handles.patient(handles.pat_index).lungs,3)/2));
			handles = updateSliceSlider(handles);
		end
		%
		try
			getPosition(handles.panelOverlayData.SNR_lung_rectOne);
			getPosition(handles.panelOverlayData.SNR_lung_rectTwo);
			exists = 1;
		catch
			exists = 0;
		end
		%
		if ~exists
			xaxis = floor(get(lungAxes, 'XLim'));
			yaxis = floor(get(lungAxes, 'YLim'));
			mid_x = round(xaxis(2)/2);
			size_box = xaxis(2)/4;
			%
			handles.panelOverlayData.SNR_lung_rectOne = imrect(lungAxes, [(mid_x-size_box/2) 10 size_box size_box]);
			handles.panelOverlayData.SNR_lung_rectTwo = imrect(lungAxes, [(mid_x-size_box/2) size_box*2 size_box size_box]);
			fcn = makeConstrainToRectFcn('imrect', [xaxis(1)+1,xaxis(2)-1], [yaxis(1)+1,yaxis(2)-1]);
			setPositionConstraintFcn(handles.panelOverlayData.SNR_lung_rectOne,fcn);
			setPositionConstraintFcn(handles.panelOverlayData.SNR_lung_rectTwo,fcn);
			if isfield(handles.panelOverlayData, 'SNR_lung_regionOne')&&isfield(handles.panelOverlayData, 'SNR_lung_regionTwo')
				setConstrainedPosition(handles.panelOverlayData.SNR_lung_rectOne, handles.panelOverlayData.SNR_lung_regionOne);
				setConstrainedPosition(handles.panelOverlayData.SNR_lung_rectTwo, handles.panelOverlayData.SNR_lung_regionTwo);
			end
		end
		%
		handles.panelOverlayData.SNR_lung_regionOne = round(handles.panelOverlayData.SNR_lung_rectOne.getPosition);
		handles.panelOverlayData.SNR_lung_regionTwo = round(handles.panelOverlayData.SNR_lung_rectTwo.getPosition);
	else
		if isfield(handles.panelOverlayData, 'SNR_lung_rectOne')
			delete(handles.panelOverlayData.SNR_lung_rectOne);
			handles.panelOverlayData = rmfield(handles.panelOverlayData, 'SNR_lung_rectOne');
			handles.panelOverlayData = rmfield(handles.panelOverlayData, 'SNR_lung_regionOne');
		end
		if isfield(handles.panelOverlayData, 'SNR_lung_rectTwo')
			delete(handles.panelOverlayData.SNR_lung_rectTwo);
			handles.panelOverlayData = rmfield(handles.panelOverlayData, 'SNR_lung_rectTwo');
			handles.panelOverlayData = rmfield(handles.panelOverlayData, 'SNR_lung_regionTwo');
		end
	end
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	if strcmp(handles.state, 'def_body_signal_and_noise_region')
		if handles.leftpanel == 'B'
			bodyAxes = handles.axes1;
		elseif handles.rightpanel == 'B'
			bodyAxes = handles.axes2;
		else
			handles.rightpanel = 'B';
			bodyAxes = handles.axes2;
			handles = updateSliceSlider(handles);
		end
		%
		if get(handles.slider_slice, 'value')>size(handles.patient(handles.pat_index).body,3)
			set(handles.slider_slice, 'value', round(size(handles.patient(handles.pat_index).body,3)/2));
			handles = updateSliceSlider(handles);
		end
		%
		try
			getPosition(handles.panelOverlayData.SNR_body_rectOne);
			getPosition(handles.panelOverlayData.SNR_body_rectTwo);
			exists = 1;
		catch
			exists = 0;
		end
		%
		if ~exists
			xaxis = floor(get(bodyAxes, 'XLim'));
			yaxis = floor(get(bodyAxes, 'YLim'));
			mid_x = round(xaxis(2)/2);
			size_box = xaxis(2)/4;
			%
			handles.panelOverlayData.SNR_body_rectOne = imrect(bodyAxes, [(mid_x-size_box/2) 10 size_box size_box]);
			handles.panelOverlayData.SNR_body_rectTwo = imrect(bodyAxes, [(mid_x-size_box/2) size_box*2 size_box size_box]);
			fcn = makeConstrainToRectFcn('imrect', [xaxis(1)+1,xaxis(2)-1], [yaxis(1)+1,yaxis(2)-1]);
			setPositionConstraintFcn(handles.panelOverlayData.SNR_body_rectOne,fcn);
			setPositionConstraintFcn(handles.panelOverlayData.SNR_body_rectTwo,fcn);
			if isfield(handles.panelOverlayData, 'SNR_body_regionOne')&&isfield(handles.panelOverlayData, 'SNR_body_regionTwo')
				setConstrainedPosition(handles.panelOverlayData.SNR_body_rectOne, handles.panelOverlayData.SNR_body_regionOne);
				setConstrainedPosition(handles.panelOverlayData.SNR_body_rectTwo, handles.panelOverlayData.SNR_body_regionTwo);
			end
		end
		%
		handles.panelOverlayData.SNR_body_regionOne = round(handles.panelOverlayData.SNR_body_rectOne.getPosition);
		handles.panelOverlayData.SNR_body_regionTwo = round(handles.panelOverlayData.SNR_body_rectTwo.getPosition);
	else
		if isfield(handles.panelOverlayData, 'SNR_body_rectOne')
			delete(handles.panelOverlayData.SNR_body_rectOne);
			handles.panelOverlayData = rmfield(handles.panelOverlayData, 'SNR_body_rectOne');
			handles.panelOverlayData = rmfield(handles.panelOverlayData, 'SNR_body_regionOne');
		end
		if isfield(handles.panelOverlayData, 'SNR_body_rectTwo')
			delete(handles.panelOverlayData.SNR_body_rectTwo);
			handles.panelOverlayData = rmfield(handles.panelOverlayData, 'SNR_body_rectTwo');
			handles.panelOverlayData = rmfield(handles.panelOverlayData, 'SNR_body_regionTwo');
		end
	end
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	if strcmp(handles.state, 'def_noiseregion')
		if handles.leftpanel == 'L'
			lungAxes = handles.axes1;
		elseif handles.rightpanel == 'L'
			lungAxes = handles.axes2;
		else
			handles.leftpanel = 'L';
			lungAxes = handles.axes1;
			handles = updateSliceSlider(handles);
		end
		%
		if get(handles.slider_slice, 'value')>size(handles.patient(handles.pat_index).lungs,3)
			set(handles.slider_slice, 'value', round(size(handles.patient(handles.pat_index).lungs,3)/2));
			handles = updateSliceSlider(handles);
		end
		%
		try
			getPosition(handles.panelOverlayData.seg_lung_rect);
			exists = 1;
		catch
			exists = 0;
		end
		%
		if ~exists
			%Get middle of xaxis to place region of interest
			xaxis = floor(get(lungAxes, 'XLim'));
			yaxis = floor(get(lungAxes, 'YLim'));
			mid_x = round(xaxis(2) / 2);
			size_box = xaxis(2) / 4;
			%disp here
			%pause(1)
			if isfield(handles.panelOverlayData, 'seg_lung_rect')
				handles.panelOverlayData.seg_lung_rect;
			end
			%disp a;
			%Create a place region of interest, constrain to axis
			handles.panelOverlayData.seg_lung_rect = imrect(lungAxes, [(mid_x-size_box/2), 10, size_box, size_box,] );
			fcn = makeConstrainToRectFcn('imrect',[xaxis(1)+1,xaxis(2)-1], [yaxis(1)+1,yaxis(2)-1]);
			setPositionConstraintFcn(handles.panelOverlayData.seg_lung_rect,fcn)
			if isfield(handles.panelOverlayData, 'seg_lung_region')
				setConstrainedPosition(handles.panelOverlayData.seg_lung_rect, handles.panelOverlayData.seg_lung_region);
			end
		end
		%
		handles.panelOverlayData.seg_lung_region = round(handles.panelOverlayData.seg_lung_rect.getPosition);
		%
		try
			set(handles.analyze_hetero, 'Enable', 'on');
		catch err
			if strcmp(err.message, 'Invalid or deleted object.')==0
				rethrow(err);
			end
		end
	else
		if isfield(handles.panelOverlayData, 'seg_lung_rect')
			delete(handles.panelOverlayData.seg_lung_rect);
			handles.panelOverlayData = rmfield(handles.panelOverlayData, 'seg_lung_rect');
			handles.panelOverlayData = rmfield(handles.panelOverlayData, 'seg_lung_region');
		end
	end
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
end