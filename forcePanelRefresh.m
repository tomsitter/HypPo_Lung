function handles = forcePanelRefresh(handles)
	axes(handles.axes1);
	imshow([0 0; 0 0]);
	axes(handles.axes2);
	imshow([0 0; 0 0]);
	handles = updateImagePanels(handles);
end

