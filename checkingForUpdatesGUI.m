function varargout = checkingForUpdatesGUI(varargin)
% CHECKINGFORUPDATESGUI MATLAB code for checkingForUpdatesGUI.fig
%      CHECKINGFORUPDATESGUI, by itself, creates a new CHECKINGFORUPDATESGUI or raises the existing
%      singleton*.
%
%      H = CHECKINGFORUPDATESGUI returns the handle to a new CHECKINGFORUPDATESGUI or the handle to
%      the existing singleton*.
%
%      CHECKINGFORUPDATESGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHECKINGFORUPDATESGUI.M with the given input arguments.
%
%      CHECKINGFORUPDATESGUI('Property','Value',...) creates a new CHECKINGFORUPDATESGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before checkingForUpdatesGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to checkingForUpdatesGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help checkingForUpdatesGUI

% Last Modified by GUIDE v2.5 12-Jun-2013 15:32:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @checkingForUpdatesGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @checkingForUpdatesGUI_OutputFcn, ...
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


% --- Executes just before checkingForUpdatesGUI is made visible.
function checkingForUpdatesGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to checkingForUpdatesGUI (see VARARGIN)

% Choose default command line output for checkingForUpdatesGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes checkingForUpdatesGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = checkingForUpdatesGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
