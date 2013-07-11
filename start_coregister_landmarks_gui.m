function start_coregister_landmarks_gui(hObject)
	%COREGISTER_LANDMARKS aligns a lung mask with a body mask and returns the aligned
	%body mask and image.
	% function [reg_lungmask, reg_bodymask] = coregister(lungmask, bodymask)
	% lungmask and bodymask are both binary images
	% The user selects 3 to 7 landmarks, and then the algorithm finds a
	% map to register the proton image to the helium image. This function uses 
	% Afine method for translation, rotation and scaling the proton images.
	%
	% The function was modified first by:
	%       M. Kirby June 1, 2010.
	% 
	% Next modification by:
	%       M.Reza Heydarian, 
	%       Robarts Research Institute, June 17, 2011:
	% The function was modified to overlay helium image on the registered
	% proton image (including their segmented cotour) and asks confirmation 
	% from the user. Then the function applys the same registration map to the
	% rest of the proton images.
	%
	% Modified by:
	%   Thomas Sitter
	%   TBRRI, March 27, 2013
	% Incorporated into HypPo_Lung GUI
	
	%index = handles.pat_index;
	%slice = round(get(handles.slider_slice, 'Value'));
	%patient = handles.patient(index);
	
	% lungmask = patient.lungmask(:,:,slice);
	%bodymask = patient.bodymask(:,:,slice);
	%lungs = patient.lungs(:,:,slice);
	%body = patient.body(:,:,slice);
	
	%target = lungs;
	%source = body;
	
	%{
	axes(handles.axes1);
	imagesc(target)
	title( 'Helium Image', 'fontweight', 'bold', 'fontsize', 12 )

	axes(handles.axes2);
	source = imadjust(source);
	imagesc(source) 
	title( 'Proton Image', 'fontweight', 'bold', 'fontsize', 12 )
	%}
	
	handles = guidata(hObject);
	
	if handles.leftpanel == 'L'
		lungAxes = handles.axes1;
	elseif handles.rightpanel == 'L'
		lungAxes = handles.axes2;
	else
		handles.leftpanel = 'L';
		lungAxes = handles.axes1;
		handles = updateSliceSlider(handles);
	end
	
	if handles.leftpanel == 'B'
		bodyAxes = handles.axes1;
	elseif handles.rightpanel == 'B'
		bodyAxes = handles.axes2;
	else
		handles.rightpanel = 'B';
		bodyAxes = handles.axes2;
		handles = updateSliceSlider(handles);
	end
	
	if ~isfield(handles, 'panelOverlayData')
		handles.panelOverlayData = struct();
	end
	
	handles.panelOverlayData.coreg_landmarks_escape_pointer = libpointer('uint32');
	handles.panelOverlayData.coreg_landmarks_escape_pointer.Value = 0;
	
	% ---------------> reading mouse clicks
	
	handles.panelOverlayData.coreg_landmarks_lungs_x = [];
	handles.panelOverlayData.coreg_landmarks_lungs_y = [];
	
	handles.panelOverlayData.coreg_landmarks_body_x = [];
	handles.panelOverlayData.coreg_landmarks_body_y = [];
	
	handles.panelOverlayData.coreg_landmarks_lung_plot = [];
	handles.panelOverlayData.coreg_landmarks_body_plot = [];
	
	handles.panelOverlayData.coreg_landmarks_lung_text = [];
	handles.panelOverlayData.coreg_landmarks_body_text = [];
	
	guidata(hObject, handles);
	
	updateStatusBox(handles, 'Select landmarks in both images. Press ENTER key when done.');  % chose features that are easy to identify
	
	while 1
		try
			[newX, newY] = ginputax2([lungAxes,bodyAxes], handles.panelOverlayData.coreg_landmarks_escape_pointer, 1);
		catch err
			if strcmp(err.identifier,'MATLAB:ginput:FigureDeletionPause')
				break;
			else
				rethrow(err);
			end
		end
		handles = guidata(hObject);
		if isequal(newX,[])
			break;
		end
		if get(handles.figure1,'CurrentAxes')==lungAxes
			xLim = get(lungAxes, 'xlim');
			yLim = get(lungAxes, 'ylim');
			if newX>xLim(1)&&newX<xLim(2)&&newY>yLim(1)&&newY<yLim(2)
				newText = text(newX, newY, num2str(size(handles.panelOverlayData.coreg_landmarks_lungs_x,1)+1), 'VerticalAlignment','bottom','HorizontalAlignment','right','color',[0,1,0]);
				handles.panelOverlayData.coreg_landmarks_lung_text = [newText,handles.panelOverlayData.coreg_landmarks_lung_text];
				hold on;
				newPlot = plot(newX, newY, 'y+');
				handles.panelOverlayData.coreg_landmarks_lung_plot = [handles.panelOverlayData.coreg_landmarks_lung_plot, newPlot];
				hold off;
				handles.panelOverlayData.coreg_landmarks_lungs_x = [handles.panelOverlayData.coreg_landmarks_lungs_x; newX];
				handles.panelOverlayData.coreg_landmarks_lungs_y = [handles.panelOverlayData.coreg_landmarks_lungs_y; newY];
			end
		elseif get(handles.figure1,'CurrentAxes')==bodyAxes
			xLim = get(bodyAxes, 'xlim');
			yLim = get(bodyAxes, 'ylim');
			if newX>xLim(1)&&newX<xLim(2)&&newY>yLim(1)&&newY<yLim(2)
				newText = text(newX, newY, num2str(size(handles.panelOverlayData.coreg_landmarks_body_x,1)+1), 'VerticalAlignment','bottom','HorizontalAlignment','right','color',[0,1,0]);
				handles.panelOverlayData.coreg_landmarks_body_text = [newText,handles.panelOverlayData.coreg_landmarks_body_text];
				hold on;
				newPlot = plot(newX, newY, 'y+');
				handles.panelOverlayData.coreg_landmarks_body_plot = [handles.panelOverlayData.coreg_landmarks_body_plot, newPlot];
				hold off;
				handles.panelOverlayData.coreg_landmarks_body_x = [handles.panelOverlayData.coreg_landmarks_body_x; newX];
				handles.panelOverlayData.coreg_landmarks_body_y = [handles.panelOverlayData.coreg_landmarks_body_y; newY];
			end
		end
		guidata(hObject, handles);
	end
	
	
	
	% reg_H = zeros(size(proton));  % Registered Proton images
	% reg_H_mask = zeros(size(protonMask));  % Registered Mask for Proton images
	% numberOfslices = size(protonMask,3);
	% for indx = 1: numberOfslices
	% 
	%     H_image = proton(:,:,indx);
	%     registered = imtransform(H_image, tform, 'xdata', [1 size(source,2)], 'ydata', [1, size(source, 1)]);
	%     reg_H(:,:,indx) = registered;
	% %     figure;
	% %     subplot(1,2,1)
	% %     imshow(reg_H(:,:,indx),[])
	% 
	%     H_mask = protonMask(:,:,indx);

	%reg_body = imtransform(body, tform, 'xdata', [1 size(source,2)], 'ydata', [1, size(source, 1)]);
	%reg_bodymask = imtransform(bodymask, tform, 'xdata', [1 size(source,2)], 'ydata', [1, size(source, 1)]);

		 %     reg_H_mask(:,:,indx) = registered;
	% %     subplot(1,2,2)
	% %     imshow(reg_H_mask(:,:,indx),[])
	% %     figure, imshow(protonMask(:,:,indx),[])
	%      
	% end
end