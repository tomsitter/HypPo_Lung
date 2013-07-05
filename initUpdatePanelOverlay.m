function initUpdatePanelOverlay(hObject)
	handles = guidata(hObject);
	if ~isfield(handles, 'panelOverlayRunning')
		handles.panelOverlayRunning = 0;
	end
	if handles.panelOverlayRunning==0
		handles.panelOverlayRunning = 1;
		lastRun = 0;
		% lastRun is to allow the loop to run one extra time to clean up
		% everything
		while (~strcmp(handles.state,'idle')||lastRun==1)&&ishandle(hObject)
			% figure could close at any time during this loop
			handles = updatePanelOverlay(handles);
			if ishandle(hObject)
				guidata(hObject, handles);
			end
			pause(0.1);
			if ishandle(hObject)
				handles = guidata(hObject);
				if strcmp(handles.state,'idle')&&lastRun==0
					lastRun = 1;
				else
					lastRun = 0;
				end
			end
		end
		if ishandle(hObject)
			handles.panelOverlayRunning = 0;
			guidata(hObject, handles);
		end
	end
	%{
	if ~isfield(handles, 'panelOverlayTimer')
		handles.panelOverlayTimer = timer('TimerFcn',{@updatePanelOverlayTimer,hObject},'Period', 0.1, 'ExecutionMode', 'fixedSpacing');
		start(handles.panelOverlayTimer);
	end
	%}
end