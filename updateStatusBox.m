 function updateStatusBox(handles, message, sep)
    statustext = cellstr(get(handles.statusbox, 'String'));
    if sep
        msg = cat(1, message, '-------', statustext);
    else
        msg = cat(1, message, statustext);
    end
        
    
    set(handles.statusbox, 'String', msg);
 end