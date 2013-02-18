function [data,parms,fov,matSize] = dicom2mat(path,files)

if not(iscell(files))
    files = {files};
end

% Calculate number of files
num_files = length(files);

% Read DICOM files
for im = 1:num_files    
    fileName = strcat(path,files{im});
    parms = dicominfo(fileName);

    % Read image and convert to 8-bit
    I = dicomread(parms);
    I = double(I);
    I = I - min(I(:));
    I = I / max(I(:));
    I = I*255;
    I = round(I);
    I = uint8(I);
    data(:,:,im) = I;
end

%Extract FOV from last file
width = double(parms.Width); %image width (e.g. 512)
height = double(parms.Height); %image height (e.g. 512)
resolution = double(parms.PixelSpacing);
matSize = [width, height];
fov = matSize.*resolution';