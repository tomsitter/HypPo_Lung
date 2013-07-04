function varargout = exportImage(varargin)
% EXPORTIMAGE MATLAB code for exportImage.fig
%      EXPORTIMAGE, by itself, creates a new EXPORTIMAGE or raises the existing
%      singleton*.
%
%      H = EXPORTIMAGE returns the handle to a new EXPORTIMAGE or the handle to
%      the existing singleton*.
%
%      EXPORTIMAGE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXPORTIMAGE.M with the given input arguments.
%
%      EXPORTIMAGE('Property','Value',...) creates a new EXPORTIMAGE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before exportImage_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to exportImage_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help exportImage

% Last Modified by GUIDE v2.5 17-Apr-2013 13:33:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @exportImage_OpeningFcn, ...
                   'gui_OutputFcn',  @exportImage_OutputFcn, ...
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
end

% --- Executes just before exportImage is made visible.
function exportImage_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to exportImage (see VARARGIN)


handles.maingui = varargin{1};
handles.panel = varargin{2};

% Choose default command line output for exportImage
handles.output = hObject;


handles = displayImage(handles);

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using exportImage.
% if strcmp(get(hObject,'Visible'),'off')
%     plot(rand(5));
% end

% UIWAIT makes exportImage wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end


% --- Outputs from this function are returned to the command line.
function varargout = exportImage_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

end

% --- Executes on button press in push_save.
function push_save_Callback(hObject, eventdata, handles)
% hObject    handle to push_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% popup_sel_index = get(handles.menu_format, 'Value');
% switch popup_sel_index
%     case 1
%         plot(rand(5));
%     case 2
%         plot(sin(1:0.01:25.99));
%     case 3
%         bar(1:.5:10);
%     case 4
%         plot(membrane);
%     case 5
%         surf(peaks);
% end

formatchoice = get(handles.menu_format, 'Value');
switch formatchoice
    case 1
        format = 'tif';
    case 2
        format = 'bmp';
    case 3
        format = 'jpg';
    case 4
        format = 'fig';
    case 5
        format = 'pdf';
    case 6
        format = 'm';
    case 7
        format = 'png';
end

filename = get(handles.edit_filename, 'String');
% filename = filename{1};

filename = strcat(filename, '.', format);

F = getframe(handles.axes_preview);
imshow(F.cdata);
imwrite(F.cdata, filename, format);
%saveas(handles.axes_preview, filename, format);


end

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)
end

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)

end

% --- Executes on selection change in menu_format.
function menu_format_Callback(hObject, eventdata, handles)
% hObject    handle to menu_format (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns menu_format contents as cell array
%        contents{get(hObject,'Value')} returns selected item from menu_format
end

% --- Executes during object creation, after setting all properties.
function menu_format_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menu_format (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end

% set(hObject, 'String', {'plot(rand(5))', 'plot(sin(1:0.01:25))', 'bar(1:.5:10)', 'plot(membrane)', 'surf(peaks)'});

end

function edit_filename_Callback(hObject, eventdata, handles)
% hObject    handle to edit_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_filename as text
%        str2double(get(hObject,'String')) returns contents of edit_filename as a double
end

% --- Executes during object creation, after setting all properties.
function edit_filename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

% --- Executes on selection change in menu_colormap.
function menu_colormap_Callback(hObject, eventdata, handles)
% hObject    handle to menu_colormap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns menu_colormap contents as cell array
%        contents{get(hObject,'Value')} returns selected item from menu_colormap

handles = displayImage(handles);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function menu_colormap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menu_colormap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

end

function  handles = displayImage( handles )
%SAVEIMAGE Summary of this function goes here
%   Detailed explanation goes here

maingui = handles.maingui;

colorchoice = get(handles.menu_colormap, 'Value');

switch colorchoice
    case 1
        color = 'gray';
    case 2
        color = 'jet';
    case 3
        color = 'hsv';
    otherwise
        color = 'gray';
end
colormap(color);

slice = max(get(maingui.slider_slice, 'Value'), 1);

pat_index = maingui.pat_index;

panel = handles.panel;
if strcmp(panel, 'left')
    imgtype = maingui.leftpanel;
else
    imgtype = maingui.rightpanel;
end

switch imgtype
    case 'L'
            numslices = size(maingui.patient(pat_index).lungs, 3);
            tslice = min(slice, numslices);
            if not(isempty(maingui.patient(pat_index).lungs))
                imagesc(maingui.patient(pat_index).lungs(:, :, tslice));
            else
%                 updateStatusBox(maingui, 'No lung images loaded', 0);
                imagesc(gray);
            end
    case 'LM'
        numslices = size(maingui.patient(pat_index).lungmask, 3);
        tslice = min(slice, numslices);
        if not(isempty(maingui.patient(pat_index).lungmask))
            lungs = maingui.patient(pat_index).lungs(:, :, tslice);
            lungmask = maingui.patient(pat_index).lungmask(:, :, tslice);
            imagesc(maskOverlay(lungs, lungmask));
            %imagesc(maingui.patient(pat_index).lungmask(:, :, val));
        else
%             updateStatusBox(maingui, 'No lung mask found', 0);
            imagesc(gray);
        end
    case 'B'
        numslices = size(maingui.patient(pat_index).body, 3);
        tslice = min(slice, numslices);
        if not(isempty(maingui.patient(pat_index).body))
            imagesc(maingui.patient(pat_index).body(:, :, tslice));
        else
%             updateStatusBox(maingui, 'No body images loaded', 0);
            imagesc(gray);
        end
    case 'BM'
        numslices = size(maingui.patient(pat_index).bodymask, 3);
        tslice = min(slice, numslices);
        if not(isempty(maingui.patient(pat_index).bodymask))
%             imagesc(maingui.patient(pat_index).bodymask(:, :, val));
            body = maingui.patient(pat_index).body(:, :, tslice);
            bodymask = maingui.patient(pat_index).bodymask(:, :, tslice);
            imagesc(maskOverlay(body, bodymask));
        else
%             updateStatusBox(maingui, 'No body mask found', 0);
            imagesc(gray);
        end
    case 'C'
        body = maingui.patient(pat_index).body(:, :, slice);
        bodymask = maingui.patient(pat_index).bodymask(:, :, slice);
        lungmask = maingui.patient(pat_index).lungmask(:, :, slice);
        rgbImage = repmat(body,[1 1 3]);
        imshowpair(bodymask, lungmask);
        overlap = getimage(gca);
        bothimages = rgbImage + (overlap / 1.5);
        
        imagesc(bothimages);
        
%         viewCoregistration(body, bodymask, lungmask);
    otherwise
%         msg = sprintf('Unknown image state for left panel: %s', leftpanel);
%         updateStatusBox(handes,msg, 1);
end


end
