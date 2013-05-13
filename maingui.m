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

% Last Modified by GUIDE v2.5 26-Apr-2013 22:28:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
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

handles.leftpanel = 'L';
handles.rightpanel = 'B';

% handles.slice_index = 1;
handles.state = 'idle';

updateImagePanels(handles);

% Choose default command line output for maingui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes maingui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


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

updateImagePanels(handles);


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

% handles.patient(pat_index).id = 'NoData';

handles.pat_index = pat_index;

updateStatusBox(handles, 'Created new patient', 1);
updateSliceSlider(hObject, handles);
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

            updateSliceSlider(hObject, handles);
            
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

%Get current patient
pat_index = handles.pat_index;
patient = handles.patient(pat_index);
id = patient.id;
 
%Cannot have dashes in matlab variables, replace with underscore and then
%assign into workspace
id = sprintf('pat_%s', id);
id = strrep(id, '-', '_');
id = strrep(id, ' ', '_');

uisave('patient', id);

assignin('base', id, patient);
msg = sprintf('Saving patient %s to workspace', id);
updateStatusBox(handles, msg, 1);

% --------------------------------------------------------------------
function file_loadpatient_Callback(hObject, ~, handles)
% hObject    handle to file_loadpatient (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pat_index = handles.pat_index;

[fname,pname] = uigetfile('*.mat', 'Select previous patient.mat file');

if isequal(fname,0) || isequal(pname,0)
   updateStatusBox(handles, 'Cancelled by user', 0)
   return;
else
   updateStatusBox(handles, ['User selected ', fullfile(pname, fname)], 1)
   %return;
end

filename=[pname fname];

new_experiment = load(filename);
new_patient = new_experiment.patient;

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

% Update handles structure
guidata(hObject, handles)

msg = sprintf('Loaded patient %s', new_patient.id);
updateStatusBox(handles, msg, 1);
updateMenuOptions(handles);
updateSliceSlider(hObject, handles);

% --------------------------------------------------------------------
function file_loadlung_Callback(hObject, ~, handles)
% hObject    handle to file_loadlung (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Read DICOM or PARREC files and store information in handles
%under the currect patient
handles = readImages(handles, 'lung');

updateSliceSlider(hObject, handles);
updateViewOptions(handles);
set(handles.analyze_seglungs, 'Enable', 'on');
% Update handles structure
guidata(hObject, handles)

% --------------------------------------------------------------------
function file_loadbody_Callback(hObject, ~, handles)
% hObject    handle to file_loadbody (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Read DICOM or PARREC files and store information in handles
%under the currect patient
handles = readImages(handles, 'body');

updateSliceSlider(hObject, handles);
updateViewOptions(handles);
set(handles.analyze_segbody, 'Enable', 'on');
% Update handles structure
guidata(hObject, handles)


% --------------------------------------------------------------------
function analyze_seglungs_Callback(hObject, ~, handles)
% hObject    handle to analyze_seglungs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateStatusBox(handles, 'Preparing to segment lungs', 1);

updateStatusBox(handles, 'Select a region of noise', 0);

handles.state = 'def_noiseregion';

%Get middle of xaxis to place region of interest
xaxis = floor(get(handles.axes1, 'XLim'));
mid_x = round(xaxis(2) / 2);
size_box = xaxis(2) / 4;

%Create an place region of interest, constrain to axis
region = imrect(handles.axes1, [(mid_x-10) 0 size_box size_box] );
fcn = makeConstrainToRectFcn('imrect', xaxis, get(handles.axes1, 'YLim'));
setPositionConstraintFcn(region,fcn)
handles.noise_region = region;

while strcmp(handles.state, 'def_noiseregion')
    %h = guidata(handles);
    try
        handles.noise_region = round(region.getPosition);
        guidata(hObject, handles);
        %disp('looping');
        pause(0.5)
    catch err
        if strcmp(err.message, 'Invalid or deleted object.')
            %This is a known event. It happens when the user finishes
            %selecting noise region. Not sure how to fix it but the algorithm
            %runs fine.
            break;
        end
    end
end

set(handles.analyze_hetero, 'Enable', 'on');

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
slice = get(handles.slider_slice, 'Value');
patient = handles.patient(index);

lungmask = patient.lungmask(:,:,slice);

% axes(handles.axes1);
% imagesc(patient.lungs(:,:,slice));

axes(handles.axes2);
% maskOverlay(reg_body, lungmask);
viewCoregistration(reg_body, reg_bodymask, lungmask);

applyall = questdlg('Do you want to apply this transform to all images?');
if strcmpi(applyall, 'Yes')
    body = patient.body;
    bodymask = patient.bodymask;
    height = size(body,1);
    width = size(body,2);
    for i = 1:size(body, 3)
%         reg_body = imtransform(body, tform, 'xdata', [1 width], 'ydata', [1, height]);
%         reg_bodymask = imtransform(bodymask, tform, 'xdata', [1 width], 'ydata', [1, height]);
        patient.body(:,:,i) = imtransform(body(:,:,i), tform, 'xdata', [1 width], 'ydata', [1, height]);
        patient.bodymask(:,:,i) = imtransform(bodymask(:,:,i), tform, 'xdata', [1 width], 'ydata', [1, height]);
    end
end
    
updateStatusBox(handles, 'Finished Coregistration', 1);

guidata(hObject, handles);


% --- Executes on button press in push_applyall.
function push_applyall_Callback(hObject, ~, handles)
% hObject    handle to push_applyall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

state = handles.state;
handles.state = 'pause';
index = handles.pat_index;
%slice = get(handles.slider_slice, 'Value');
patient = handles.patient(index);

if strcmp(state, 'def_noiseregion')
    dims = handles.noise_region;
    [x y w h] = deal(max(1, dims(1)), max(1, dims(2)), ...
                     max(1, dims(3)), max(1, dims(4)));
    images = patient.lungs;
      
    curImages = images(:,:,:);
    
    rois = curImages(y:y+h, x:x+w, :);
    
    figure(2);
    montage(reshape(rois, [size(rois, 1) size(rois, 2) 1 size(rois, 3)]))
    
    ok = questdlg('Are all the regions of interest only noise?', 'Reselect Noise Region?', 'Yes');
    
    if not(strcmp(ok, 'Yes'))
        
        updateImagePanels(handles);

        %Finished with current task
        handles.state = 'idle';

        guidata(hObject, handles);
        updateStatusBox(handles, 'Reselect noise region and try again', 0);
        close(figure(2));
        return;
    end
    
    close(figure(2));
    axes(handles.axes2);
    %calculate optimal threshold value and threshold image
    wb = waitbar(0, 'Segmentation in Progress');
    numImages = size(curImages, 3);
    for slice = 1:numImages
        roi = curImages(y:y+h, x:x+w, slice);
        [threshold, mean_noise] = calculate_noise(double(sort(roi(:))));
        handles.patient(index).threshold{slice} = threshold;
        handles.patient(index).mean_noise{slice} = mean_noise;
%         handles.patient(index).seglung(:,:,slice) = curImages(:,:,slice) > threshold;
        handles.patient(index).lungmask(:,:,slice) = thresholdmask(curImages(:,:,slice), threshold, mean_noise);
        waitbar(slice/numImages, wb);
    end
    close(wb);
    handles.leftpanel='L';
    handles.rightpanel='LM';
    updateStatusBox(handles, 'Images thresholded', 0);
    
    %set(handles.analyze_threshold, 'Enable', 'on');
end

updateImagePanels(handles);

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
index = handles.pat_index;
slice = get(handles.slider_slice, 'Value');
patient = handles.patient(index);

if strcmp(state, 'def_noiseregion')
    dims = handles.noise_region;
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
end

updateImagePanels(handles);

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
updateImagePanels(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function viewright_lungmask_Callback(hObject, eventdata, handles)
% hObject    handle to viewright_lungmask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.rightpanel = 'LM';
updateImagePanels(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function viewright_body_Callback(hObject, eventdata, handles)
% hObject    handle to viewright_body (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.rightpanel = 'B';
updateImagePanels(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function viewright_bodymask_Callback(hObject, eventdata, handles)
% hObject    handle to viewright_bodymask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.rightpanel = 'BM';
updateImagePanels(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function viewleft_lungs_Callback(hObject, eventdata, handles)
% hObject    handle to viewleft_lungs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.leftpanel = 'L';
updateImagePanels(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function viewleft_lungmask_Callback(hObject, eventdata, handles)
% hObject    handle to viewleft_lungmask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.leftpanel = 'LM';
updateImagePanels(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function viewleft_body_Callback(hObject, eventdata, handles)
% hObject    handle to viewleft_body (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.leftpanel = 'B';
updateImagePanels(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function viewleft_bodymask_Callback(hObject, eventdata, handles)
% hObject    handle to viewleft_bodymask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.leftpanel = 'BM';
updateImagePanels(handles);
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
index = handles.pat_index;
slice = get(handles.slider_slice, 'Value');
handles.leftpanel = 'LM';

if slice == 0
    %This must be a blank patient.
    updateStatusBox(handles, 'No lung images found.', 1);
    return;
end

%Get mask and image
mask = handles.patient(index).lungmask(:,:,slice);
image = handles.patient(index).lungs(:,:,slice);

axes(handles.axes1);

% %Check if mask is defined
% if sum(sum(mask)) == 0
%     updateStatusBox(handles, 'No mask found. Have you segmented this image yet?',1);
%     return;
% end

updateStatusBox(handles, 'Select the area you want to add.',1);

maskOverlay(image, mask);

roi = roipoly();

if isempty(roi)
    return;
end

mask = mask | roi;
handles.patient(index).lungmask(:,:,slice) = mask;

updateImagePanels(handles);

guidata(hObject, handles)

% --------------------------------------------------------------------
function manual_lremove_Callback(hObject, eventdata, handles)
% hObject    handle to manual_lremove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index = handles.pat_index;
slice = get(handles.slider_slice, 'Value');
handles.leftpanel = 'LM';

if slice == 0
    %This must be a blank patient.
    updateStatusBox(handles, 'No lung images found.', 1);
    return;
end

%Get mask and image
mask = handles.patient(index).lungmask(:,:,slice);
image = handles.patient(index).lungs(:,:,slice);

axes(handles.axes1);

% %Check if mask is defined
% if sum(sum(mask)) == 0
%     updateStatusBox(handles, 'No mask found. Have you segmented this image yet?',1);
%     return;
% end

updateStatusBox(handles, 'Select the area you want to remove.',1);

maskOverlay(image, mask);

roi = roipoly();

if isempty(roi)
    return;
end

mask = mask & ~roi;
handles.patient(index).lungmask(:,:,slice) = mask;

updateImagePanels(handles);

guidata(hObject, handles)

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
index = handles.pat_index;
slice = get(handles.slider_slice, 'Value');
handles.leftpanel = 'BM';

if slice == 0
    %This must be a blank patient.
    updateStatusBox(handles, 'No body images found.', 1);
    return;
end

%Get mask and image
mask = handles.patient(index).bodymask(:,:,slice);
image = handles.patient(index).body(:,:,slice);

axes(handles.axes1);

% %Check if mask is defined
% if sum(sum(mask)) == 0
%     updateStatusBox(handles, 'No mask found. Have you segmented this image yet?',1);
%     return;
% end

updateStatusBox(handles, 'Select the area you want to add.',1);

maskOverlay(image, mask);

roi = roipoly();

if isempty(roi)
    return;
end

mask = mask | roi;
handles.patient(index).bodymask(:,:,slice) = mask;

updateImagePanels(handles);

guidata(hObject, handles)

% --------------------------------------------------------------------
function manual_bremove_Callback(hObject, eventdata, handles)
% hObject    handle to manual_bremove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index = handles.pat_index;
slice = get(handles.slider_slice, 'Value');
handles.leftpanel = 'BM';

if slice == 0
    %This must be a blank patient.
    updateStatusBox(handles, 'No body images found.', 1);
    return;
end

%Get mask and image
mask = handles.patient(index).bodymask(:,:,slice);
image = handles.patient(index).body(:,:,slice);

axes(handles.axes1);

% %Check if mask is defined
% if sum(sum(mask)) == 0
%     updateStatusBox(handles, 'No mask found. Have you segmented this image yet?',1);
%     return;
% end

updateStatusBox(handles, 'Select the area you want to remove.',1);

maskOverlay(image, mask);

roi = roipoly();

if isempty(roi)
    return;
end

mask = mask & ~roi;
handles.patient(index).bodymask(:,:,slice) = mask;

updateImagePanels(handles);

guidata(hObject, handles)


% --------------------------------------------------------------------
function analyze_segbody_Callback(hObject, eventdata, handles)
% hObject    handle to analyze_segbody (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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

updateImagePanels(handles);
updateMenuOptions(handles);

guidata(hObject, handles);


% --- Executes on button press in push_cancel.
function push_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to push_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%untested
updateImagePanels(handles);


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
updateImagePanels(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function viewleft_coreg_Callback(hObject, eventdata, handles)
% hObject    handle to viewleft_coreg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.leftpanel = 'C';
updateStatusBox(handles, 'Lungs: Purple, Body: Green', 1);
updateImagePanels(handles);
guidata(hObject, handles);


% --------------------------------------------------------------------
function viewright_hetero_Callback(hObject, eventdata, handles)
% hObject    handle to viewright_hetero (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.rightpanel = 'H';
% updateStatusBox(handles, 'Lungs: Purple Body: Green', 1);
updateImagePanels(handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function viewleft_hetero_Callback(hObject, eventdata, handles)
% hObject    handle to viewleft_hetero (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.leftpanel = 'H';
% updateStatusBox(handles, 'Lungs: Purple Body: Green', 1);
updateImagePanels(handles);
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
updateImagePanels(handles);

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

maskOverlay(bodyimg, bodymask);

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

updateImagePanels(handles);

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
hetero_score = zeros(size(patient.lungs, 3));

wb = waitbar(0, 'Calculating Heterogeneity...');
for i = 1:size(lungs, 3)
    waitbar(i/size(lungs, 3), wb);
    hetero = heterogeneity2(lungs(:,:,i), lungmask(:,:,i), noise);
    
    hetero_images(:,:,i) = hetero;
    
    hetero_score(i) = sum(hetero) / sum(lungmask(:,:,i));
end
close(wb);

%Normalization needs improvement if it is to be compared across patients
hetero_images = hetero_images ./ max(hetero_images(:)) * 255;
patient.hetero_images = hetero_images;
patient.hetero_score = hetero_score;
handles.patient(index) = patient;

updateStatusBox(handles, 'Finished heterogeneity calculation', 1);
set(handles.viewleft_hetero, 'Enable', 'on');
set(handles.viewright_hetero, 'Enable', 'on');
guidata(hObject, handles);
