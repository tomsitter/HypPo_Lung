function [data,fov,matSize] = dicom2mat(path,files)

% Calculate number of files
num_files = length(files);

% Read DICOM files
for im = 1:num_files    
    fileName = strcat(path,files{im});
    info = dicominfo(fileName);

    % Read image and convert to 8-bit
    I = dicomread(info);
    I = double(I);
    I = I - min(I(:));
    I = I / max(I(:));
    I = I*255;
    I = round(I);
    I = uint8(I);
    data(:,:,im) = I;
end

%Extract FOV from last file
width = double(info.Width); %image width (e.g. 512)
height = double(info.Height); %image height (e.g. 512)
resolution = double(info.PixelSpacing);
matSize = [width, height];
fov = matSize.*resolution';