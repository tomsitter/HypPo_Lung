function updatePanelOverlayTimer(thisTimer, ~, hObject)
	if ishandle(hObject)
		handles = guidata(hObject);
		handles = updatePanelOverlay(handles);
		guidata(hObject, handles);
	else
		stop(thisTimer);
	end
end