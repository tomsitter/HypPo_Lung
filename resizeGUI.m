function ResizeGUI(hObject, handles)
	%
	position = get(hObject,'Position');
	windowSize = position(3:4);
	buildSize = getappdata(hObject,'buildSize');
	fractionSize = min(windowSize./buildSize);
	paddingSize = 10*fractionSize;
	axesPaddingSize = 30;
	%fractionSize = the ratio of the size of the window to the size it was
	%originally created at
	%
	originalFontUnits = get(handles.statusbox, 'fontUnits');
	set(handles.statusbox, 'fontUnits', 'pixels');
	statusboxFontSizePixels = get(handles.statusbox, 'fontSize');
	set(handles.statusbox, 'fontUnits', originalFontUnits);
	%
	statusboxPosition = [paddingSize,paddingSize,250*(statusboxFontSizePixels/13),windowSize(2)-2*paddingSize];
	if checkDimensions(statusboxPosition)
		set(handles.statusbox, 'position', statusboxPosition);
	else
		return;
	end
	%
	uipanel_adjustOriginalPosition = get(handles.uipanel_adjust, 'position');
	uipanel_actionPosition = [0,0,0,0];
	uipanel_actionPosition(1) = statusboxPosition(1)+statusboxPosition(3)+paddingSize;
	uipanel_actionPosition(2) = paddingSize;
	uipanel_actionPosition(3) = windowSize(1)-uipanel_actionPosition(1)-paddingSize;
	uipanel_actionPosition(4) = uipanel_adjustOriginalPosition(4)+20+5;
	if checkDimensions(uipanel_actionPosition)
		set(handles.uipanel_action, 'position', uipanel_actionPosition);
	else
		return;
	end
	%
	push_applyOriginalPosition = get(handles.push_apply, 'position');
	push_applyPosition = [0,0,0,0];
	push_applyPosition(1) = 30;%30
	push_applyPosition(2) = uipanel_actionPosition(4)-(uipanel_actionPosition(4)-3*push_applyOriginalPosition(4)-2*5)/2-push_applyOriginalPosition(4)-push_applyOriginalPosition(4)/4;
	push_applyPosition(3) = push_applyOriginalPosition(3);
	push_applyPosition(4) = push_applyOriginalPosition(4);
	if checkDimensions(push_applyPosition)
		set(handles.push_apply, 'position', push_applyPosition);
	else
		return;
	end
	%
	push_applyallOriginalPosition = get(handles.push_applyall, 'position');
	push_applyallPosition = [0,0,0,0];
	push_applyallPosition(1) = 30;%30
	push_applyallPosition(2) = uipanel_actionPosition(4)-(uipanel_actionPosition(4)-3*push_applyallOriginalPosition(4)-2*5)/2-push_applyOriginalPosition(4)-(push_applyallOriginalPosition(4)+5)-push_applyallOriginalPosition(4)/4;
	push_applyallPosition(3) = push_applyallOriginalPosition(3);
	push_applyallPosition(4) = push_applyallOriginalPosition(4);
	if checkDimensions(push_applyallPosition)
		set(handles.push_applyall, 'position', push_applyallPosition);
	else
		return;
	end
	%
	push_cancelOriginalPosition = get(handles.push_cancel, 'position');
	push_cancelPosition = [0,0,0,0];
	push_cancelPosition(1) = 30;%30
	push_cancelPosition(2) = uipanel_actionPosition(4)-(uipanel_actionPosition(4)-3*push_cancelOriginalPosition(4)-2*5)/2-push_cancelOriginalPosition(4)-2*(push_cancelOriginalPosition(4)+5)-push_cancelOriginalPosition(4)/4;
	push_cancelPosition(3) = push_cancelOriginalPosition(3);
	push_cancelPosition(4) = push_cancelOriginalPosition(4);
	if checkDimensions(push_cancelPosition)
		set(handles.push_cancel, 'position', push_cancelPosition);
	else
		return;
	end
	%
	uipanel_adjustPosition = [0,0,0,0];
	uipanel_adjustPosition(1) = push_cancelPosition(1)+push_cancelPosition(3)+30;
	uipanel_adjustPosition(2) = 10;
	uipanel_adjustPosition(3) = uipanel_adjustOriginalPosition(3);
	uipanel_adjustPosition(4) = uipanel_adjustOriginalPosition(4);
	if checkDimensions(uipanel_adjustPosition)
		set(handles.uipanel_adjust, 'position', uipanel_adjustPosition);
	else
		return;
	end
	%
	uipanel3OriginalPosition = get(handles.uipanel3, 'position');
	uipanel3Position = [0,0,0,0];
	uipanel3Position(1) = uipanel_adjustPosition(1)+uipanel_adjustPosition(3)+30;
	uipanel3Position(2) = (uipanel_actionPosition(4)-uipanel3OriginalPosition(4))/2;
	uipanel3Position(3) = uipanel3OriginalPosition(3);
	uipanel3Position(4) = uipanel3OriginalPosition(4);
	if checkDimensions(uipanel3Position)
		set(handles.uipanel3, 'position', uipanel3Position);
	else
		return;
	end
	%
	slider_sliceOriginalPosition = get(handles.slider_slice, 'position');
	slider_slicePosition = [0,0,0,0];
	slider_slicePosition(1) = statusboxPosition(1)+statusboxPosition(3)+paddingSize;
	slider_slicePosition(2) = uipanel_actionPosition(2)+uipanel_actionPosition(4)+paddingSize;
	slider_slicePosition(3) = windowSize(1)-slider_slicePosition(1)-paddingSize;
	slider_slicePosition(4) = slider_sliceOriginalPosition(4);
	if checkDimensions(slider_slicePosition)
		set(handles.slider_slice, 'position', slider_slicePosition);
	else
		return;
	end
	%
	%
	uipanel4Position = [0,0,0,0];
	uipanel4Position(1) = statusboxPosition(1)+statusboxPosition(3)+paddingSize;
	uipanel4Position(2) = slider_slicePosition(2)+slider_slicePosition(4)+paddingSize;
	uipanel4Position(3) = windowSize(1)-uipanel4Position(1)-paddingSize;
	uipanel4Position(4) = windowSize(2)-uipanel4Position(2)-paddingSize;
	if checkDimensions(uipanel4Position)
		set(handles.uipanel4, 'position', uipanel4Position);
	else
		return;
	end
	%
	axes1Position = [0,0,0,0];
	if 0.5*uipanel4Position(3)<uipanel4Position(4)
		axes1Position(3) = (uipanel4Position(3)-2*axesPaddingSize-paddingSize*5)/2;
		axes1Position(4) = axes1Position(3);
		axes1Position(1) = (uipanel4Position(3)-2*(axes1Position(3)+axesPaddingSize))/3+axesPaddingSize;
		axes1Position(2) = axesPaddingSize;
	else
		axes1Position(4) = uipanel4Position(4)-2*axesPaddingSize;
		axes1Position(3) = axes1Position(4);
		axes1Position(1) = (uipanel4Position(3)-2*(axes1Position(3)+axesPaddingSize))/3+axesPaddingSize;
		axes1Position(2) = axesPaddingSize;
	end
	if checkDimensions(axes1Position)
		set(handles.axes1, 'position', axes1Position);
	else
		return;
	end
	%
	axes2Position = [0,0,0,0];
	if 0.5*uipanel4Position(3)<uipanel4Position(4)
		axes2Position(3) = (uipanel4Position(3)-2*axesPaddingSize-paddingSize*5)/2;
		axes2Position(4) = axes2Position(3);
		axes2Position(1) = (uipanel4Position(3)-2*(axes2Position(3)+axesPaddingSize))*2/3+(axes2Position(3)+axesPaddingSize)+axesPaddingSize;
		axes2Position(2) = axesPaddingSize;
	else
		axes2Position(4) = uipanel4Position(4)-2*axesPaddingSize;
		axes2Position(3) = axes2Position(4);
		axes2Position(1) = (uipanel4Position(3)-2*(axes2Position(3)+axesPaddingSize))*2/3+(axes2Position(3)+axesPaddingSize)+axesPaddingSize;
		axes2Position(2) = axesPaddingSize;
	end
	if checkDimensions(axes2Position)
		set(handles.axes2, 'position', axes2Position);
	else
		return;
	end
end

function good = checkDimensions(dims)
	good = false;
	if size(dims)==[1,4]
		if dims>=0
			%dimensions can not be negative
			good = true;
		end
	end
end
