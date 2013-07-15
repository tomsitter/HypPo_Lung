function varargout = LungParameters(varargin)
% LUNGPARAMETERS MATLAB code for LungParameters.fig
%      LUNGPARAMETERS, by itself, creates a new LUNGPARAMETERS or raises the existing
%      singleton*.
%
%      H = LUNGPARAMETERS returns the handle to a new LUNGPARAMETERS or the handle to
%      the existing singleton*.
%
%      LUNGPARAMETERS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LUNGPARAMETERS.M with the given input arguments.
%
%      LUNGPARAMETERS('Property','Value',...) creates a new LUNGPARAMETERS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LungParameters_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LungParameters_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LungParameters

% Last Modified by GUIDE v2.5 05-Jul-2013 16:35:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LungParameters_OpeningFcn, ...
                   'gui_OutputFcn',  @LungParameters_OutputFcn, ...
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

% --- Executes just before LungParameters is made visible.
function LungParameters_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LungParameters (see VARARGIN)


params = varargin{1};

temp = struct('fev', -1.0, 'fvc', -1.0, 'tlc', -1.0, 'ic', -1.0, ...
                  'dlco', -1.0, 'frc', -1.0, 'rv', -1.0);
              
param_fields = fields(temp);
handles.param_fields = param_fields;
handles.orig_params = params;


if isstruct(params)
    for i = 1:length(param_fields)
        field = sprintf('edit_%s', param_fields{i});
        if isfield(handles, field)
            if isfield(params, param_fields{i}) && params.(param_fields{i}) ~= -1
                set(handles.(field), 'String', params.(param_fields{i}));
            else
                set(handles.(field), 'String', '');
            end
        end
    end
    handles.params = params;
else
    handles.params = temp;
end

% Choose default command line output for LungParameters
% handles.output = handles.params;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes LungParameters wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = LungParameters_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.params;


delete(handles.figure1);


% --- Executes on button press in push_cancel.
function push_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to push_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
orig_params = handles.orig_params;

if isempty(orig_params)
    handles.params = struct('fev', -1.0, 'fvc', -1.0, 'tlc', -1.0, 'ic', -1.0, ...
                  'dlco', -1.0, 'frc', -1.0, 'rv', -1.0);
else
    handles.params = handles.orig_params;
end

guidata(hObject, handles);

if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(handles.figure1);
else
    % The GUI is no longer waiting, just close it
    delete(handles.figure1);
end


% --- Executes on button press in push_save.
function push_save_Callback(hObject, eventdata, handles)
% hObject    handle to push_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

params = handles.params;
param_fields = handles.param_fields;

for i = 1:length(param_fields)
    field = sprintf('edit_%s', param_fields{i});
    val = str2double(get(handles.(field), 'String'));
    if isempty(val) || isnan(val)
        params.(param_fields{i}) = -1;
    else
        params.(param_fields{i}) = val;
    end
end

handles.params = params;
guidata(hObject, handles);

if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(handles.figure1);
else
    % The GUI is no longer waiting, just close it
    delete(handles.figure1);
end


function edit_dlco_Callback(hObject, eventdata, handles)
% hObject    handle to edit_dlco (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_dlco as text
%        str2double(get(hObject,'String')) returns contents of edit_dlco as a double


% --- Executes during object creation, after setting all properties.
function edit_dlco_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_dlco (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_fev_Callback(hObject, eventdata, handles)
% hObject    handle to edit_fev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_fev as text
%        str2double(get(hObject,'String')) returns contents of edit_fev as a double


% --- Executes during object creation, after setting all properties.
function edit_fev_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_fev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_frc_Callback(hObject, eventdata, handles)
% hObject    handle to edit_frc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_frc as text
%        str2double(get(hObject,'String')) returns contents of edit_frc as a double


% --- Executes during object creation, after setting all properties.
function edit_frc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_frc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_fvc_Callback(hObject, eventdata, handles)
% hObject    handle to edit_fvc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_fvc as text
%        str2double(get(hObject,'String')) returns contents of edit_fvc as a double


% --- Executes during object creation, after setting all properties.
function edit_fvc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_fvc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_ic_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ic as text
%        str2double(get(hObject,'String')) returns contents of edit_ic as a double


% --- Executes during object creation, after setting all properties.
function edit_ic_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_rv_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rv as text
%        str2double(get(hObject,'String')) returns contents of edit_rv as a double


% --- Executes during object creation, after setting all properties.
function edit_rv_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_tlc_Callback(hObject, eventdata, handles)
% hObject    handle to edit_tlc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_tlc as text
%        str2double(get(hObject,'String')) returns contents of edit_tlc as a double


% --- Executes during object creation, after setting all properties.
function edit_tlc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_tlc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end