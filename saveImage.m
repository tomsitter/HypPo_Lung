function  saveImage( handles, panel, format )
%SAVEIMAGE Summary of this function goes here
%   Detailed explanation goes here

slice = max(get(handles.slider_slice, 'Value'), 1);

pat_index = handles.pat_index;

if strcmp(panel, 'left')
    imgtype = handles.leftpanel;
else
    imgtype = handles.rightpanel;
end

F = figure; 

colormap(gray)

switch imgtype
    case 'L'
            numslices = size(handles.patient(pat_index).lungs, 3);
            tslice = min(slice, numslices);
            if not(isempty(handles.patient(pat_index).lungs))
                imagesc(handles.patient(pat_index).lungs(:, :, tslice));
            else
                updateStatusBox(handles, 'No lung images loaded', 0);
                imagesc(gray);
            end
    case 'LM'
        numslices = size(handles.patient(pat_index).lungmask, 3);
        tslice = min(slice, numslices);
        if not(isempty(handles.patient(pat_index).lungmask))
            lungs = handles.patient(pat_index).lungs(:, :, tslice);
            lungmask = handles.patient(pat_index).lungmask(:, :, tslice);
            imagesc(maskOverlay(lungs, lungmask));
            %imagesc(handles.patient(pat_index).lungmask(:, :, val));
        else
            updateStatusBox(handles, 'No lung mask found', 0);
            imagesc(gray);
        end
    case 'B'
        numslices = size(handles.patient(pat_index).body, 3);
        tslice = min(slice, numslices);
        if not(isempty(handles.patient(pat_index).body))
            imagesc(handles.patient(pat_index).body(:, :, tslice));
        else
            updateStatusBox(handles, 'No body images loaded', 0);
            imagesc(gray);
        end
    case 'BM'
        numslices = size(handles.patient(pat_index).bodymask, 3);
        tslice = min(slice, numslices);
        if not(isempty(handles.patient(pat_index).bodymask))
%             imagesc(handles.patient(pat_index).bodymask(:, :, val));
            body = handles.patient(pat_index).body(:, :, tslice);
            bodymask = handles.patient(pat_index).bodymask(:, :, tslice);
            imagesc(maskOverlay(body, bodymask));
        else
            updateStatusBox(handles, 'No body mask found', 0);
            imagesc(gray);
        end
    case 'C'
        body = handles.patient(pat_index).body(:, :, slice);
        bodymask = handles.patient(pat_index).bodymask(:, :, slice);
        lungmask = handles.patient(pat_index).lungmask(:, :, slice);
        viewCoregistration(body, bodymask, lungmask);
    otherwise
        msg = sprintf('Unknown image state for left panel: %s', leftpanel);
        updateStatusBox(handes,msg, 1);
end


filename = inputdlg('Enter a name for the file: ');
filename = filename{1};

saveas(F, filename, format)

close(F)

end