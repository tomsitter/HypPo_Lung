function updateImagePanels(handles)

val = max(get(handles.slider_slice, 'Value'), 1);

colormap(gray)
pat_index = handles.pat_index;
leftpanel = handles.leftpanel;
rightpanel = handles.rightpanel;

%Check if there are are any patients
%If not, set checkerboard images and return
if isempty(handles.patient)
    axes(handles.axes1);
    imagesc(checkerboard(4,16));
    axes(handles.axes2);
    imagesc(checkerboard(4,16));
    return;
end

axes(handles.axes1);
switch leftpanel
    case 'L'
            numslices = size(handles.patient(pat_index).lungs, 3);
            if (val > numslices)
                val = numslices;
            end
            if not(isempty(handles.patient(pat_index).lungs))
                imagesc(handles.patient(pat_index).lungs(:, :, val));
            else
                updateStatusBox(handles, 'No lung images loaded', 0);
                imagesc(checkerboard(4,16));
            end
    case 'LM'
            numslices = size(handles.patient(pat_index).lungmask, 3);
            if (val > numslices)
                val = numslices;
            end
            if not(isempty(handles.patient(pat_index).lungmask))
                imagesc(handles.patient(pat_index).lungmask(:, :, val));
            else
                updateStatusBox(handles, 'No lung mask found', 0);
                imagesc(checkerboard(4,16));
            end
    case 'B'
        if not(isempty(handles.patient(pat_index).body))
            imagesc(handles.patient(pat_index).body(:, :, val));
        else
            updateStatusBox(handles, 'No body images loaded', 0);
            imagesc(checkerboard(4,16));
        end
    case 'BM'
        numslices = size(handles.patient(pat_index).bodymask, 3);
        if (val > numslices)
            val = numslices;
        end
        if not(isempty(handles.patient(pat_index).bodymask))
            imagesc(handles.patient(pat_index).bodymask(:, :, val));
        else
            updateStatusBox(handles, 'No body mask found', 0);
            imagesc(checkerboard(4,16));
        end
    otherwise
        msg = sprintf('Unknown image state for left panel: %s', leftpanel);
        updateStatusBox(handes,msg, 1);
end

axes(handles.axes2);
switch rightpanel
    case 'L'
            numslices = size(handles.patient(pat_index).lungs, 3);
            if (val > numslices)
                val = numslices;
            end
            if not(isempty(handles.patient(pat_index).lungs))
                imagesc(handles.patient(pat_index).lungs(:, :, val));
            else
                updateStatusBox(handles, 'No lung images loaded', 0);
                imagesc(checkerboard(4,16));
            end
    case 'LM'
            numslices = size(handles.patient(pat_index).lungmask, 3);
            if (val > numslices)
                val = numslices;
            end
            if not(isempty(handles.patient(pat_index).lungmask))
                imagesc(handles.patient(pat_index).lungmask(:, :, val));
            else
                updateStatusBox(handles, 'No lung mask', 0);
                imagesc(checkerboard(4,16));
            end
    case 'B'
        if not(isempty(handles.patient(pat_index).body))
            imagesc(handles.patient(pat_index).body(:, :, val));
        else
            updateStatusBox(handles, 'No body images loaded', 0);
            imagesc(checkerboard(4,16));
        end
    case 'BM'
        numslices = size(handles.patient(pat_index).bodymask, 3);
        if (val > numslices)
            val = numslices;
        end
        if not(isempty(handles.patient(pat_index).bodymask))
            imagesc(handles.patient(pat_index).bodymask(:, :, val));
        else
            updateStatusBox(handles, 'No body mask', 0);
            imagesc(checkerboard(4,16));
        end
    otherwise
        msg = sprintf('Unknown image state for right panel: %s', rightpanel);
        updateStatusBox(handes,msg, 1);
end