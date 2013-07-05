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

% Last Modified by GUIDE v2.5 25-Jun-2013 23:18:30

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
jvscroll = findjobj(handles.slider_slice);
jvscroll.MouseDraggedCallback = {@scrollCallback, hObject, sliderUpdatePntr};
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

function scrollCallback(~, ~, mainFigure, sliderUpdatePntr)
handles = guidata(mainFigure);
if etime(clock,handles.sliderLastUpdated)>0.04%0.05
	handles.sliderLastUpdated = clock;
	guidata(mainFigure, handles);
	handles = updateImagePanels(handles, sliderUpdatePntr);
	guidata(mainFigure, handles);
end


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
set(handles.analyze_segbody, 'Enable', 'on');
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
function analyze_coreglm_Callback(hObject, eventdata, handles)
% hObject    handle to analyze_coreglm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateStatusBox(handles, 'Preparing to coregister images', 1);

%updateStatusBox(handles, 'Select a region of noise', 0);

[reg_bodymask, reg_body, tform] = coregister_landmarks(handles);
%

index = handles.pat_index;
slice = round(get(handles.slider_slice, 'Value'));
patient = handles.patient(index);

lungmask = patient.lungmask(:,:,slice);

% axes(handles.axes1);
% imagesc(patient.lungs(:,:,slice));

axes(handles.axes2);
% maskOverlay(reg_body, lungmask);
viewCoregistration(reg_body, reg_bodymask, lungmask);

apply = questdlg('Do you want to apply this transform?');
if strcmpi(apply, 'Yes')
	applyall = questdlg('Do you want to apply this transform to all images?');
	if strcmpi(applyall, 'Yes')
		body = patient.body;
		bodymask = patient.bodymask;
		height = size(body,1);
		width = size(body,2);
		for i = 1:size(body, 3)
			%reg_body = imtransform(body, tform, 'xdata', [1 width], 'ydata', [1, height]);
			%reg_bodymask = imtransform(bodymask, tform, 'xdata', [1 width], 'ydata', [1, height]);
			patient.body(:,:,i) = imtransform(body(:,:,i), tform, 'xdata', [1 width], 'ydata', [1, height]);
			patient.bodymask(:,:,i) = imtransform(bodymask(:,:,i), tform, 'xdata', [1 width], 'ydata', [1, height]);
		end
	else
		patient.body(:,:,slice) = reg_body;
		patient.bodymask(:,:,slice) = reg_bodymask;
		%patient.body_tform(slice) = tform;
	end
	handles.patient(index) = patient;

	guidata(hObject, handles);
end

updateStatusBox(handles, 'Finished Coregistration', 1);



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
		%calculate optimal threshold value and threshold image
		wb = waitbar(0, 'Segmentation in Progress');
		numImages = size(curImages, 3);
		for slice = 1:numImages
			roi = curImages(y:y+h, x:x+w, slice);
			[threshold, mean_noise] = calculate_noise(double(sort(roi(:))));
			handles.patient(index).threshold{slice} = threshold;
			handles.patient(index).mean_noise{slice} = mean_noise;
			%handles.patient(index).seglung(:,:,slice) = curImages(:,:,slice) > threshold;
			handles.patient(index).lungmask(:,:,slice) = thresholdmask(curImages(:,:,slice), threshold, mean_noise);
			waitbar(slice/numImages, wb);
		end
		close(wb);
		handles.leftpanel='L';
		handles.rightpanel='LM';
		updateStatusBox(handles, 'Images thresholded', 0);

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
	end
end

handles = updateImagePanels(handles);
updateMenuOptions(handles);
%Finished with current task
handles.state = 'idle';
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
	end
end

handles = updateImagePanels(handles);
updateMenuOptions(handles);
%Finished with current task
handles.state = 'idle';
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
handles.patient(index).lungmask(:,:,slice) = mask;

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
handles.patient(index).lungmask(:,:,slice) = mask;

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

handles.patient(index).lungmask(:,:,slice) = zeros(size(handles.patient(index).lungmask(:,:,slice)));

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
handles.patient(index).bodymask(:,:,slice) = mask;

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
size(roi)
if isempty(roi)
	return;
end

mask = mask & ~roi;
handles.patient(index).bodymask(:,:,slice) = mask;

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

updateStatusBox(handles, 'Preparing to segment body', 1);
updateStatusBox(handles, 'Attempting to segment automatically', 0);

% handles.state = 'def_autobodyseg';

axes(handles.axes2);
numImages = size(body_images, 3);
wb = waitbar(0, 'Segmenting Lung Cavities');
for slice = 1:numImages
	waitbar(slice/numImages, wb);
	patient.bodymask(:,:,slice) = regiongrow_mask(body_images(:,:,slice));
end
close(wb);

handles.patient(index) = patient;
handles.leftpanel = 'B';
handles.rightpanel = 'BM';

handles = updateSliceSlider(handles);
updateMenuOptions(handles);

guidata(hObject, handles);


% --- Executes on button press in push_cancel.
function push_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to push_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%handles = updateImagePanels(handles);
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
function analyze_coreg_Callback(hObject, eventdata, handles)
% hObject    handle to analyze_coreg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function manual_addseed_Callback(hObject, eventdata, handles)
% hObject    handle to manual_addseed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

patient = handles.patient;
pat_index = handles.pat_index;
slice = get(handles.slider_slice, 'Value');

bodyimg = patient(pat_index).body(:,:,slice);
bodymask = patient(pat_index).bodymask(:,:,slice);

handles.leftpanel='BM';
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

imagesc(maskOverlay(bodyimg, bodymask));

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

wb = waitbar(0, 'Calculating Heterogeneity...');
for i = 1:size(lungs, 3)
	waitbar(i/size(lungs, 3), wb);
	hetero = heterogeneity(lungs(:,:,i), lungmask(:,:,i), noise);

	hetero_images(:,:,i) = hetero;

%     hetero_score(i) = sum(hetero) / sum(lungmask(:,:,i));
end
close(wb);

%Normalization needs improvement if it is to be compared across patients
% hetero_images = hetero_images ./ max(hetero_images(:)) * 255;
patient.hetero_images = hetero_images;
% patient.hetero_score = hetero_score;
handles.patient(index) = patient;

updateStatusBox(handles, 'Finished heterogeneity calculation', 1);
set(handles.viewleft_hetero, 'Enable', 'on');
set(handles.viewright_hetero, 'Enable', 'on');
guidata(hObject, handles);


% --------------------------------------------------------------------
function file_button_Callback(hObject, eventdata, handles)
newFig = box;
%set(newFig, 'MenuBar', 'none');

% hObject    handle to file_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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
if size(handles.patient(index).body_SNR,2)~=0
	handles.patient(index).body_SNR = cat(2, 0, handles.patient(index).body_SNR);
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
if size(handles.patient(index).body_SNR,2)~=0
	handles.patient(index).body_SNR = cat(2, handles.patient(index).body_SNR, 0);
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
handles.patient(index).bodymask = handles.patient(index).bodymask(2:end);
if size(handles.patient(index).body_SNR,2)~=0
	handles.patient(index).body_SNR = handles.patient(index).body_SNR(2:end);
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
handles.patient(index).bodymask = handles.patient(index).bodymask(1:end-1);
if size(handles.patient(index).body_SNR,2)~=0
	handles.patient(index).body_SNR = handles.patient(index).body_SNR(1:end-1);
end
%
handles = updateSliceSlider(handles);
%
guidata(hObject, handles);

