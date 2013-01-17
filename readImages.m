function handles = readImages(handles, type)
%% This function accepts handles, a file path, filename(s) and the
% type of image being read (currently support 'body' and 'lung')
% Patient structure is return with update information.

%Get current patient
pat_index = handles.pat_index;

% Locate appropriate files
file_msg = sprintf('Select %s Images', [upper(type(1)) type(2:end)]);
[filename,path]= uigetfile('*.*',file_msg,'MultiSelect','on',handles.curdir);

% If file selection is cancelled, pathname should be zero
if path == 0
    return
end

% Save list of file names
handles.([type '_ims']) = filename;
%handles.lung_ims = filename;

% Save path of selected file

handles.([type '_dir']) = path;
handles.curdir = path;
%set(handles.lung_dir,'String',path);

% Read lung images
msg = sprintf('Reading %s images.', type);
updateStatusBox(handles, msg);

if iscell(filename)
    %This assumes the extension is 3 characters
    %e.g. file.abc
    ext = cellfun(@(x) x(end-2:end), filename, 'UniformOutput', false);
    ext = ext{1};
    filename = cellfun(@(x) x(1:end-4), filename, 'UniformOutput', false);
else
    ext = filename(end-2:end);
    filename = filename(1:end-4);
end

if strcmp(ext, 'PAR') || strcmp(ext, 'REC')
    slices = [];
    if iscell(filename)
    	for i = 1:length(filename)
            [tslices,parms,fov,matSize] = parrec2mat(path,filename{i});
            slices(:, :, i) = tslices;
        end
    else
        [slices,parms,fov,matSize] = parrec2mat(path,filename);
    end
else
    [slices,parms,fov,matSize] = dicom2mat(path,filename);
end

handles.patient(pat_index).(['parms' type]) = parms;
if isfield(parms, 'PatientID')
    handles.patient(pat_index).id = parms.PatientID;
elseif isfield(parms, 'patient')
    handles.patient(pat_index).id = parms.patient;
end

msg = sprintf('Loaded %d images\n FOV: %d by %d\n matrix size: %d by %d\nPatient ID: %s', ...
               size(slices, 3), fov, matSize, handles.patient(pat_index).id);
updateStatusBox(handles, msg);

handles.patient(pat_index).(type) = slices;

axes(handles.axes1);
imagesc(slices(:, :, pat_index));