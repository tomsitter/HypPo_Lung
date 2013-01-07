function varargout = maingui(varargin)
% MAIN MATLAB code for maingui.fig
%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN.M with the given input arguments.
%
%      MAIN('Property','Value',...) creates a new MAIN or raises the
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

% Last Modified by GUIDE v2.5 06-Jan-2013 18:57:52

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
function maingui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to maingui (see VARARGIN)

%Save current directory
handles.curdir = cd;

%define a new empty patient
handles.patient = struct('id', {}, 'lung', {}, 'body', {}, ...
                         'seglung', {}, 'segbody', {}, ...
                         'coreg', {}, 'parmslung', {}, 'parmsbody', {}, ...
                         'analysis', {});
                     
% Choose default command line output for maingui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes maingui wait for user response (see UIRESUME)
% uiwait(handles.figure_main);


% --- Outputs from this function are returned to the command line.
function varargout = maingui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function file_menu_Callback(hObject, eventdata, handles)
% hObject    handle to file_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function file_newpatient_Callback(hObject, eventdata, handles)
% hObject    handle to file_newpatient (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function file_changepatient_Callback(hObject, eventdata, handles)
% hObject    handle to file_changepatient (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function statusbox_Callback(hObject, eventdata, handles)
% hObject    handle to statusbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of statusbox as text
%        str2double(get(hObject,'String')) returns contents of statusbox as a double


% --- Executes during object creation, after setting all properties.
function statusbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to statusbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function file_analyze_Callback(hObject, eventdata, handles)
% hObject    handle to file_analyze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function slider_slice_Callback(hObject, eventdata, handles)
% hObject    handle to slider_slice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = get(hObject, 'Value');

axes(handles.axes1);
imagesc(handles.patient(1).lung(:, :, val));

axes(handles.axes2);
imagesc(handles.patient(1).lung(:, :, val));

% --- Executes during object creation, after setting all properties.
function slider_slice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_slice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --------------------------------------------------------------------
function file_changeexp_Callback(hObject, eventdata, handles)
% hObject    handle to file_changeexp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function load_lung_Callback(hObject, eventdata, handles)
% hObject    handle to load_lung (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Locate appropriate files
[filename,path]= uigetfile('*.*','Select Lung Images','MultiSelect','on',handles.curdir);

% If file selection is cancelled, pathname should be zero
if path == 0
    return
end

% Save list of file names
handles.lung_ims = filename;

% Save path of selected file
handles.lung_dir = path;
handles.curdir = path;
%set(handles.lung_dir,'String',path);

% Read lung images
updateStatusBox(handles, 'Reading lung images.');

[lungSlices,parms,fov,matSize] = dicom2mat(path,filename);

handles.patient(1).parms = parms;
handles.patient(1).id = parms.PatientID;

msg = sprintf('Loaded %d images\n FOV: %d by %d\n matrix size: %d by %d\nPatient ID: %s', ...
               size(lungSlices, 3), fov, matSize, parms.PatientID);
updateStatusBox(handles, msg);

handles.patient(1).lung = lungSlices;

axes(handles.axes1);
imagesc(lungSlices(:, :, 1));

set(handles.slider_slice, 'val', 1);
set(handles.slider_slice, 'min', 1);
set(handles.slider_slice, 'max', size(lungSlices, 3))
set(handles.slider_slice, 'sliderstep', [1/(size(lungSlices, 3)-1), ...
                                         1/(size(lungSlices, 3)-1)] );
set(handles.slider_slice, 'Visible', 'on');

% Update handles structure
guidata(hObject, handles)


% --------------------------------------------------------------------
function file_savepatient_Callback(hObject, eventdata, handles)
% hObject    handle to file_savepatient (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

patientID = sprintf('pat_%s', handles.patient(1).id);

msg = sprintf('Saving patient %s to workspace', patientID);
updateStatusBox(handles, msg);

assignin('base', patientID, handles.patient(1));

patient = handles.patient(1);
uisave('patient', patientID);


% --------------------------------------------------------------------
function file_loadpatient_Callback(hObject, eventdata, handles)
% hObject    handle to file_loadpatient (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%try
    [fname,pname] = uigetfile('*.mat', 'Select previous patient.mat file');

    if isequal(fname,0) || isequal(pname,0)
       disp('User pressed cancel')
    else
       disp(['User selected ', fullfile(pname, fname)])
    end

    filename=[pname fname];
    
    new_experiment = load(filename);
    new_patient = new_experiment.patient;
    prev_patient = handles.patient(1);
    
    fn = fieldnames(new_patient);
    for i = 1:numel(fn)
        if isfield(prev_patient, fn{i})
            handles.patient(1).(fn{i}) = new_patient.(fn{i});
        else
            msg = sprintf('Found unknown field "%s", are you sure this is a patient file?', fn{i});
            updateStatusBox(handles, msg);
        end
    end
    
    handles.experiment(1) = prev_patient;
    
    % Update handles structure
    guidata(hObject, handles)
    
%catch err
%    disp(err.message)
%end
