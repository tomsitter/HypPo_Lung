 function updateStatusBox(handles, message)
    statustext = cellstr(get(handles.statusbox, 'String'));
    msg = cat(1, message, '-------', statustext);
    
    set(handles.statusbox, 'String', msg);
 end