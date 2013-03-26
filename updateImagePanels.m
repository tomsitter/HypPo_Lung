function updateImagePanels(handles)

val = max(get(handles.slider_slice, 'Value'), 1);

colormap(gray)
pat_index = handles.pat_index;
leftpanel = handles.leftpanel;
rightpanel = handles.rightpanel;

axes(handles.axes1);
switch leftpanel
    case 'L'
            numslices = size(handles.patient(pat_index).lung, 3);
            if (val > numslices)
                val = numslices;
            end
            if not(isempty(handles.patient(pat_index).lung))
                imagesc(handles.patient(pat_index).lung(:, :, val));
            else
                updateStatusBox(handles, 'No lung images loaded', 0);
                imagesc(checkerboard(4,16,16));
            end
    case 'LM'
            numslices = size(handles.patient(pat_index).lung, 3);
            if (val > numslices)
                val = numslices;
            end
            if not(isempty(handles.patient(pat_index).lungmask))
                imagesc(handles.patient(pat_index).lungmask(:, :, val));
            else
                updateStatusBox(handles, 'No lung images loaded', 0);
                imagesc(checkerboard(4,16,16));
            end
    case 'B'
        if not(isempty(handles.patient(pat_index).body))
            imagesc(handles.patient(pat_index).body(:, :, val));
        else
            updateStatusBox(handles, 'No body images loaded', 0);
            imagesc(checkerboard(4,16,16));
        end
    case 'BM'
        numslices = size(handles.patient(pat_index).bodymask, 3);
        if (val > numslices)
            val = numslices;
        end
        if not(isempty(handles.patient(pat_index).bodymask))
            imagesc(handles.patient(pat_index).bodymask(:, :, val));
        else
            updateStatusBox(handles, 'No body images loaded', 0);
            imagesc(checkerboard(4,16,16));
        end
end

axes(handles.axes2);
switch rightpanel
    case 'L'
            numslices = size(handles.patient(pat_index).lung, 3);
            if (val > numslices)
                val = numslices;
            end
            if not(isempty(handles.patient(pat_index).lung))
                imagesc(handles.patient(pat_index).lung(:, :, val));
            else
                updateStatusBox(handles, 'No lung images loaded', 0);
                imagesc(checkerboard(4,16,16));
            end
    case 'LM'
            numslices = size(handles.patient(pat_index).lung, 3);
            if (val > numslices)
                val = numslices;
            end
            if not(isempty(handles.patient(pat_index).lungmask))
                imagesc(handles.patient(pat_index).lungmask(:, :, val));
            else
                updateStatusBox(handles, 'No lung mask', 0);
                imagesc(checkerboard(4,16,16));
            end
    case 'B'
        if not(isempty(handles.patient(pat_index).body))
            imagesc(handles.patient(pat_index).body(:, :, val));
        else
            updateStatusBox(handles, 'No body images loaded', 0);
            imagesc(checkerboard(4,16,16));
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
            imagesc(checkerboard(4,16,16));
        end
end