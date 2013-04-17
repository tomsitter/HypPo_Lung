 function updateStatusBox(handles, message, sep)
 
    %Sep parameter was added later, adding for backward compatibility
    if nargin == 2
        sep = 1;
    end
 
    statustext = cellstr(get(handles.statusbox, 'String'));
    if sep
        msg = cat(1, message, '-------', statustext);
    else
        msg = cat(1, message, statustext);
    end
        
    
    set(handles.statusbox, 'String', msg);
 end