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

% Last Modified by GUIDE v2.5 22-Aug-2013 12:09:19

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
handles.firstSlice = round(max(get(handles.maingui.slider_slice, 'Value'), 1));
handles.lastSlice = handles.firstSlice;
handles.numColumns = 1;
if strcmp(handles.panel, 'left')
	handles.imageType = handles.maingui.leftpanel;
elseif strcmp(handles.panel, 'right')
	handles.imageType = handles.maingui.rightpanel;
end

slicesCellArray = cell(1);
for a=1:getNumOfSlices(handles.maingui.patient(handles.maingui.pat_index), handles.imageType)
	slicesCellArray{a} = num2str(a);
end
set(handles.menu_firstSlice, 'String', slicesCellArray);
set(handles.menu_lastSlice, 'String', slicesCellArray);
set(handles.menu_numOfColumns, 'String', slicesCellArray);
set(handles.menu_firstSlice, 'Value', handles.firstSlice);
set(handles.menu_lastSlice, 'Value', handles.lastSlice);
set(handles.menu_numOfColumns, 'Value', 1);
set(handles.menu_multipleFiles, 'enable', 'off');

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

filetypes = {'*.png';'*.jpeg';'*.tiff';'*.bmp';'*.gif';'*.jpeg2000';'*.hdf';'*.pbm';'*.pcx';'*.pgm';'*.pnm';'*.ppm';'*.rasS';'*.xwd'};

if get(handles.menu_multipleFiles, 'Value')==1
	[filename, pathname] = uiputfile(filetypes, 'Image Save Location');
	if ~isequal(filename,0) && ~isequal(pathname,0)
		%imwrite(baseImg,fullfile(pathname,filename),'png');
		imwrite(handles.imagesToExport, fullfile(pathname,filename));
	end
elseif get(handles.menu_multipleFiles, 'Value')==2
	fileName = inputdlg('File name (without extension):','File Name',1);
	if ~isempty(fileName)
		fileName = fileName{1};
		if ~strcmp(fileName,'')
			fileName = [fileName,'_'];
		end
		[extIndex,clickedOkay] = listdlg('ListString',filetypes,'SelectionMode','single');
		if clickedOkay
			fileExt = filetypes{extIndex};
			folder_name = uigetdir();
			if ~isequal(folder_name,0)
				for a=1:size(handles.imagesToExport,4)
					imwrite(handles.imagesToExport(:,:,:,a), fullfile(folder_name,[fileName,num2str(a),fileExt(2:end)]));
				end
				msgbox('The images have been saved.','Success');
			end
		end
	end
end

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

function handles = displayImage( handles )
%SAVEIMAGE Summary of this function goes here
%   Detailed explanation goes here
%
colormapInt = get(handles.menu_colormap, 'Value');
%
pat_index = handles.maingui.pat_index;
%
exportArrayBW = [];
%
for a=1:(handles.lastSlice-handles.firstSlice+1)
	onSlice = handles.firstSlice-1+a;
	switch handles.imageType
		case 'L'
			numslices = size(handles.maingui.patient(pat_index).lungs, 3);
			if onSlice>numslices || onSlice<=0
				exportArrayBW(:,:,a) = zeros(size(handles.maingui.patient(pat_index).lungs(:,:,1)));
			else
				exportArrayBW(:,:,a) = handles.maingui.patient(pat_index).lungs(:,:,onSlice);
			end
		case 'B'
			numslices = size(handles.maingui.patient(pat_index).body, 3);
			if onSlice>numslices || onSlice<=0
				exportArrayBW(:,:,a) = zeros(size(handles.maingui.patient(pat_index).body(:,:,1)));
			else
				exportArrayBW(:,:,a) = handles.maingui.patient(pat_index).body(:,:,onSlice);
			end
		otherwise
			disp 'Not Available!';
	end
end
%
exportArrayColor = [];
%
for a=1:(handles.lastSlice-handles.firstSlice+1)
	if colormapInt==1
		switch handles.imageType
			case 'L'
				colormapToApply = gray;
			case 'B'
				colormapToApply = gray;
		end
	elseif colormapInt==2
		colormapToApply = gray;
	elseif colormapInt==3
		colormapToApply = jet;
	elseif colormapInt==4
		colormapToApply = hsv;
	end
	colormapToApply = colormapToApply(1:round(end*max(max(exportArrayBW(:,:,a)))/max(exportArrayBW(:))),:);
	exportArrayColor(:,:,:,a) = applyColormapToImage(exportArrayBW(:,:,a), colormapToApply);
end
%
combinedImage = [];
%
for a=1:(handles.lastSlice-handles.firstSlice+1)
	%onSlice = handles.firstSlice-1+a;
	width = size(exportArrayColor(:,:,:,a),1);
	height = size(exportArrayColor(:,:,:,a),2);
	y = floor((a-1)/handles.numColumns);
	x = mod(a-1,handles.numColumns);
	combinedImage((height*y+1):(height*(y+1)),(width*x+1):(width*(x+1)),:,:) = exportArrayColor(:,:,:,a);
end
%
if get(handles.menu_multipleFiles, 'Value')==1
	handles.imagesToExport = combinedImage;
elseif get(handles.menu_multipleFiles, 'Value')==2
	handles.imagesToExport = exportArrayColor;
end
%{

if colormapInt==1
	switch handles.imageType
		case 'L'
			exportArray(:,:,:,a) = applyColormapToImage(currentImage, gray);
		case 'B'
			exportArray(:,:,:,a) = applyColormapToImage(currentImage, gray);
	end
elseif colormapInt==2
	exportArray(:,:,:,a) = applyColormapToImage(currentImage, gray);
elseif colormapInt==3
	exportArray(:,:,:,a) = applyColormapToImage(currentImage, jet);
elseif colormapInt==4
	exportArray(:,:,:,a) = applyColormapToImage(currentImage, hsv);
end

%}
%
imshow(combinedImage);
%
%{
panel = handles.panel;
if strcmp(panel, 'left')
    imgtype = handles.maingui.leftpanel;
else
    imgtype = handles.maingui.rightpanel;
end
%}
%
%{
switch imgtype
    case 'L'
            numslices = size(handles.maingui.patient(pat_index).lungs, 3);
            tslice = min(slice, numslices);
            if not(isempty(handles.maingui.patient(pat_index).lungs))
                imagesc(handles.maingui.patient(pat_index).lungs(:, :, tslice));
            else
%                 updateStatusBox(handles.maingui, 'No lung images loaded', 0);
                imagesc(gray);
            end
    case 'LM'
        numslices = size(handles.maingui.patient(pat_index).lungmask, 3);
        tslice = min(slice, numslices);
        if not(isempty(handles.maingui.patient(pat_index).lungmask))
            lungs = handles.maingui.patient(pat_index).lungs(:, :, tslice);
            lungmask = handles.maingui.patient(pat_index).lungmask(:, :, tslice);
            imagesc(maskOverlay(lungs, lungmask));
            %imagesc(handles.maingui.patient(pat_index).lungmask(:, :, val));
        else
%             updateStatusBox(handles.maingui, 'No lung mask found', 0);
            imagesc(gray);
        end
    case 'B'
        numslices = size(handles.maingui.patient(pat_index).body, 3);
        tslice = min(slice, numslices);
        if not(isempty(handles.maingui.patient(pat_index).body))
            imagesc(handles.maingui.patient(pat_index).body(:, :, tslice));
        else
%             updateStatusBox(handles.maingui, 'No body images loaded', 0);
            imagesc(gray);
        end
    case 'BM'
        numslices = size(handles.maingui.patient(pat_index).bodymask, 3);
        tslice = min(slice, numslices);
        if not(isempty(handles.maingui.patient(pat_index).bodymask))
%             imagesc(handles.maingui.patient(pat_index).bodymask(:, :, val));
            body = handles.maingui.patient(pat_index).body(:, :, tslice);
            bodymask = handles.maingui.patient(pat_index).bodymask(:, :, tslice);
            imagesc(maskOverlay(body, bodymask));
        else
%             updateStatusBox(handles.maingui, 'No body mask found', 0);
            imagesc(gray);
        end
    case 'C'
        body = handles.maingui.patient(pat_index).body(:, :, slice);
        bodymask = handles.maingui.patient(pat_index).bodymask(:, :, slice);
        lungmask = handles.maingui.patient(pat_index).lungmask(:, :, slice);
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
%}

end


% --- Executes on selection change in menu_multipleFiles.
function menu_multipleFiles_Callback(hObject, eventdata, handles)
% hObject    handle to menu_multipleFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns menu_multipleFiles contents as cell array
%        contents{get(hObject,'Value')} returns selected item from menu_multipleFiles
end

% --- Executes during object creation, after setting all properties.
function menu_multipleFiles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menu_multipleFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



% --- Executes on selection change in menu_firstSlice.
function menu_firstSlice_Callback(hObject, eventdata, handles)
% hObject    handle to menu_firstSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns menu_firstSlice contents as cell array
%        contents{get(hObject,'Value')} returns selected item from menu_firstSlice
handles.firstSlice = get(hObject,'Value');
handles = displayImage(handles);
if handles.lastSlice>handles.firstSlice
	set(handles.menu_multipleFiles, 'enable', 'on');
else
	set(handles.menu_multipleFiles, 'enable', 'off');
end
if handles.lastSlice<handles.firstSlice
	set(handles.push_save, 'enable', 'off');
else
	set(handles.push_save, 'enable', 'on');
end
guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function menu_firstSlice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menu_firstSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on selection change in menu_lastSlice.
function menu_lastSlice_Callback(hObject, eventdata, handles)
% hObject    handle to menu_lastSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns menu_lastSlice contents as cell array
%        contents{get(hObject,'Value')} returns selected item from menu_lastSlice
handles.lastSlice = get(hObject,'Value');
handles = displayImage(handles);
if handles.lastSlice>handles.firstSlice
	set(handles.menu_multipleFiles, 'enable', 'on');
else
	set(handles.menu_multipleFiles, 'enable', 'off');
end
if handles.lastSlice<handles.firstSlice
	set(handles.push_save, 'enable', 'off');
else
	set(handles.push_save, 'enable', 'on');
end
guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function menu_lastSlice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menu_lastSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on selection change in text7.
function menu_numOfColumns_Callback(hObject, eventdata, handles)
% hObject    handle to text7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns text7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from text7
handles.numColumns = get(hObject,'Value');
handles = displayImage(handles);
guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function menu_numOfColumns_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


