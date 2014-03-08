function [data,parms] = dicom2mat(path,files)
%returns parms of last file

if not(iscell(files))
    files = {files};
end

% Calculate number of files
num_files = length(files);

max_slices_per_file = 1;

% Read DICOM files
for im = 1:num_files
    fileName = strcat(path,files{im});
    parms = dicominfo(fileName);
	% the returned value of parms will always be the parameters of the very last file
    % Read image and convert to 8-bit
    I = dicomread(parms);
	if size(I,4)>max_slices_per_file
		max_slices_per_file = size(I,4);
	end
	% if there is more than one slice in the file, it must be the first file
	% if there is only one slice in the file, there cannot be files before it
	% with more than one slice
	if size(I,4)~=1
		% more than one slice in this file
		if im~=1
			% not the first file
			msgbox('See error message (once you close this message).');
			error('DICOM_READ_ERROR: One file contains multiple slices while another contains only one slice. Unsure if these are all for the same patient or for different patients.');
		end
	else
		% only one slice in this file
		if max_slices_per_file>1
			% if there was a previous file with more than one slice
			msgbox('See error message (once you close this message).');
			error('DICOM_READ_ERROR: One file contains multiple slices while another contains only one slice. Unsure if these are all for the same patient or for different patients.');
		end
	end
%     I = double(I);
%     I = I - min(I(:));
%     I = I / max(I(:));
%     I = I*255;
%     I = round(I);
%     I = uint8(I);
	if size(I,4)~=1
		% more than one slice in this file
		for a=1:size(I,4)
			data(:,:,a) = uint8(mat2gray(I(:,:,:,a))*255);
		end
	else
		% only one slice in this file
		data(:,:,im) = uint8(mat2gray(I)*255);
	end
end