function keyDown = waitforbuttonpresswithescape(escapePointer)
	% this function tries to replicate the function "waitforbuttonpress",
	% while adding the ability to stop waiting by modifying the pointer
	% value
	pressedPtr = libpointer('uint32');
	pressedPtr.Value = 0;
	set(gcf,'WindowButtonDownFcn',{@buttonDownCallback, pressedPtr});
	set(gcf,'KeyPressFcn',{@keyPressedCallback, pressedPtr});
	initFigure = gcf;
	while ~pressedPtr.Value&&~escapePointer.Value
		if ~ishandle(initFigure)
			error('MATLAB:uiw:ws_WaitForKeyOrButtonpress:CannotWaitForKeyPress2', 'waitforbuttonpresswithescape exit because initial figure has been deleted');
		end
		pause(0.01);
	end
	keyDown = pressedPtr.Value-1;
end

function buttonDownCallback(~, ~, pressedPtr)
	pressedPtr.Value = 1;
end
function keyPressedCallback(~, ~, pressedPtr)
	pressedPtr.Value = 2;
end