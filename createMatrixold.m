function createMatrix(handles)




pat_index = handles.pat_index;
leftpanel = handles.leftpanel;
rightpanel = handles.rightpanel;
            numslices = size(handles.patient(pat_index).lungs, 3);
%Check if there are are any patients
%If not, set checkerboard images and return


%plot([1:9], [1:9]);
     
            if not(isempty(handles.patient(pat_index).lungs))
              %imagesc(handles.patient(pat_index).lungs(:, :, 2));
                    temp= cat(3,(handles.patient(pat_index).lungs(:, :, 1:numslices)));
                    % temp2=  handles.patient(pat_index).lungs(:, :, 6);
           dlmwrite('a.txt',temp(200,200,1:numslices));
           %  dlmwrite('b.txt',temp2(200,200));
            else
                updateStatusBox(handles, 'error', 0);
                imagesc(gray);
            end
end