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

% Last Modified by GUIDE v2.5 07-Jan-2013 13:25:29

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

handles.viewmode = 'LnB';
handles.pat_index = 1;
                     
% Choose default command line output for maingui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes maingui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = maingui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



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


% --- Executes on slider movement.
function slider_slice_Callback(hObject, eventdata, handles)
% hObject    handle to slider_slice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

%Get current patient
pat_index = handles.pat_index;

val = get(hObject, 'Value');

if not(isempty(handles.patient(pat_index).body)) && strcmp(handles.viewmode, 'LnB')
    axes(handles.axes1);
    imagesc(handles.patient(pat_index).lung(:, :, val));

    axes(handles.axes2);
    imagesc(handles.patient(pat_index).body(:, :, val));
else
    axes(handles.axes1);
    imagesc(handles.patient(pat_index).lung(:, :, val));

    axes(handles.axes2);
    imagesc(handles.patient(pat_index).lung(:, :, val));
end


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
function file_menu_Callback(hObject, eventdata, handles)
% hObject    handle to file_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function file_analyze_Callback(hObject, eventdata, handles)
% hObject    handle to file_analyze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function file_changeexp_Callback(hObject, eventdata, handles)
% hObject    handle to file_changeexp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function file_changepatient_Callback(hObject, eventdata, handles)
% hObject    handle to file_changepatient (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function file_savepatient_Callback(hObject, eventdata, handles)
% hObject    handle to file_savepatient (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Get current patient
pat_index = handles.pat_index;

patientID = sprintf('pat_%s', handles.patient(pat_index).id);

msg = sprintf('Saving patient %s to workspace', patientID);
updateStatusBox(handles, msg);

assignin('base', patientID, handles.patient(pat_index));

patient = handles.patient(pat_index);
uisave('patient', patientID);

% --------------------------------------------------------------------
function file_loadpatient_Callback(hObject, eventdata, handles)
% hObject    handle to file_loadpatient (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%try
    pat_index = handles.pat_index;

    [fname,pname] = uigetfile('*.mat', 'Select previous patient.mat file');

    if isequal(fname,0) || isequal(pname,0)
       disp('User pressed cancel')
    else
       disp(['User selected ', fullfile(pname, fname)])
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
            updateStatusBox(handles, msg);
        end
    end
    
    msg = sprintf('Loaded patient %s', new_patient.id);
    updateStatusBox(handles, msg);
    
    updateSliceSlider(hObject, handles);
    
    % Update handles structure
    guidata(hObject, handles)
    
%catch err
%    disp(err.message)
%end

% --------------------------------------------------------------------
function file_loadlung_Callback(hObject, eventdata, handles)
% hObject    handle to file_loadlung (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Read DICOM or PARREC files and store information in handles
%under the currect patient
handles = readImages(handles, 'lung');

updateSliceSlider(hObject, handles);

% Update handles structure
guidata(hObject, handles)

% --------------------------------------------------------------------
function file_loadbody_Callback(hObject, eventdata, handles)
% hObject    handle to file_loadbody (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Read DICOM or PARREC files and store information in handles
%under the currect patient
handles = readImages(handles, 'body');

updateSliceSlider(hObject, handles);

% Update handles structure
guidata(hObject, handles)
