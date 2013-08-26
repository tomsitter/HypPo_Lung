function varargout = maingui(varargin)
% MAINGUI MATLAB code for maingui.fig
%      MAINGUI, by itself, creates a new MAINGUI or raises the existing
%      singleton*.
%
%      H = MAINGUI returns the handle to a new MAINGUI or the handle to
%      the existing singleton*.
%
%      MAINGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAINGUI.M with the given input arguments.
%
%      MAINGUI('Property','Value',...) creates a new MAINGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before maingui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to maingui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help maingui

% Last Modified by GUIDE v2.5 13-Aug-2013 21:40:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
				   'gui_Singleton',  gui_Singleton, ...
				   'gui_OpeningFcn', @maingui_OpeningFcn, ...
				   'gui_OutputFcn',  @maingui_OutputFcn, ...
				   'gui_LayoutFcn',  [] , ...
				   'gui_Callback',   []);
if nargin && ischar(varargin{1})
	gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
	[varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
	gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before maingui is made visible.
function maingui_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to maingui (see VARARGIN)

%Save current directory
handles.curdir = cd;

%define a new empty patient
handles.patient = newPatient();
handles.pat_index = 1;

handles.leftpanel = '';
handles.rightpanel = '';

handles.leftpanelcoreg = 1;
handles.rightpanelcoreg = 1;
handles.overridepanelnocoreg = 0;

% handles.slice_index = 1;
handles.state = 'idle';

set(handles.figure1, 'visible', 'on');
% needs to be visible for the slider moving callback to work (not sure why)
%
sliderUpdatePntr = libpointer('uint32');
sliderUpdatePntr.Value = 0;
% The purpose of the pointer is to make sure that the slices are not
% overwritten. When the slider is moving, the callback is sometimes called
% before the previous callback has finished. This causes the first callback
% to stop, the second callback to run, and the first callback to then
% finish after the second callback finishes. Since the first callback
% finishes after the second callback does, it overwrites the changes made
% by the second callback. The pointer is modified in the
% updateImageSlices.m script so that each callback knows if it should
% update the image slices or not.
%

sliderStoppedMovingTimer = timer('StartDelay',10,'TimerFcn',{@updateImagePanelsSliderStop, hObject, sliderUpdatePntr});

jvscroll = findjobj(handles.slider_slice);
jvscroll.MouseDraggedCallback = {@scrollCallback, hObject, sliderUpdatePntr, sliderStoppedMovingTimer};
handles.sliderLastUpdated = clock;

% Choose default command line output for maingui
handles.output = hObject;

handles = updateImagePanels(handles);
handles = updateSliceSlider(handles);
updateMenuOptions(handles);
updateViewOptions(handles);

% Update handles structure
guidata(hObject, handles);
%
filePath = mfilename('fullpath');
directoryLocationsInString = [strfind(filePath,'\'),strfind(filePath,'/')];
parentDirectoryIndex = max(directoryLocationsInString);
folderPath = filePath(1:parentDirectoryIndex-1);
%
%checkAndGetUpdates('tomsitter','HypPo_Lung',folderPath);
updateTimer = timer('TimerFcn',{@checkAndGetUpdatesTimer,'tomsitter','HypPo_Lung',folderPath}, 'StartDelay', 1.0);
start(updateTimer);
% checkAndGetUpdates is in a timer because the maingui window automatically brings
% itself to the front once the opening function is finished. This causes
% the update window to be hidden behind the maingui window. The timer fixes
% this problem. The timer also allows the program to continue if the
% checkAndGetUpdates crashes.
%
% UIWAIT makes maingui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function checkAndGetUpdatesTimer(hObject, ~, username, repo, projectFolderPath)
stop(hObject);
delete(hObject);
checkAndGetUpdates(username, repo, projectFolderPath);

function scrollCallback(~, ~, mainFigure, sliderUpdatePntr, sliderStoppedMovingTimer)
handles = guidata(mainFigure);
if etime(clock,handles.sliderLastUpdated)>0.06%0.05
	handles.sliderLastUpdated = clock;
	guidata(mainFigure, handles);
	handles = updateImagePanels(handles, sliderUpdatePntr);
	guidata(mainFigure, handles);
	%
	stop(sliderStoppedMovingTimer);
	set(sliderStoppedMovingTimer,'StartDelay',0.1);
	start(sliderStoppedMovingTimer);
end

function updateImagePanelsSliderStop(hObject, ~, mainFigure, sliderUpdatePntr)
handles = guidata(mainFigure);
if sliderUpdatePntr.Value
	stop(hObject);
	set(hObject,'StartDelay',0.1);
	start(hObject);
else
	handles = updateImagePanels(handles);
end
guidata(mainFigure, handles);


% --- Outputs from this function are returned to the command line.
function varargout = maingui_OutputFcn(~, ~, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function statusbox_Callback(hObject, ~, handles)
% hObject    handle to statusbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of statusbox as text
%        str2double(get(hObject,'String')) returns contents of statusbox as a double


% --- Executes during object creation, after setting all properties.
function statusbox_CreateFcn(hObject, ~, handles)
% hObject    handle to statusbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_slice_Callback(hObject, ~, handles)
% hObject    handle to slider_slice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

%Get current patient
%pat_index = handles.pat_index;

%val = get(hObject, 'Value');
handles = updateSliceSlider(handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider_slice_CreateFcn(hObject, ~, ~)
% hObject    handle to slider_slice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --------------------------------------------------------------------
function file_menu_Callback(hObject, ~, handles)
% hObject    handle to file_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_analyze_Callback(hObject, ~, handles)
% hObject    handle to menu_analyze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% % --------------------------------------------------------------------
% function file_changeexp_Callback(hObject, eventdata, handles)
% % hObject    handle to file_changeexp (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function file_newpatient_Callback(hObject, ~, handles)
% hObject    handle to file_newpatient (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pat_index = length(handles.patient) + 1;

% new_patient = newPatient();

% fn = fieldnames(new_patient);
% for i = 1:numel(fn)
%     handles.patient(pat_index).(fn{i}) = new_patient.(fn{i});
% end
p = newPatient();
p(1).id = 'newPatient';
handles.patient(pat_index) = p;
handles.leftpanel = '';
handles.rightpanel = '';

% handles.patient(pat_index).id = 'NoData';

handles.pat_index = pat_index;

updateStatusBox(handles, 'Created new patient', 1);
handles = updateSliceSlider(handles);
updateMenuOptions(handles);
updateViewOptions(handles);

guidata(hObject, handles);

% --------------------------------------------------------------------
function file_changepatient_Callback(hObject, eventdata, handles)
% hObject    handle to file_changepatient (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
patients = handles.patient;
pat_index = handles.pat_index;

ids = {patients(:).id};

if isempty(ids) 
	file_loadpatient_Callback(hObject, eventdata, handles)
else
	[selection, ok] = listdlg('PromptString', 'Select a patient:', ...
							  'ListString', ids, 'SelectionMode', 'single', ...
							  'InitialValue', pat_index);

	if ok
		if pat_index == selection
			updateStatusBox(handles, 'Current patient selected', 0);
		else
			handles.pat_index = selection;

			msg = sprintf('Changed to patient %s', ids{selection});
			updateStatusBox(handles, msg, 1);

			handles = updateSliceSlider(handles);

			updateViewOptions(handles);
			updateMenuOptions(handles);

			guidata(hObject, handles);
		end
	end
end



% --------------------------------------------------------------------
function file_savepatient_Callback(hObject, ~, handles)
% hObject    handle to file_savepatient (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if size(handles.patient,2)~=0
	%Get current patient
	pat_index = handles.pat_index;
	patient = handles.patient(pat_index);
	id = patient.id;

	%Cannot have dashes in matlab variables, replace with underscore and then
	%assign into workspace
	id = sprintf('pat_%s', id);
	id = strrep(id, '-', '_');
	id = strrep(id, ' ', '_');

	eval(sprintf('%s = patient', id));

	uisave(sprintf('%s', id), id);

	assignin('base', id, patient);
	msg = sprintf('Saving patient %s to workspace', id);
	updateStatusBox(handles, msg, 1);
else
	errordlg('Cannot save patient: there is no patient loaded', 'Cannot Save Patient', 'modal');
end

% --------------------------------------------------------------------
function file_loadpatient_Callback(hObject, ~, handles)
% hObject    handle to file_loadpatient (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pat_index = handles.pat_index;

[fname,pname] = uigetfile('*.mat', 'Select previous patient.mat file');

if isequal(fname,0) || isequal(pname,0)
	updateStatusBox(handles, 'Cancelled by user', 0);
	return;
else
	updateStatusBox(handles, ['User selected ', fullfile(pname, fname)], 1);
	%return;
end

filename=[pname fname];

new_experiment = load(filename);
%new_patient = new_experiment.patient;

new_patients = fieldnames(new_experiment);

if size(new_patients,1)~=1
	msg = sprintf('The file had multiple fields, are you sure this is a patient file? Check the structure and try again.');
	updateStatusBox(handles, msg, 0);
	return;
end

new_patient = new_experiment.(new_patients{1});

if isempty(handles.patient)
	cur_patient = handles.patient;
else
	cur_patient = handles.patient(pat_index);
	pat_index = pat_index + 1;
	handles.pat_index = pat_index;
end

fn = fieldnames(new_patient);
for i = 1:numel(fn)
	if isfield(cur_patient, fn{i})
		handles.patient(pat_index).(fn{i}) = new_patient.(fn{i});
	else
		msg = sprintf('Found unknown field "%s", are you sure this is a patient file?', fn{i});
		updateStatusBox(handles, msg, 0);
	end
end

updateViewOptions(handles);
handles = updateSliceSlider(handles);

% Update handles structure
guidata(hObject, handles);

msg = sprintf('Loaded patient %s', new_patient.id);
updateStatusBox(handles, msg, 1);
updateMenuOptions(handles);

% --------------------------------------------------------------------
function file_loadlung_Callback(hObject, ~, handles)
% hObject    handle to file_loadlung (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Read DICOM or PARREC files and store information in handles
%under the currect patient
handles = readImages(handles, 'lung');

handles = updateSliceSlider(handles);
updateViewOptions(handles);
updateMenuOptions(handles);
%set(handles.analyze_seglungs, 'Enable', 'on');
%set(handles.calculate_lung_SNR, 'Enable', 'on');
% Update handles structure
guidata(hObject, handles);

% --------------------------------------------------------------------
function file_loadbody_Callback(hObject, ~, handles)
% hObject    handle to file_loadbody (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Read DICOM or PARREC files and store information in handles
%under the currect patient
handles = readImages(handles, 'body');

handles = updateSliceSlider(handles);
updateViewOptions(handles);
updateMenuOptions(handles);

% Update handles structure
guidata(hObject, handles)


% --------------------------------------------------------------------
function analyze_seglungs_Callback(hObject, ~, handles)
% hObject    handle to analyze_seglungs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
%
updateStatusBox(handles, 'Preparing to segment lungs', 1);
%
updateStatusBox(handles, 'Select a region of noise', 0);
%
handles.state = 'def_noiseregion';
guidata(hObject, handles);
initUpdatePanelOverlay(hObject);
%


% --------------------------------------------------------------------
function analyze_coreg_lm_Callback(hObject, eventdata, handles)
% hObject    handle to analyze_coreg_lm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateStatusBox(handles, 'Preparing to coregister images', 1);

handles.state = 'def_coreg_landmarks';
handles.overridepanelnocoreg = 1;
handles = updateImagePanels(handles);
guidata(hObject, handles);

start_coregister_landmarks_gui(hObject);


% --- Executes on button press in push_applyall.
function push_applyall_Callback(hObject, ~, handles)
% hObject    handle to push_applyall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
state = handles.state;
handles.state = 'pause';
if size(handles.patient,2)~=0
	index = handles.pat_index;
	patient = handles.patient(index);

	if strcmp(state, 'def_noiseregion')
		dims = round(handles.panelOverlayData.seg_lung_rect.getPosition);
		[x y w h] = deal(max(1, dims(1)), max(1, dims(2)), ...
						 max(1, dims(3)), max(1, dims(4)));
		images = patient.lungs;

		curImages = images(:,:,:);

		rois = curImages(y:y+h, x:x+w, :);

		montageFigure = figure();
		montage3(rois);

		ok = questdlg('Are all the regions of interest only noise?', 'Reselect Noise Region?', 'Yes');

		if not(strcmp(ok, 'Yes'))

			%handles = updateImagePanels(handles);

			%Finished with current task
			%handles.state = 'idle';
			handles.state = state;

			guidata(hObject, handles);
			updateStatusBox(handles, 'Reselect noise region and try again', 0);
			close(montageFigure);
			return;
		end

		close(montageFigure);
		axes(handles.axes2);
		%
		continueAnyways = displayWarningsAboutLungMasks(handles.patient(index));
		%
		if continueAnyways
			handles.patient(index).VLV = [];
			handles.patient(index).aVLV = [];
			wb = waitbar(0, {'Segmentation in Progress.',' If you click ''Cancel'', please wait for the function ',' to stop and the progress bar window to close ',' (it might take a few seconds). '},'createcancelbtn','setappdata(gcbf,''canceling'',1);');
			numImages = size(curImages, 3);
			for slice = 1:numImages
				if ~isempty(getappdata(wb,'canceling'))
					break;
				end
				roi = curImages(y:y+h, x:x+w, slice);
				[threshold, mean_noise] = calculate_noise(double(sort(roi(:))));
				handles.patient(index).threshold{slice} = threshold;
				handles.patient(index).mean_noise{slice} = mean_noise;
				handles.patient(index).lungmask(:,:,slice) = thresholdmask(curImages(:,:,slice), threshold, mean_noise);
				waitbar(slice/numImages, wb);
			end
			delete(wb);
			handles.leftpanel='L';
			handles.rightpanel='LM';
			updateStatusBox(handles, 'Images thresholded', 0);
		end

		%set(handles.analyze_threshold, 'Enable', 'on');
	elseif strcmp(state, 'def_lung_signal_and_noise_region')||strcmp(state, 'def_body_signal_and_noise_region')
		if strcmp(state, 'def_lung_signal_and_noise_region')
			images = patient.lungs;
		elseif strcmp(state, 'def_body_signal_and_noise_region')
			images = patient.body;
		end

		if strcmp(state, 'def_lung_signal_and_noise_region')
			dims_one = round(handles.panelOverlayData.SNR_lung_rectOne.getPosition);
		elseif strcmp(state, 'def_body_signal_and_noise_region')
			dims_one = round(handles.panelOverlayData.SNR_body_rectOne.getPosition);
		end

		[xOne yOne wOne hOne] = deal(max(1, dims_one(1)), max(1, dims_one(2)), ...
						 max(1, dims_one(3)), max(1, dims_one(4)));

		roi_one = images(yOne:yOne+hOne, xOne:xOne+wOne, :);

		if strcmp(state, 'def_lung_signal_and_noise_region')
			dims_two = round(handles.panelOverlayData.SNR_lung_rectTwo.getPosition);
		elseif strcmp(state, 'def_body_signal_and_noise_region')
			dims_two = round(handles.panelOverlayData.SNR_body_rectTwo.getPosition);
		end

		[xTwo yTwo wTwo hTwo] = deal(max(1, dims_two(1)), max(1, dims_two(2)), ...
						 max(1, dims_two(3)), max(1, dims_two(4)));

		roi_two = images(yTwo:yTwo+hTwo, xTwo:xTwo+wTwo, :);

		mask_signal = zeros([size(images,1), size(images,2), size(images,3)]);
		mask_noise = zeros([size(images,1), size(images,2), size(images,3)]);

		if mean(roi_one(:))>mean(roi_two(:))
			mask_signal(yOne:yOne+hOne, xOne:xOne+wOne, :) = 1;
			mask_noise(yTwo:yTwo+hTwo, xTwo:xTwo+wTwo, :) = 1;
			roi_signal = roi_one;
			roi_noise = roi_two;
		else
			mask_signal(yTwo:yTwo+hTwo, xTwo:xTwo+wTwo, :) = 1;
			mask_noise(yOne:yOne+hOne, xOne:xOne+wOne, :) = 1;
			roi_signal = roi_two;
			roi_noise = roi_one;
		end

		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		montageFigure = figure();
		montage3(roi_signal);

		ok = questdlg('Are all the regions of interest only signal?', 'Reselect Signal Region?', 'Yes');

		if not(strcmp(ok, 'Yes'))
			%handles = updateImagePanels(handles);

			%Finished with current task
			%handles.state = 'idle';
			handles.state = state;

			guidata(hObject, handles);
			updateStatusBox(handles, 'Reselect signal region and try again', 1);
			close(montageFigure);
			return;
		end

		close(montageFigure);

		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		montageFigure = figure();
		montage3(roi_noise);

		ok = questdlg('Are all the regions of interest only noise?', 'Reselect Noise Region?', 'Yes');

		if not(strcmp(ok, 'Yes'))
			%handles = updateImagePanels(handles);

			%Finished with current task
			%handles.state = 'idle';
			handles.state = state;

			guidata(hObject, handles);
			updateStatusBox(handles, 'Reselect noise region and try again', 1);
			close(montageFigure);
			return;
		end

		close(montageFigure);

		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		updateStatusBox(handles, 'SNR is stored in the patient data', 1);

		if strcmp(state, 'def_lung_signal_and_noise_region')
			handles.patient(index).lung_SNR = calculate_SNR(mask_signal,mask_noise,images);
		elseif strcmp(state, 'def_body_signal_and_noise_region')
			handles.patient(index).body_SNR = calculate_SNR(mask_signal,mask_noise,images);
		end
	elseif strcmp(state, 'def_coreg_landmarks')
		if any(size(handles.panelOverlayData.coreg_landmarks_lungs_x)~=size(handles.panelOverlayData.coreg_landmarks_body_x))
			handles.state = state;
			guidata(hObject, handles);
			errordlg('You must select the same number of points on both the lung image and body image!', '', 'modal');
			return;
		end
		%
		handles.panelOverlayData.coreg_landmarks_escape_pointer.Value = 1;
		%
		tform = coregister_landmarks(handles.panelOverlayData.coreg_landmarks_lungs_x, handles.panelOverlayData.coreg_landmarks_lungs_y, handles.panelOverlayData.coreg_landmarks_body_x, handles.panelOverlayData.coreg_landmarks_body_y);
		%
		index = handles.pat_index;
		slice = round(get(handles.slider_slice, 'Value'));
		patient = handles.patient(index);
		
		lungmask = patient.lungmask(:,:,slice);
		bodymask = patient.bodymask(:,:,slice);
		body = patient.body(:,:,slice);
		
		height = size(body,1);
		width = size(body,2);
		reg_body = imtransform(body, tform, 'xdata', [1, width], 'ydata', [1, height]);
		reg_bodymask = round(imtransform(bodymask, tform, 'xdata', [1, width], 'ydata', [1, height]));
		
		resultFigure = figure;
		screenSize = get(0, 'ScreenSize');
		set(resultFigure, 'position', [screenSize(3)*0.1,screenSize(4)*0.2,screenSize(3)*0.8,screenSize(4)*0.6])
		subplotAxes = tight_subplot(1,3,[.01 .03],[.1 .01],[.01 .01]);
		%
		axes(subplotAxes(1));
		lungsDouble = patient.lungs(:,:,slice);
		lungsDouble = double(lungsDouble);
		lungsDouble = (lungsDouble-min(lungsDouble(:)))/(max(lungsDouble(:))-min(lungsDouble(:)));
		imshow(maskOverlay(lungsDouble,patient.lungmask(:,:,slice)));
		hold on;
		for a=1:size(handles.panelOverlayData.coreg_landmarks_lungs_x)
			plot(handles.panelOverlayData.coreg_landmarks_lungs_x, handles.panelOverlayData.coreg_landmarks_lungs_y, 'y+');
		end
		hold off;
		%
		axes(subplotAxes(2));
		bodyDouble = patient.body(:,:,slice);
		bodyDouble = double(bodyDouble);
		bodyDouble = (bodyDouble-min(bodyDouble(:)))/(max(bodyDouble(:))-min(bodyDouble(:)));
		imshow(maskOverlay(bodyDouble,patient.bodymask(:,:,slice)));
		hold on;
		for a=1:size(handles.panelOverlayData.coreg_landmarks_body_x)
			plot(handles.panelOverlayData.coreg_landmarks_body_x, handles.panelOverlayData.coreg_landmarks_body_y, 'y+');
		end
		hold off;
		%
		axes(subplotAxes(3));
		reg_body = double(reg_body);
		reg_body = (reg_body-min(reg_body(:)))/(max(reg_body(:))-min(reg_body(:)));
		imshow(viewCoregistration(reg_body, reg_bodymask, lungmask));
		%
		apply = questdlg('Do you want to apply this transform to all slices?');
		close(resultFigure);
		continueAnyways = displayWarningsAboutImageTransformations(patient);
		if strcmpi(apply, 'Yes')&&continueAnyways
			for a=1:size(patient.body,3)
				%patient.body(:,:,a) = imtransform(patient.body(:,:,a), tform, 'xdata', [1 width], 'ydata', [1, height]);
				%patient.bodymask(:,:,a) = round(imtransform(patient.bodymask(:,:,a), tform, 'xdata', [1 width], 'ydata', [1, height]));
				%patient.tform{a} = tform;
				%
				patient = applyImageTransformationToPatientData(patient, tform, a);
			end
			%
			handles.patient(index) = patient;
		end
		%
		delete(handles.panelOverlayData.coreg_landmarks_lung_plot);
		delete(handles.panelOverlayData.coreg_landmarks_body_plot);
		delete(handles.panelOverlayData.coreg_landmarks_lung_text);
		delete(handles.panelOverlayData.coreg_landmarks_body_text);
		%
		handles.panelOverlayData = rmfield(handles.panelOverlayData, 'coreg_landmarks_lung_plot');
		handles.panelOverlayData = rmfield(handles.panelOverlayData, 'coreg_landmarks_body_plot');
		handles.panelOverlayData = rmfield(handles.panelOverlayData, 'coreg_landmarks_lung_text');
		handles.panelOverlayData = rmfield(handles.panelOverlayData, 'coreg_landmarks_body_text');
		handles.panelOverlayData = rmfield(handles.panelOverlayData, 'coreg_landmarks_lungs_x');
		handles.panelOverlayData = rmfield(handles.panelOverlayData, 'coreg_landmarks_lungs_y');
		handles.panelOverlayData = rmfield(handles.panelOverlayData, 'coreg_landmarks_body_x');
		handles.panelOverlayData = rmfield(handles.panelOverlayData, 'coreg_landmarks_body_y');
		%
		updateStatusBox(handles, 'Finished Coregistration', 1);
	elseif strcmp(state, 'def_max_signal_region')
		dims = round(handles.panelOverlayData.max_signal_rect.getPosition);
		[x y w h] = deal(max(1, dims(1)), max(1, dims(2)), ...
						 max(1, dims(3)), max(1, dims(4)));
		
		slice = round(get(handles.slider_slice, 'Value'));
		pat_index = handles.pat_index;
		
		curImage = patient.lungs(:,:,slice);
					 
		roi = curImage(y:y+h, x:x+w);
		
		totalAVLV = 0;
		numSlices = 0;
		
		for a=1:size(patient.lungmask,3)
			patient.aVLV(a) = calculateAbsVLV(mean(roi(:)),patient.parmslung,patient.lungs(:,:,a),patient.lungmask(:,:,a));
			totalAVLV = totalAVLV+patient.aVLV(a);
			if patient.aVLV(a)~=0
				numSlices = numSlices+1;
			end
			%patient.aVLV(a)
			%disp mm^3;
		end
		
		updateStatusBox(handles, ['The total absolute VLV (',num2str(numSlices),' slices) is: ',num2str(round(totalAVLV)),' mL'], 1);
		
		handles.patient(index) = patient;
		
	end
end

handles.overridepanelnocoreg = 0;
handles = updateImagePanels(handles);
updateMenuOptions(handles);
%Finished with current task
handles.state = 'idle';
set(handles.slider_slice, 'enable', 'on');
guidata(hObject, handles);

% --- Executes on button press in push_apply.
function push_apply_Callback(hObject, ~, handles)
% hObject    handle to push_apply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

state = handles.state;
handles.state = 'pause';
if size(handles.patient,2)~=0
	index = handles.pat_index;
	slice = get(handles.slider_slice, 'Value');
	patient = handles.patient(index);

	if strcmp(state, 'def_noiseregion')
		dims = round(handles.panelOverlayData.seg_lung_rect.getPosition);
		[x y w h] = deal(max(1, dims(1)), max(1, dims(2)), ...
						 max(1, dims(3)), max(1, dims(4)));
		images = patient.lungs;

		curImage = images(:,:,slice);

		roi = curImage(y:y+h, x:x+w);

		axes(handles.axes2);
		%calculate optimal threshold value and threshold image
		[threshold, mean_noise] = calculate_noise(double(sort(roi(:))));
		handles.patient(index).threshold{slice} = threshold;
		handles.patient(index).mean_noise{slice} = mean_noise;
	%         handles.patient(index).seglung(:,:,slice) = curImages(:,:,slice) > threshold;
		handles.patient(index).lungmask(:,:,slice) = thresholdmask(curImage, threshold, mean_noise);

		updateStatusBox(handles, 'Image thresholded', 0);

		%set(handles.analyze_threshold, 'Enable', 'on');
	elseif strcmp(state, 'def_lung_signal_and_noise_region')||strcmp(state, 'def_body_signal_and_noise_region')
		if strcmp(state, 'def_lung_signal_and_noise_region')
			curImage = patient.lungs(:,:,slice);
		elseif strcmp(state, 'def_body_signal_and_noise_region')
			curImage = patient.body(:,:,slice);
		end

		if strcmp(state, 'def_lung_signal_and_noise_region')
			dims_one = round(handles.panelOverlayData.SNR_lung_rectOne.getPosition);
		elseif strcmp(state, 'def_body_signal_and_noise_region')
			dims_one = round(handles.panelOverlayData.SNR_body_rectOne.getPosition);
		end

		[xOne yOne wOne hOne] = deal(max(1, dims_one(1)), max(1, dims_one(2)), ...
						 max(1, dims_one(3)), max(1, dims_one(4)));

		roi_one = curImage(yOne:yOne+hOne, xOne:xOne+wOne);

		if strcmp(state, 'def_lung_signal_and_noise_region')
			dims_two = round(handles.panelOverlayData.SNR_lung_rectTwo.getPosition);
		elseif strcmp(state, 'def_body_signal_and_noise_region')
			dims_two = round(handles.panelOverlayData.SNR_body_rectTwo.getPosition);
		end

		[xTwo yTwo wTwo hTwo] = deal(max(1, dims_two(1)), max(1, dims_two(2)), ...
						 max(1, dims_two(3)), max(1, dims_two(4)));

		roi_two = curImage(yTwo:yTwo+hTwo, xTwo:xTwo+wTwo);

		mask_signal = zeros([size(curImage,1), size(curImage,2)]);
		mask_noise = zeros([size(curImage,1), size(curImage,2)]);

		if mean(roi_one(:))>mean(roi_two(:))
			mask_signal(yOne:yOne+hOne, xOne:xOne+wOne) = 1;
			mask_noise(yTwo:yTwo+hTwo, xTwo:xTwo+wTwo) = 1;
		else
			mask_signal(yTwo:yTwo+hTwo, xTwo:xTwo+wTwo) = 1;
			mask_noise(yOne:yOne+hOne, xOne:xOne+wOne) = 1;
		end

		updateStatusBox(handles, 'SNR is stored in the patient data', 1);

		if strcmp(state, 'def_lung_signal_and_noise_region')
			patient.lung_SNR = zeros([size(patient.lungs,3),1]);
			patient.lung_SNR(slice) = calculate_SNR(mask_signal,mask_noise,curImage);
			updateStatusBox(handles, ['The SNR of the slice was: ',num2str(patient.lung_SNR(slice))], 0);
		elseif strcmp(state, 'def_body_signal_and_noise_region')
			patient.body_SNR = zeros([size(patient.body,3),1]);
			patient.body_SNR(slice) = calculate_SNR(mask_signal,mask_noise,curImage);
			updateStatusBox(handles, ['The SNR of the slice was: ',num2str(patient.body_SNR(slice))], 0);
		end
		handles.patient(index) = patient;
		guidata(hObject, handles);
	elseif strcmp(state, 'def_coreg_landmarks')
		if any(size(handles.panelOverlayData.coreg_landmarks_lungs_x)~=size(handles.panelOverlayData.coreg_landmarks_body_x))
			handles.state = state;
			guidata(hObject, handles);
			errordlg('You must select the same number of points on both the lung image and body image!', '', 'modal');
			return;
		end
		%
		handles.panelOverlayData.coreg_landmarks_escape_pointer.Value = 1;
		%
		tform = coregister_landmarks(handles.panelOverlayData.coreg_landmarks_lungs_x, handles.panelOverlayData.coreg_landmarks_lungs_y, handles.panelOverlayData.coreg_landmarks_body_x, handles.panelOverlayData.coreg_landmarks_body_y);
		%
		index = handles.pat_index;
		slice = round(get(handles.slider_slice, 'Value'));
		patient = handles.patient(index);
		
		lungmask = patient.lungmask(:,:,slice);
		bodymask = patient.bodymask(:,:,slice);
		body = patient.body(:,:,slice);
		
		height = size(body,1);
		width = size(body,2);
		reg_body = imtransform(body, tform, 'xdata', [1 width], 'ydata', [1, height]);
		reg_bodymask = round(imtransform(bodymask, tform, 'xdata', [1 width], 'ydata', [1, height]));
		
		resultFigure = figure;
		screenSize = get(0, 'ScreenSize');
		set(resultFigure, 'position', [screenSize(3)*0.1,screenSize(4)*0.2,screenSize(3)*0.8,screenSize(4)*0.6])
		subplotAxes = tight_subplot(1,3,[.01 .03],[.1 .01],[.01 .01]);
		%
		axes(subplotAxes(1));
		lungDouble = patient.lungs(:,:,slice);
		lungDouble = double(lungDouble);
		lungDouble = (lungDoublemin(lungDouble(:)))/(max(lungDouble(:))-min(lungDouble(:)));
		imshow(maskOverlay(lungDouble,patient.lungmask(:,:,slice)));
		hold on;
		for a=1:size(handles.panelOverlayData.coreg_landmarks_lungs_x)
			plot(handles.panelOverlayData.coreg_landmarks_lungs_x, handles.panelOverlayData.coreg_landmarks_lungs_y, 'y+');
		end
		hold off;
		%
		axes(subplotAxes(2));
		bodyDouble = patient.body(:,:,slice);
		bodyDouble = double(bodyDouble);
		bodyDouble = (bodyDouble-min(bodyDouble(:)))/(max(bodyDouble(:))-min(bodyDouble(:)));
		imshow(maskOverlay(bodyDouble,patient.bodymask(:,:,slice)));
		hold on;
		for a=1:size(handles.panelOverlayData.coreg_landmarks_body_x)
			plot(handles.panelOverlayData.coreg_landmarks_body_x, handles.panelOverlayData.coreg_landmarks_body_y, 'y+');
		end
		hold off;
		%
		axes(subplotAxes(3));
		reg_body = double(reg_body);
		reg_body = (reg_body-min(reg_body(:)))/(max(reg_body(:))-min(reg_body(:)));
		imshow(viewCoregistration(reg_body, reg_bodymask, lungmask));
		%
		apply = questdlg('Do you want to apply this transform to this slice?');
		close(resultFigure);
		continueAnyways = displayWarningsAboutImageTransformations(patient);
		if strcmpi(apply, 'Yes')&&continueAnyways
			%patient.body(:,:,slice) = reg_body;
			%patient.bodymask(:,:,slice) = reg_bodymask;
			%patient.tform{slice} = tform;
			%
			patient = applyImageTransformationToPatientData(patient, tform, slice);
			%
			handles.patient(index) = patient;
		end
		%
		delete(handles.panelOverlayData.coreg_landmarks_lung_plot);
		delete(handles.panelOverlayData.coreg_landmarks_body_plot);
		delete(handles.panelOverlayData.coreg_landmarks_lung_text);
		delete(handles.panelOverlayData.coreg_landmarks_body_text);
		%
		handles.panelOverlayData = rmfield(handles.panelOverlayData, 'coreg_landmarks_lung_plot');
		handles.panelOverlayData = rmfield(handles.panelOverlayData, 'coreg_landmarks_body_plot');
		handles.panelOverlayData = rmfield(handles.panelOverlayData, 'coreg_landmarks_lung_text');
		handles.panelOverlayData = rmfield(handles.panelOverlayData, 'coreg_landmarks_body_text');
		handles.panelOverlayData = rmfield(handles.panelOverlayData, 'coreg_landmarks_lungs_x');
		handles.panelOverlayData = rmfield(handles.panelOverlayData, 'coreg_landmarks_lungs_y');
		handles.panelOverlayData = rmfield(handles.panelOverlayData, 'coreg_landmarks_body_x');
		handles.panelOverlayData = rmfield(handles.panelOverlayData, 'coreg_landmarks_body_y');
		%
		updateStatusBox(handles, 'Finished Coregistration', 1);
	elseif strcmp(state, 'def_max_signal_region')
		
		handles.state = state;
		guidata(hObject, handles);
		errordlg('You must apply this to all slices (click "Apply To All" instead of "Apply").', '', 'modal');
		return;
		
	end
end

handles.overridepanelnocoreg = 0;
handles = updateImagePanels(handles);
updateMenuOptions(handles);
%Finished with current task
handles.state = 'idle';
set(handles.slider_slice, 'enable', 'on');
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_view_Callback(hObject, eventdata, handles)
% hObject    handle to menu_view (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function view_left_Callback(hObject, eventdata, handles)
% hObject    handle to view_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function view_right_Callback(hObject, eventdata, handles)
% hObject    handle to view_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function viewright_lungs_Callback(hObject, eventdata, handles)
% hObject    handle to viewright_lungs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.rightpanel = 'L';
handles = updateSliceSlider(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function viewright_lungmask_Callback(hObject, eventdata, handles)
% hObject    handle to viewright_lungmask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.rightpanel = 'LM';
handles = updateSliceSlider(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function viewright_body_Callback(hObject, eventdata, handles)
% hObject    handle to viewright_body (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.rightpanel = 'B';
handles = updateSliceSlider(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function viewright_bodymask_Callback(hObject, eventdata, handles)
% hObject    handle to viewright_bodymask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.rightpanel = 'BM';
handles = updateSliceSlider(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function viewleft_lungs_Callback(hObject, eventdata, handles)
% hObject    handle to viewleft_lungs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.leftpanel = 'L';
handles = updateSliceSlider(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function viewleft_lungmask_Callback(hObject, eventdata, handles)
% hObject    handle to viewleft_lungmask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.leftpanel = 'LM';
handles = updateSliceSlider(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function viewleft_body_Callback(hObject, eventdata, handles)
% hObject    handle to viewleft_body (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.leftpanel = 'B';
handles = updateSliceSlider(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function viewleft_bodymask_Callback(hObject, eventdata, handles)
% hObject    handle to viewleft_bodymask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.leftpanel = 'BM';
handles = updateSliceSlider(handles);
guidata(hObject, handles);


% --------------------------------------------------------------------
function analyze_manual_Callback(hObject, eventdata, handles)
% hObject    handle to analyze_manual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function manual_ladd_Callback(hObject, eventdata, handles)
% hObject    handle to manual_ladd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(handles.leftpanel, 'LM')
	lungMaskAxes = handles.axes1;
elseif strcmp(handles.rightpanel, 'LM')
	lungMaskAxes = handles.axes2;
else
	handles.rightpanel = 'LM';
	lungMaskAxes = handles.axes2;
	handles = updateSliceSlider(handles);
	guidata(hObject, handles);
end

index = handles.pat_index;
slice = round(get(handles.slider_slice, 'Value'));

if slice == 0
	%This must be a blank patient.
	updateStatusBox(handles, 'No lung images found.', 1);
	return;
end

mask = handles.patient(index).lungmask(:,:,slice);

updateStatusBox(handles, 'Select the area you want to add.', 1);

set(handles.figure1, 'currentaxes', lungMaskAxes);

roi = roipoly();

if isempty(roi)
	return;
end

mask = mask | roi;

continueAnyways = displayWarningsAboutLungMasks(handles.patient(index));
%
if continueAnyways
	handles.patient(index).VLV = [];
	handles.patient(index).aVLV = [];
	handles.patient(index).lungmask(:,:,slice) = mask;
end

handles = updateImagePanels(handles);

guidata(hObject, handles);

% --------------------------------------------------------------------
function manual_lremove_Callback(hObject, eventdata, handles)
% hObject    handle to manual_lremove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(handles.leftpanel, 'LM')
	lungMaskAxes = handles.axes1;
elseif strcmp(handles.rightpanel, 'LM')
	lungMaskAxes = handles.axes2;
else
	handles.rightpanel = 'LM';
	lungMaskAxes = handles.axes2;
	handles = updateSliceSlider(handles);
	guidata(hObject, handles);
end

index = handles.pat_index;
slice = round(get(handles.slider_slice, 'Value'));

if slice == 0
	%This must be a blank patient.
	updateStatusBox(handles, 'No lung images found.', 1);
	return;
end

mask = handles.patient(index).lungmask(:,:,slice);

updateStatusBox(handles, 'Select the area you want to remove.',1);

set(handles.figure1, 'currentaxes', lungMaskAxes);

roi = roipoly();

if isempty(roi)
	return;
end

mask = mask & ~roi;

continueAnyways = displayWarningsAboutLungMasks(handles.patient(index));
%
if continueAnyways
	handles.patient(index).VLV = [];
	handles.patient(index).aVLV = [];
	handles.patient(index).lungmask(:,:,slice) = mask;
end

handles = updateImagePanels(handles);

guidata(hObject, handles)

% --------------------------------------------------------------------
function manual_lremoveall_Callback(hObject, eventdata, handles)
% hObject    handle to manual_lremoveall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index = handles.pat_index;
slice = round(get(handles.slider_slice, 'Value'));

if slice == 0
	%This must be a blank patient.
	updateStatusBox(handles, 'No lung images found.', 1);
	return;
end

continueAnyways = displayWarningsAboutLungMasks(handles.patient(index));
%
if continueAnyways
	handles.patient(index).VLV = [];
	handles.patient(index).aVLV = [];
	handles.patient(index).lungmask(:,:,slice) = zeros(size(handles.patient(index).lungmask(:,:,slice)));
end

handles = updateImagePanels(handles);

guidata(hObject, handles);

% --------------------------------------------------------------------
function manual_lungmask_Callback(hObject, eventdata, handles)
% hObject    handle to manual_lungmask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function manual_bodymask_Callback(hObject, eventdata, handles)
% hObject    handle to manual_bodymask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function manual_badd_Callback(hObject, eventdata, handles)
% hObject    handle to manual_badd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(handles.leftpanel, 'BM')
	bodyMaskAxes = handles.axes1;
elseif strcmp(handles.rightpanel, 'BM')
	bodyMaskAxes = handles.axes2;
else
	handles.rightpanel = 'BM';
	bodyMaskAxes = handles.axes2;
	handles = updateSliceSlider(handles);
	guidata(hObject, handles);
end

handles.overridepanelnocoreg = 1;
handles = updateImagePanels(handles);

index = handles.pat_index;
slice = round(get(handles.slider_slice, 'Value'));

if slice == 0
	%This must be a blank patient.
	updateStatusBox(handles, 'No body images found.', 1);
	return;
end

mask = handles.patient(index).bodymask(:,:,slice);

updateStatusBox(handles, 'Select the area you want to add.',1);

set(handles.figure1, 'currentaxes', bodyMaskAxes);

roi = roipoly();

if isempty(roi)
	return;
end

mask = mask | roi;

continueAnyways = displayWarningsAboutBodyMasks(handles.patient(index));
%
if continueAnyways
	handles.patient(index).TLV = [];
	handles.patient(index).aTLV = [];
	handles.patient(index).TLV_coreg = [];
	handles.patient(index).aTLV_coreg = [];
	
	handles.patient(index).bodymask(:,:,slice) = mask;

	for a=1:size(handles.patient(index).bodymask,3)
		handles.patient(index) = applyImageTransformationToPatientData(handles.patient(index), handles.patient(index).tform{a}, a);
	end
end
handles.overridepanelnocoreg = 0;
handles = updateImagePanels(handles);

guidata(hObject, handles)


% --------------------------------------------------------------------
function manual_bremove_Callback(hObject, eventdata, handles)
% hObject    handle to manual_bremove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(handles.leftpanel, 'BM')
	bodyMaskAxes = handles.axes1;
elseif strcmp(handles.rightpanel, 'BM')
	bodyMaskAxes = handles.axes2;
else
	handles.rightpanel = 'BM';
	bodyMaskAxes = handles.axes2;
	handles = updateSliceSlider(handles);
	guidata(hObject, handles);
end

handles.overridepanelnocoreg = 1;
handles = updateImagePanels(handles);

index = handles.pat_index;
slice = round(get(handles.slider_slice, 'Value'));

if slice == 0
	%This must be a blank patient.
	updateStatusBox(handles, 'No body images found.', 1);
	return;
end

mask = handles.patient(index).bodymask(:,:,slice);

updateStatusBox(handles, 'Select the area you want to remove.',1);

set(handles.figure1, 'currentaxes', bodyMaskAxes);

roi = roipoly();

if isempty(roi)
	return;
end

mask = mask & ~roi;

continueAnyways = displayWarningsAboutBodyMasks(handles.patient(index));
%
if continueAnyways
	handles.patient(index).TLV = [];
	handles.patient(index).aTLV = [];
	handles.patient(index).TLV_coreg = [];
	handles.patient(index).aTLV_coreg = [];
	
	handles.patient(index).bodymask(:,:,slice) = mask;

	for a=1:size(handles.patient(index).bodymask,3)
		handles.patient(index) = applyImageTransformationToPatientData(handles.patient(index), handles.patient(index).tform{a}, a);
	end
end

handles.overridepanelnocoreg = 0;
handles = updateImagePanels(handles);

guidata(hObject, handles)


% --------------------------------------------------------------------
function analyze_segbody_Callback(hObject, eventdata, handles)
% hObject    handle to analyze_segbody (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
handles = updateImagePanels(handles);
%
index = handles.pat_index;
patient = handles.patient(index);
body_images = patient.body;

continueAnyways = displayWarningsAboutBodyMasks(handles.patient(index));
%
if continueAnyways
	handles.patient(index).TLV = [];
	handles.patient(index).aTLV = [];
	handles.patient(index).TLV_coreg = [];
	handles.patient(index).aTLV_coreg = [];
	
	updateStatusBox(handles, 'Preparing to segment body', 1);
	updateStatusBox(handles, 'Attempting to segment automatically', 0);

	% handles.state = 'def_autobodyseg';

	axes(handles.axes2);
	numImages = size(body_images, 3);
	wb = waitbar(0, {'Segmenting Lung Cavities',' If you click ''Cancel'', please wait for the function ',' to stop and the progress bar window to close ',' (it might take a few seconds). '},'createcancelbtn','setappdata(gcbf,''canceling'',1);');
	for slice = 1:numImages
		if ~isempty(getappdata(wb,'canceling'))
			break;
		end
		waitbar(slice/numImages, wb);
		patient.bodymask(:,:,slice) = regiongrow_mask(body_images(:,:,slice));
		% NOTE: bodymask is still a double, even though it was set to uint8 in regiongrow_mask
	end
	delete(wb);

	handles.patient(index) = patient;
	handles.leftpanel = 'B';
	handles.rightpanel = 'BM';

	handles = updateSliceSlider(handles);
	updateMenuOptions(handles);
end

guidata(hObject, handles);


% --- Executes on button press in push_cancel.
function push_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to push_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%handles = updateImagePanels(handles);
if strcmp(handles.state,'def_coreg_landmarks')
	handles.panelOverlayData.coreg_landmarks_escape_pointer.Value = 1;
	%
	delete(handles.panelOverlayData.coreg_landmarks_lung_plot);
	delete(handles.panelOverlayData.coreg_landmarks_body_plot);
	delete(handles.panelOverlayData.coreg_landmarks_lung_text);
	delete(handles.panelOverlayData.coreg_landmarks_body_text);
	%
	handles.panelOverlayData = rmfield(handles.panelOverlayData, 'coreg_landmarks_lung_plot');
	handles.panelOverlayData = rmfield(handles.panelOverlayData, 'coreg_landmarks_body_plot');
	handles.panelOverlayData = rmfield(handles.panelOverlayData, 'coreg_landmarks_lung_text');
	handles.panelOverlayData = rmfield(handles.panelOverlayData, 'coreg_landmarks_body_text');
	handles.panelOverlayData = rmfield(handles.panelOverlayData, 'coreg_landmarks_lungs_x');
	handles.panelOverlayData = rmfield(handles.panelOverlayData, 'coreg_landmarks_lungs_y');
	handles.panelOverlayData = rmfield(handles.panelOverlayData, 'coreg_landmarks_body_x');
	handles.panelOverlayData = rmfield(handles.panelOverlayData, 'coreg_landmarks_body_y');
end
set(handles.slider_slice, 'enable', 'on');
handles.overridepanelnocoreg = 0;
handles = updateImagePanels(handles);
updateMenuOptions(handles);
handles.state = 'idle';
guidata(hObject, handles);


% --- Executes on button press in push_up.
function push_up_Callback(hObject, eventdata, handles)
% hObject    handle to push_up (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in push_right.
function push_right_Callback(hObject, eventdata, handles)
% hObject    handle to push_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in push_down.
function push_down_Callback(hObject, eventdata, handles)
% hObject    handle to push_down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in push_left.
function push_left_Callback(hObject, eventdata, handles)
% hObject    handle to push_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function viewright_coreg_Callback(hObject, eventdata, handles)
% hObject    handle to viewright_coreg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.rightpanel = 'C';
updateStatusBox(handles, 'Lungs: Purple Body: Green', 1);
handles = updateSliceSlider(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function viewleft_coreg_Callback(hObject, eventdata, handles)
% hObject    handle to viewleft_coreg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.leftpanel = 'C';
updateStatusBox(handles, 'Lungs: Purple, Body: Green', 1);
handles = updateImagePanels(handles);
guidata(hObject, handles);


% --------------------------------------------------------------------
function viewright_hetero_Callback(hObject, eventdata, handles)
% hObject    handle to viewright_hetero (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.rightpanel = 'H';
% updateStatusBox(handles, 'Lungs: Purple Body: Green', 1);
handles = updateSliceSlider(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function viewleft_hetero_Callback(hObject, eventdata, handles)
% hObject    handle to viewleft_hetero (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.leftpanel = 'H';
% updateStatusBox(handles, 'Lungs: Purple Body: Green', 1);
handles = updateSliceSlider(handles);
guidata(hObject, handles);


% --------------------------------------------------------------------
function analyze_coreg_cc_Callback(hObject, eventdata, handles)
% hObject    handle to analyze_coreg_cc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pat_index = handles.pat_index;

num_slices = min(size(handles.patient(pat_index).lungmask, 3), size(handles.patient(pat_index).bodymask, 3));

tform = cell(1);

for a=1:num_slices
	lungmask = handles.patient(pat_index).lungmask(:,:,a);
	bodymask = handles.patient(pat_index).bodymask(:,:,a);

	tform{a} = coregister_crosscorrelation(imresize(lungmask,size(bodymask)), bodymask);
end

continueAnyways = displayWarningsAboutImageTransformations(handles.patient(pat_index));

if continueAnyways
	for a=1:num_slices
		handles.patient(pat_index) = applyImageTransformationToPatientData(handles.patient(pat_index), tform{a}, a);
		%{
		patient(pat_index).tform{a} = tform;

		height = size(patient(pat_index).lungmask(:,:,a),1);
		width = size(patient(pat_index).lungmask(:,:,a),2);

		patient(pat_index).bodymask(:,:,a) = round(imtransform(patient(pat_index).bodymask(:,:,a), tform, 'XYScale', 1, 'XData',[1 width],'YData',[1 height]));
		patient(pat_index).body(:,:,a) = imtransform(patient(pat_index).body(:,:,a), tform, 'XYScale', 1, 'XData',[1 width],'YData',[1 height]);
		%}
	end
end

handles = updateImagePanels(handles);

guidata(hObject, handles);


% --------------------------------------------------------------------
function manual_addseed_Callback(hObject, eventdata, handles)
% hObject    handle to manual_addseed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

patient = handles.patient;
pat_index = handles.pat_index;
slice = round(get(handles.slider_slice, 'Value'));

continueAnyways = displayWarningsAboutBodyMasks(handles.patient(pat_index));
%
if continueAnyways
	handles.patient(index).TLV = [];
	handles.patient(index).aTLV = [];
	handles.patient(index).TLV_coreg = [];
	handles.patient(index).aTLV_coreg = [];
	
	bodyimg = patient(pat_index).body(:,:,slice);
	bodymask = patient(pat_index).bodymask(:,:,slice);

	handles.leftpanel='BM';
	handles.overridepanelnocoreg = 1;
	handles = updateImagePanels(handles);

	tolerance = uint8(str2double(get(handles.edit_tolerance, 'String')));


	%newbodymask = manual_regiongrow( image, oldmask, seed )
	[x, y] = getpts(handles.axes1);
	x = uint16(x);
	y = uint16(y);

	set(handles.push_undoseed, 'UserData', bodymask);

	for i = 1:length(x)
		newbodymask = segmentRegion(tolerance, bodyimg, y(i), x(i));
	%     newbodymask2 = BWregionGrowing(bodyimg, x(i), y(i));

		bodymask = bodymask | newbodymask;
	end

	handles.patient(pat_index).bodymask(:,:,slice) = bodymask;

	for a=1:size(handles.patient(pat_index).bodymask,3)
		handles.patient(pat_index) = applyImageTransformationToPatientData(handles.patient(pat_index), handles.patient(pat_index).tform{a}, a);
	end

	handles.overridepanelnocoreg = 0;
	
	bodyDouble = double(bodyimg);
	bodyDouble = (bodyDouble-min(bodyDouble(:)))/(max(bodyDouble(:))-min(bodyDouble(:)));
	imagesc(maskOverlay(bodyDouble, bodymask));
end

guidata(hObject, handles);


function edit_tolerance_Callback(hObject, eventdata, handles)
% hObject    handle to edit_tolerance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_tolerance as text
%        str2double(get(hObject,'String')) returns contents of edit_tolerance as a double


% --- Executes during object creation, after setting all properties.
function edit_tolerance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_tolerance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_undoseed.
function push_undoseed_Callback(hObject, eventdata, handles)
% hObject    handle to push_undoseed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% patient = handles.patient;
index = handles.pat_index;
slice = get(handles.slider_slice, 'Value');

saved_mask = get(hObject, 'UserData');

set(hObject, 'UserData', handles.patient(index).bodymask(:,:,slice));

handles.patient(index).bodymask(:,:,slice) = saved_mask;

handles = updateImagePanels(handles);

guidata(hObject, handles);


% --------------------------------------------------------------------
function export_left_Callback(hObject, eventdata, handles)
% hObject    handle to export_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% saveImage(handles, 'left', 'tif')
exportImage(handles, 'left');

% --------------------------------------------------------------------
function export_right_Callback(hObject, eventdata, handles)
% hObject    handle to export_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
exportImage(handles, 'right') 


% --------------------------------------------------------------------
function file_export_Callback(hObject, eventdata, handles)
% hObject    handle to file_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function analyze_hetero_Callback(hObject, eventdata, handles)
% hObject    handle to analyze_hetero (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

updateStatusBox(handles, 'Beginning heterogeneity calculation', 1);


index = handles.pat_index;
slice = get(handles.slider_slice, 'Value');

patient = handles.patient(index);
lungs = patient.lungs;
lungmask = patient.lungmask;

if length(patient.mean_noise{slice}) < slice
%     threshold = 0;
	noise = 0;
else
%     threshold = patient.threshold{slice};
	noise = patient.mean_noise{slice};
end

if not(noise)
	noise = 0;
end

hetero_images = zeros(size(patient.hetero_images));
% hetero_score = zeros(size(patient.lungs, 3));

wb = waitbar(0, {'Calculating Heterogeneity...',' If you click ''Cancel'', please wait for the function ',' to stop and the progress bar window to close ',' (it might take a few seconds). '},'createcancelbtn','setappdata(gcbf,''canceling'',1);');
for i = 1:size(lungs, 3)
	if ~isempty(getappdata(wb,'canceling'))
		break;
	end
	waitbar(i/size(lungs, 3), wb);
	hetero = heterogeneity(lungs(:,:,i), lungmask(:,:,i), noise);

	hetero_images(:,:,i) = hetero;

%     hetero_score(i) = sum(hetero) / sum(lungmask(:,:,i));
end
delete(wb);

%Normalization needs improvement if it is to be compared across patients
% hetero_images = hetero_images ./ max(hetero_images(:)) * 255;
patient.hetero_images = hetero_images;
% patient.hetero_score = hetero_score;
handles.patient(index) = patient;

updateStatusBox(handles, 'Finished heterogeneity calculation', 1);
set(handles.viewleft_hetero, 'Enable', 'on');
set(handles.viewright_hetero, 'Enable', 'on');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --------------------------------------------------------------------
function calculate_lung_SNR_segmentation_Callback(hObject, eventdata, handles)
% hObject    handle to calculate_lung_SNR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
index = handles.pat_index;
patient = handles.patient(index);
%
lungmask = patient.lungmask;
lungs = patient.lungs;
if max(max(max(lungmask)))==0
	error('Need to segment the lungs first.');
end
patient.lung_SNR = calculate_SNR(lungmask,1-lungmask,lungs);
handles.patient(index) = patient;
guidata(hObject, handles);


% --------------------------------------------------------------------
function calculate_body_SNR_segmentation_Callback(hObject, eventdata, handles)
% hObject    handle to calculate_body_SNR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
index = handles.pat_index;
patient = handles.patient(index);
%
bodymask = patient.bodymask;
lungs = patient.lungs;
if max(max(max(bodymask)))==0
	error('Need to segment the lungs first.');
end
patient.body_SNR = calculate_SNR(bodymask,1-bodymask,lungs);
handles.patient(index) = patient;
guidata(hObject, handles);


% --------------------------------------------------------------------
function calculate_lung_SNR_bounding_box_Callback(hObject, eventdata, handles)
% hObject    handle to calculate_lung_SNR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
handles.state = 'def_lung_signal_and_noise_region';
handles.overridepanelnocoreg = 1;
handles = updateImagePanels(handles);
guidata(hObject, handles);
initUpdatePanelOverlay(hObject);
%


% --------------------------------------------------------------------
function calculate_body_SNR_bounding_box_Callback(hObject, eventdata, handles)
% hObject    handle to calculate_body_SNR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
handles.state = 'def_body_signal_and_noise_region';
handles.overridepanelnocoreg = 1;
handles = updateImagePanels(handles);
guidata(hObject, handles);
initUpdatePanelOverlay(hObject);
%


% --------------------------------------------------------------------
function analyze_heteroscore_Callback(hObject, eventdata, handles)
% hObject    handle to analyze_heteroscore (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
patients = handles.patient;
pat_index = handles.pat_index;

ids = {patients(:).id};

if isempty(ids) 
%     file_loadpatient_Callback(hObject, eventdata, handles)
		msg = sprintf('No patients selected');
		updateStatusBox(handles, msg, 1);
else
	[selection, ok] = listdlg('PromptString', 'Select a patient:', ...
							  'ListString', ids, 'SelectionMode', 'multiple', ...
							  'InitialValue', pat_index);

	if ok

		msg = sprintf('Calculating heterogeneity scores');
		updateStatusBox(handles, msg, 1);

		selected = patients(selection);

		scored_patients = heteroscore(selected);
		patients(selection) = scored_patients;
		handles.patient = patients;

		msg = sprintf('Finished Calculating heterogeneity scores');
		updateStatusBox(handles, msg, 0);

%             handles = updateSliceSlider(handles);

%             updateViewOptions(handles);
%             updateMenuOptions(handles);
		guidata(hObject, handles);
	end
end


% --------------------------------------------------------------------
function slice_lung_add_beginning_Callback(hObject, eventdata, handles)
% hObject    handle to slice_lung_add_beginning (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index = handles.pat_index;
%
handles.patient(index).lungs = cat(3, zeros(size(handles.patient(index).lungs(:,:,1))), handles.patient(index).lungs);
handles.patient(index).lungmask = cat(3, zeros(size(handles.patient(index).lungmask(:,:,1))), handles.patient(index).lungmask);
handles.patient(index).hetero_images = cat(3, zeros(size(handles.patient(index).hetero_images(:,:,1))), handles.patient(index).hetero_images);
if size(handles.patient(index).mean_noise,2)~=0
	handles.patient(index).mean_noise = cat(2, 0, handles.patient(index).mean_noise);
end
if size(handles.patient(index).threshold,2)~=0
	handles.patient(index).threshold = cat(2, 0, handles.patient(index).threshold);
end
if size(handles.patient(index).lung_SNR,2)~=0
	handles.patient(index).lung_SNR = cat(2, 0, handles.patient(index).lung_SNR);
end
if size(handles.patient(index).VLV,2)~=0
	handles.patient(index).VLV = cat(2, 0, handles.patient(index).VLV);
end
if size(handles.patient(index).aVLV,2)~=0
	handles.patient(index).aVLV = cat(2, 0, handles.patient(index).aVLV);
end
%
handles = updateSliceSlider(handles);
%
guidata(hObject, handles);


% --------------------------------------------------------------------
function slice_lung_add_end_Callback(hObject, eventdata, handles)
% hObject    handle to slice_lung_add_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index = handles.pat_index;
%
handles.patient(index).lungs = cat(3, handles.patient(index).lungs, zeros(size(handles.patient(index).lungs(:,:,1))));
handles.patient(index).lungmask = cat(3, handles.patient(index).lungmask, zeros(size(handles.patient(index).lungmask(:,:,1))));
handles.patient(index).hetero_images = cat(3, handles.patient(index).hetero_images, zeros(size(handles.patient(index).hetero_images(:,:,1))));
if size(handles.patient(index).mean_noise,2)~=0
	handles.patient(index).mean_noise = cat(2, handles.patient(index).mean_noise, 0);
end
if size(handles.patient(index).threshold,2)~=0
	handles.patient(index).threshold = cat(2, handles.patient(index).threshold, 0);
end
if size(handles.patient(index).lung_SNR,2)~=0
	handles.patient(index).lung_SNR = cat(2, handles.patient(index).lung_SNR, 0);
end
if size(handles.patient(index).VLV,2)~=0
	handles.patient(index).VLV = cat(2, handles.patient(index).VLV, 0);
end
if size(handles.patient(index).aVLV,2)~=0
	handles.patient(index).aVLV = cat(2, handles.patient(index).aVLV, 0);
end
%
handles = updateSliceSlider(handles);
%
guidata(hObject, handles);


% --------------------------------------------------------------------
function slice_lung_remove_beginning_Callback(hObject, eventdata, handles)
% hObject    handle to slice_lung_remove_beginning (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index = handles.pat_index;
%
handles.patient(index).lungs = handles.patient(index).lungs(:,:,2:end);
handles.patient(index).lungmask = handles.patient(index).lungmask(:,:,2:end);
handles.patient(index).hetero_images = handles.patient(index).hetero_images(:,:,2:end);
if size(handles.patient(index).mean_noise,2)~=0
	handles.patient(index).mean_noise = handles.patient(index).mean_noise(2:end);
end
if size(handles.patient(index).threshold,2)~=0
	handles.patient(index).threshold = handles.patient(index).threshold(2:end);
end
if size(handles.patient(index).lung_SNR,2)~=0
	handles.patient(index).lung_SNR = handles.patient(index).lung_SNR(2:end);
end
if size(handles.patient(index).VLV,2)~=0
	handles.patient(index).VLV = handles.patient(index).VLV(2:end);
end
if size(handles.patient(index).aVLV,2)~=0
	handles.patient(index).aVLV = handles.patient(index).aVLV(2:end);
end
%
handles = updateSliceSlider(handles);
%
guidata(hObject, handles);


% --------------------------------------------------------------------
function slice_lung_remove_end_Callback(hObject, eventdata, handles)
% hObject    handle to slice_lung_remove_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index = handles.pat_index;
%
handles.patient(index).lungs = handles.patient(index).lungs(:,:,1:end-1);
handles.patient(index).lungmask = handles.patient(index).lungmask(:,:,1:end-1);
handles.patient(index).hetero_images = handles.patient(index).hetero_images(:,:,1:end-1);
if size(handles.patient(index).mean_noise,2)~=0
	handles.patient(index).mean_noise = handles.patient(index).mean_noise(1:end-1);
end
if size(handles.patient(index).threshold,2)~=0
	handles.patient(index).threshold = handles.patient(index).threshold(1:end-1);
end
if size(handles.patient(index).lung_SNR,2)~=0
	handles.patient(index).lung_SNR = handles.patient(index).lung_SNR(1:end-1);
end
if size(handles.patient(index).VLV,2)~=0
	handles.patient(index).VLV = handles.patient(index).VLV(1:end-1);
end
if size(handles.patient(index).aVLV,2)~=0
	handles.patient(index).aVLV = handles.patient(index).aVLV(1:end-1);
end
%
handles = updateSliceSlider(handles);
%
guidata(hObject, handles);


% --------------------------------------------------------------------
function slice_body_add_beginning_Callback(hObject, eventdata, handles)
% hObject    handle to slice_body_add_beginning (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index = handles.pat_index;
%
handles.patient(index).body = cat(3, zeros(size(handles.patient(index).body(:,:,1))), handles.patient(index).body);
handles.patient(index).bodymask = cat(3, zeros(size(handles.patient(index).bodymask(:,:,1))), handles.patient(index).bodymask);
handles.patient(index).body_coreg = cat(3, zeros(size(handles.patient(index).body_coreg(:,:,1))), handles.patient(index).body_coreg);
handles.patient(index).bodymask_coreg = cat(3, zeros(size(handles.patient(index).bodymask_coreg(:,:,1))), handles.patient(index).bodymask_coreg);
handles.patient(index).tform = cat(1, [], handles.patient(index).tform);
if size(handles.patient(index).body_SNR,2)~=0
	handles.patient(index).body_SNR = cat(2, 0, handles.patient(index).body_SNR);
end
if size(handles.patient(index).TLV,2)~=0
	handles.patient(index).TLV = cat(2, 0, handles.patient(index).TLV);
end
if size(handles.patient(index).aTLV,2)~=0
	handles.patient(index).aTLV = cat(2, 0, handles.patient(index).aTLV);
end
if size(handles.patient(index).TLV_coreg,2)~=0
	handles.patient(index).TLV_coreg = cat(2, 0, handles.patient(index).TLV_coreg);
end
if size(handles.patient(index).aTLV_coreg,2)~=0
	handles.patient(index).aTLV_coreg = cat(2, 0, handles.patient(index).aTLV_coreg);
end
%
handles = updateSliceSlider(handles);
%
guidata(hObject, handles);


% --------------------------------------------------------------------
function slice_body_add_end_Callback(hObject, eventdata, handles)
% hObject    handle to slice_body_add_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index = handles.pat_index;
%
handles.patient(index).body = cat(3, handles.patient(index).body, zeros(size(handles.patient(index).body(:,:,1))));
handles.patient(index).bodymask = cat(3, handles.patient(index).bodymask, zeros(size(handles.patient(index).bodymask(:,:,1))));
handles.patient(index).body_coreg = cat(3, handles.patient(index).body_coreg, zeros(size(handles.patient(index).body_coreg(:,:,1))));
handles.patient(index).bodymask_coreg = cat(3, handles.patient(index).bodymask_coreg, zeros(size(handles.patient(index).bodymask_coreg(:,:,1))));
handles.patient(index).tform = cat(1, handles.patient(index).tform, []);
if size(handles.patient(index).body_SNR,2)~=0
	handles.patient(index).body_SNR = cat(2, handles.patient(index).body_SNR, 0);
end
if size(handles.patient(index).TLV,2)~=0
	handles.patient(index).TLV = cat(2, handles.patient(index).TLV, 0);
end
if size(handles.patient(index).aTLV,2)~=0
	handles.patient(index).aTLV = cat(2, handles.patient(index).aTLV, 0);
end
if size(handles.patient(index).TLV_coreg,2)~=0
	handles.patient(index).TLV_coreg = cat(2, handles.patient(index).TLV_coreg, 0);
end
if size(handles.patient(index).aTLV_coreg,2)~=0
	handles.patient(index).aTLV_coreg = cat(2, handles.patient(index).aTLV_coreg, 0);
end
%
handles = updateSliceSlider(handles);
%
guidata(hObject, handles);


% --------------------------------------------------------------------
function slice_body_remove_beginning_Callback(hObject, eventdata, handles)
% hObject    handle to slice_body_remove_beginning (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index = handles.pat_index;
%
handles.patient(index).body = handles.patient(index).body(:,:,2:end);
handles.patient(index).bodymask = handles.patient(index).bodymask(:,:,2:end);
handles.patient(index).body_coreg = handles.patient(index).body_coreg(:,:,2:end);
handles.patient(index).bodymask_coreg = handles.patient(index).bodymask_coreg(:,:,2:end);
handles.patient(index).tform = handles.patient(index).tform(2:end);
if size(handles.patient(index).body_SNR,2)~=0
	handles.patient(index).body_SNR = handles.patient(index).body_SNR(2:end);
end
if size(handles.patient(index).TLV,2)~=0
	handles.patient(index).TLV = handles.patient(index).TLV(2:end);
end
if size(handles.patient(index).aTLV,2)~=0
	handles.patient(index).aTLV = handles.patient(index).aTLV(2:end);
end
if size(handles.patient(index).TLV_coreg,2)~=0
	handles.patient(index).TLV_coreg = handles.patient(index).TLV_coreg(2:end);
end
if size(handles.patient(index).aTLV_coreg,2)~=0
	handles.patient(index).aTLV_coreg = handles.patient(index).aTLV_coreg(2:end);
end
%
handles = updateSliceSlider(handles);
%
guidata(hObject, handles);


% --------------------------------------------------------------------
function slice_body_remove_end_Callback(hObject, eventdata, handles)
% hObject    handle to slice_body_remove_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index = handles.pat_index;
%
handles.patient(index).body = handles.patient(index).body(:,:,1:end-1);
handles.patient(index).bodymask = handles.patient(index).bodymask(:,:,1:end-1);
handles.patient(index).body_coreg = handles.patient(index).body_coreg(:,:,1:end-1);
handles.patient(index).bodymask_coreg = handles.patient(index).bodymask_coreg(:,:,1:end-1);
handles.patient(index).tform = handles.patient(index).tform(1:end-1);
if size(handles.patient(index).body_SNR,2)~=0
	handles.patient(index).body_SNR = handles.patient(index).body_SNR(1:end-1);
end
if size(handles.patient(index).TLV,2)~=0
	handles.patient(index).TLV = handles.patient(index).TLV(1:end-1);
end
if size(handles.patient(index).aTLV,2)~=0
	handles.patient(index).aTLV = handles.patient(index).aTLV(1:end-1);
end
if size(handles.patient(index).TLV_coreg,2)~=0
	handles.patient(index).TLV_coreg = handles.patient(index).TLV_coreg(1:end-1);
end
if size(handles.patient(index).aTLV_coreg,2)~=0
	handles.patient(index).aTLV_coreg = handles.patient(index).aTLV_coreg(1:end-1);
end
%
handles = updateSliceSlider(handles);
%
guidata(hObject, handles);


% --------------------------------------------------------------------
function viewright_overlay_Callback(hObject, eventdata, handles)
% hObject    handle to viewright_overlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.rightpanel = 'O';
handles = updateSliceSlider(handles);
guidata(hObject, handles);


% --------------------------------------------------------------------
function viewleft_overlay_Callback(hObject, eventdata, handles)
% hObject    handle to viewleft_overlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.leftpanel = 'O';
handles = updateSliceSlider(handles);
guidata(hObject, handles);


% --------------------------------------------------------------------
function analyze_coreg_DFTcc_Callback(hObject, eventdata, handles)
% hObject    handle to analyze_coreg_DFTcc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pat_index = handles.pat_index;

num_slices = min(size(handles.patient(pat_index).lungmask, 3), size(handles.patient(pat_index).bodymask, 3));

tform = cell(1);

for a=1:num_slices
	lungmask = handles.patient(pat_index).lungmask(:,:,a);
	bodymask = handles.patient(pat_index).bodymask(:,:,a);

	tform{a} = coregister_DFTcrosscorrelation(imresize(lungmask,size(bodymask)), bodymask);
end

continueAnyways = displayWarningsAboutImageTransformations(handles.patient(pat_index));

if continueAnyways
	for a=1:num_slices
		handles.patient(pat_index) = applyImageTransformationToPatientData(handles.patient(pat_index), tform{a}, a);
		%{
		patient(pat_index).tform{a} = tform;

		height = size(patient(pat_index).lungmask(:,:,a),1);
		width = size(patient(pat_index).lungmask(:,:,a),2);

		patient(pat_index).bodymask(:,:,a) = round(imtransform(patient(pat_index).bodymask(:,:,a), tform, 'XYScale', 1, 'XData',[1 width],'YData',[1 height]));
		patient(pat_index).body(:,:,a) = imtransform(patient(pat_index).body(:,:,a), tform, 'XYScale', 1, 'XData',[1 width],'YData',[1 height]);
		%}
	end
end

handles = updateImagePanels(handles);

guidata(hObject, handles);


% --------------------------------------------------------------------
function view_left_showcoregistered_yes_Callback(hObject, eventdata, handles)
% hObject    handle to view_left_showcoregistered_yes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.leftpanelcoreg = 1;
updateMenuOptions(handles);
handles = updateImagePanels(handles);
guidata(hObject, handles);


% --------------------------------------------------------------------
function view_left_showcoregistered_no_Callback(hObject, eventdata, handles)
% hObject    handle to view_left_showcoregistered_no (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.leftpanelcoreg = 0;
updateMenuOptions(handles);
handles = updateImagePanels(handles);
guidata(hObject, handles);


% --------------------------------------------------------------------
function view_right_showcoregistered_yes_Callback(hObject, eventdata, handles)
% hObject    handle to view_right_showcoregistered_yes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.rightpanelcoreg = 1;
updateMenuOptions(handles);
handles = updateImagePanels(handles);
guidata(hObject, handles);


% --------------------------------------------------------------------
function view_right_showcoregistered_no_Callback(hObject, eventdata, handles)
% hObject    handle to view_right_showcoregistered_no (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.rightpanelcoreg = 0;
updateMenuOptions(handles);
handles = updateImagePanels(handles);
guidata(hObject, handles);


% --------------------------------------------------------------------
function analyze_coreg_remove_Callback(hObject, eventdata, handles)
% hObject    handle to analyze_coreg_remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pat_index = handles.pat_index;
%
tform = maketform('affine', eye(3));
%
continueAnyways = displayWarningsAboutImageTransformations(handles.patient(pat_index));
%
if continueAnyways
	for a=1:size(handles.patient(pat_index).body,3)
		handles.patient(pat_index) = applyImageTransformationToPatientData(handles.patient(pat_index), tform, a);
	end
end
%
handles = updateImagePanels(handles);
%
guidata(hObject, handles);


% --------------------------------------------------------------------
function analyze_LV_aVLV_Callback(hObject, ~, handles)
% hObject    handle to analyze_LV_aVLV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
handles.state = 'def_max_signal_region';
guidata(hObject, handles);
initUpdatePanelOverlay(hObject);
%


% --------------------------------------------------------------------
function analyze_LV_VLV_Callback(hObject, ~, handles)
% hObject    handle to analyze_LV_VLV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
patient = handles.patient;
pat_index = handles.pat_index;
%
totalVLV = 0;
%
numSlices = 0;
%
for a=1:size(patient(pat_index).lungmask,3)
	patient(pat_index).VLV(a) = calculateVLV(patient(pat_index).parmslung, patient(pat_index).lungmask(:,:,a));
	totalVLV = totalVLV+patient(pat_index).VLV(a);
	if patient(pat_index).VLV(a)~=0
		numSlices = numSlices+1;
	end
	%patient(pat_index).VLV(a)
	%disp mm^3;
end
%
updateStatusBox(handles, ['The total VLV (',num2str(numSlices),' slices) is: ',num2str(round(totalVLV)),' mL'], 1);
%
handles.patient = patient;
guidata(hObject, handles);
%


% --------------------------------------------------------------------
function analyze_LV_aTLV_Callback(hObject, ~, handles)
% hObject    handle to analyze_LV_aTLV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
patient = handles.patient;
pat_index = handles.pat_index;
%
totalATLV_original = 0;
totalATLV_coreg = 0;
%
numSlices = 0;
%
maxSignalH = max(patient(pat_index).body(logical(patient(pat_index).bodymask)));
%
for a=1:size(patient(pat_index).lungmask,3)
	patient(pat_index).aTLV(a) = calculateAbsTLV(maxSignalH, patient(pat_index).parmsbody, patient(pat_index).body(:,:,a), patient(pat_index).bodymask(:,:,a));
	totalATLV_original = totalATLV_original+patient(pat_index).aTLV(a);
	if patient(pat_index).aTLV(a)~=0
		numSlices = numSlices+1;
	end
	if sum(patient(pat_index).bodymask_coreg(:))~=0
		% if there is at least one slice that is coregistered
		if sum(sum(patient(pat_index).bodymask_coreg(:,:,a)))~=0
			% if the coregistration was performed at this slice
			patient(pat_index).aTLV_coreg(a) = calculateAbsTLV(maxSignalH, patient(pat_index).parmsbody, patient(pat_index).body_coreg(:,:,a), patient(pat_index).bodymask_coreg(:,:,a));
		else
			% use the original image because there is no coregistered slice here
			patient(pat_index).aTLV_coreg(a) = calculateAbsTLV(maxSignalH, patient(pat_index).parmsbody, patient(pat_index).body(:,:,a), patient(pat_index).bodymask(:,:,a));
		end
		totalATLV_coreg = totalATLV_coreg+patient(pat_index).aTLV_coreg(a);
	end
	%patient(pat_index).TLV(a)
	%disp mm^3;
end
%
if sum(patient(pat_index).bodymask_coreg(:))~=0&&round(totalTLV_original)~=round(totalTLV_coreg)
	updateStatusBox(handles, ['The total absolute TLV (before coregistration; ',num2str(numSlices),' slices) is: ',num2str(round(totalATLV_original)),' mL'], 1);
	updateStatusBox(handles, ['The total absolute TLV (after coregistration; ',num2str(numSlices),' slices) is: ',num2str(round(totalATLV_coreg)),' mL'], 0);
else
	updateStatusBox(handles, ['The total absolute TLV (',num2str(numSlices),' slices) is: ',num2str(round(totalATLV_original)),' mL'], 1);
end
%
handles.patient = patient;
guidata(hObject, handles);
%


% --------------------------------------------------------------------
function analyze_LV_TLV_Callback(hObject, ~, handles)
% hObject    handle to analyze_LV_TLV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
patient = handles.patient;
pat_index = handles.pat_index;
%
totalTLV_original = 0;
totalTLV_coreg = 0;
%
numSlices = 0;
%
for a=1:size(patient(pat_index).lungmask,3)
	patient(pat_index).TLV(a) = calculateTLV(patient(pat_index).parmsbody, patient(pat_index).bodymask(:,:,a));
	totalTLV_original = totalTLV_original+patient(pat_index).TLV(a);
	if patient(pat_index).TLV(a)~=0
		numSlices = numSlices+1;
	end
	if sum(patient(pat_index).bodymask_coreg(:))~=0
		% if there is at least one slice that is coregistered
		if sum(sum(patient(pat_index).bodymask_coreg(:,:,a)))~=0
			% if the coregistration was performed at this slice
			patient(pat_index).TLV_coreg(a) = calculateTLV(patient(pat_index).parmsbody, patient(pat_index).bodymask_coreg(:,:,a));
		else
			% use the original image because there is no coregistered slice here
			patient(pat_index).TLV_coreg(a) = calculateTLV(patient(pat_index).parmsbody, patient(pat_index).bodymask(:,:,a));
		end
		totalTLV_coreg = totalTLV_coreg+patient(pat_index).TLV_coreg(a);
	end
	%patient(pat_index).TLV(a)
	%disp mm^3;
end
%
if sum(patient(pat_index).bodymask_coreg(:))~=0&&totalTLV_original~=totalTLV_coreg
	updateStatusBox(handles, ['The total TLV (before coregistration; ',num2str(numSlices),' slices) is: ',num2str(round(totalTLV_original)),' mL'], 1);
	updateStatusBox(handles, ['The total TLV (after coregistration; ',num2str(numSlices),' slices) is: ',num2str(round(totalTLV_coreg)),' mL'], 0);
else
	updateStatusBox(handles, ['The total TLV (',num2str(numSlices),' slices) is: ',num2str(round(totalTLV_original)),' mL'], 1);
end
%
handles.patient = patient;
guidata(hObject, handles);
%


% --------------------------------------------------------------------
function view_overlaycolor_red_Callback(hObject, eventdata, handles)
% hObject    handle to view_overlaycolor_red (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
pat_index = handles.pat_index;
%
handles.patient(pat_index).overlayColor = [1 0 0];
%
handles = updateImagePanels(handles);
%
guidata(hObject, handles);

% --------------------------------------------------------------------
function view_overlaycolor_green_Callback(hObject, eventdata, handles)
% hObject    handle to view_overlaycolor_green (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
pat_index = handles.pat_index;
%
handles.patient(pat_index).overlayColor = [0 1 0];
%
handles = updateImagePanels(handles);
%
guidata(hObject, handles);


% --------------------------------------------------------------------
function view_overlaycolor_blue_Callback(hObject, eventdata, handles)
% hObject    handle to view_overlaycolor_blue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
pat_index = handles.pat_index;
%
handles.patient(pat_index).overlayColor = [0 0 1];
%
handles = updateImagePanels(handles);
%
guidata(hObject, handles);


% --------------------------------------------------------------------
function view_overlaycolor_yellow_Callback(hObject, eventdata, handles)
% hObject    handle to view_overlaycolor_yellow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
pat_index = handles.pat_index;
%
handles.patient(pat_index).overlayColor = [1 1 0];
%
handles = updateImagePanels(handles);
%
guidata(hObject, handles);


% --------------------------------------------------------------------
function view_overlaycolor_white_Callback(hObject, eventdata, handles)
% hObject    handle to view_overlaycolor_white (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
pat_index = handles.pat_index;
%
handles.patient(pat_index).overlayColor = [1 1 1];
%
handles = updateImagePanels(handles);
%
guidata(hObject, handles);


% --------------------------------------------------------------------
function analyze_coreg_expand_Callback(hObject, eventdata, handles)
% hObject    handle to analyze_coreg_expand (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pat_index = handles.pat_index;

num_slices = min(size(handles.patient(pat_index).lungmask, 3), size(handles.patient(pat_index).bodymask, 3));

tform = cell(1);

for a=1:num_slices
	lungmask = handles.patient(pat_index).lungmask(:,:,a);
	bodymask = handles.patient(pat_index).bodymask(:,:,a);

	tform{a} = coregister_expand(imresize(lungmask,size(bodymask)), bodymask);
end

%
continueAnyways = displayWarningsAboutImageTransformations(handles.patient(pat_index));

if continueAnyways
	for a=1:num_slices
		handles.patient(pat_index) = applyImageTransformationToPatientData(handles.patient(pat_index), tform{a}, a);
		%{
		patient(pat_index).tform{a} = tform;

		height = size(patient(pat_index).lungmask(:,:,a),1);
		width = size(patient(pat_index).lungmask(:,:,a),2);

		patient(pat_index).bodymask(:,:,a) = round(imtransform(patient(pat_index).bodymask(:,:,a), tform, 'XYScale', 1, 'XData',[1 width],'YData',[1 height]));
		patient(pat_index).body(:,:,a) = imtransform(patient(pat_index).body(:,:,a), tform, 'XYScale', 1, 'XData',[1 width],'YData',[1 height]);
		%}
	end
end

handles = updateImagePanels(handles);

guidata(hObject, handles);


% --------------------------------------------------------------------
function analyze_coreg_invert_Callback(hObject, eventdata, handles)
% hObject    handle to analyze_coreg_invert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pat_index = handles.pat_index;

num_slices = min(size(handles.patient(pat_index).lungmask, 3), size(handles.patient(pat_index).bodymask, 3));

tform = cell(1);

for a=1:num_slices
	lungmask = handles.patient(pat_index).lungmask(:,:,a);
	bodymask = handles.patient(pat_index).bodymask(:,:,a);
	lungs = handles.patient(pat_index).lungs(:,:,a);
	body = handles.patient(pat_index).body(:,:,a);
	tform{a} = coregister_invert(imresize(lungs,size(body)), body, imresize(lungmask,size(bodymask)), bodymask);
end

continueAnyways = displayWarningsAboutImageTransformations(handles.patient(pat_index));

if continueAnyways
	for a=1:num_slices
		handles.patient(pat_index) = applyImageTransformationToPatientData(handles.patient(pat_index), tform{a}, a);
		%{
		patient(pat_index).tform{a} = tform;

		height = size(patient(pat_index).lungmask(:,:,a),1);
		width = size(patient(pat_index).lungmask(:,:,a),2);

		patient(pat_index).bodymask(:,:,a) = round(imtransform(patient(pat_index).bodymask(:,:,a), tform, 'XYScale', 1, 'XData',[1 width],'YData',[1 height]));
		patient(pat_index).body(:,:,a) = imtransform(patient(pat_index).body(:,:,a), tform, 'XYScale', 1, 'XData',[1 width],'YData',[1 height]);
		%}
	end
end

handles = updateImagePanels(handles);

guidata(hObject, handles);













