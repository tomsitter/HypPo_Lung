function handles = readImages(handles, type)
%% This function accepts handles, a file path, filename(s) and the
% type of image being read (currently support 'body' and 'lung')
% Patient structure is returned with updated information.

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

msg = sprintf('Reading %s images.', type);
updateStatusBox(handles, msg, 0);

%Begin reading files
ext = '';
len_ext = 0;
%if iscell(filename) 
    %Pattern match to find extension on files
    expr = '\w+\.(?<ext>\w+)';
    exts = regexp(filename, expr, 'names');
    
    if iscell(exts)
        if not(isempty(exts{1, 1}))
            ext = exts{1, 1}.ext;
            len_ext = length(ext) + 1; %+1 to include '.'
        end
    else
        if not(isempty(exts))
            ext = exts.ext;
            len_ext = length(ext)+ 1;
        end
    end
%end
%     if sum(len_ext) > 0
%         for i = 1:length(len_ext)
%             %This assumes the extension is 3 characters
%             %e.g. file.abc
%             %ext = cellfun(@(x) x(end-2:end), filename, 'UniformOutput', false);
%             %ext = ext{1};
%             %filename = cellfun(@(x) x(1:end-length(ext+1)), filename, 'UniformOutput', false);
%             f = filename{i}
%             filename{i} = f(1:end-len_ext(i))
%         end
%     end

%TODO
%Handle this for cell array of exts
if strcmp(ext, 'PAR') || strcmp(ext, 'REC')
    slices = [];
    if iscell(filename)
		% doesn't work
		%{
        for i = 1:length(filename)
            f = filename{i};
            filename{i} = f(1:end-len_ext(i));
            [tslices,parms,fov,matSize] = parrec2mat(path,filename{i});
            slices(:, :, i) = tslices;
        end
		%}
		msgbox('Can only select one PAR or REC file at a time.');
		return;
    else
        %Potential error -- must remove filepath from filename?
        [slices,parms,fov,matSize] = parrec2mat(path,filename(1:end-len_ext));
    end
else
    if iscell(filename)
        [slices,parms,fov,matSize] = dicom2mat(path,filename);
    else
        [slices,parms,fov,matSize] = dicom2mat(path,{filename});
    end
end
%end

handles.patient(pat_index).(['parms' type]) = parms;
if isfield(parms, 'PatientID')
    handles.patient(pat_index).id = parms.PatientID;
elseif isfield(parms, 'patient')
    handles.patient(pat_index).id = parms.patient;
end

msg = sprintf('Loaded %d images\n FOV: %d by %d\n matrix size: %d by %d\nPatient ID: %s', ...
               size(slices, 3), fov, matSize, handles.patient(pat_index).id);
updateStatusBox(handles, msg, 0);

if strcmp(type, 'lung')
    type = 'lungs';
elseif strcmp(type, 'body')
    type = 'body';
end

handles.patient(pat_index).(type) = slices;

if strcmp(type, 'lungs')
    handles.patient(pat_index).lungmask = zeros(size(slices));
    handles.patient(pat_index).hetero_images = zeros(size(slices));
	handles.patient(pat_index).overlayColor = [1 1 1];
	if strcmp(handles.patient(pat_index).id(1),'F')
		handles.patient(pat_index).overlayColor = [1 1 0];
	elseif strcmp(handles.patient(pat_index).id(1:2),'He')
		handles.patient(pat_index).overlayColor = [1 0 0];
	elseif strcmp(handles.patient(pat_index).id(1:2),'Xe')
		handles.patient(pat_index).overlayColor = [0 1 0];
	end
elseif strcmp(type, 'body')
    handles.patient(pat_index).body_coreg = zeros(size(slices));
    handles.patient(pat_index).bodymask = zeros(size(slices));
    handles.patient(pat_index).bodymask_coreg = zeros(size(slices));
    handles.patient(pat_index).tform = cell([size(slices, 3),1]);
end

% updateSliceSlider(handles.slider_slice, handles);
% updateViewOptions(handles);

%     axes(handles.axes1);
%     slider_val = get(handles.slider_slice, 'Value');
%     if slider_val > size(slices, 3)
%         set(handles.slider_slice, 'Value', 1);
%         imagesc(slices(:, :, 1));
%     else
%         imagesc(slices(:, :, slider_val));
%     end