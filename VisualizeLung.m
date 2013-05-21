function VisualizeLung(handles)
aspect=get(handles.slider2, 'value');
detail=get(handles.slider3, 'value');

scale=1/detail;

pat_index = handles.pat_index;
leftpanel = handles.leftpanel;
rightpanel = handles.rightpanel;

numslices = size(handles.patient(pat_index).lungs, 3);
ysize1=size(imresize(handles.patient(pat_index).lungs(:, :, 1),scale),1)
xsize1=size(imresize(handles.patient(pat_index).lungs(:, :, 1),scale),2)
matrix=zeros(ysize1,xsize1);
   multi=round(aspect*(ysize1/numslices));
        if not(isempty(handles.patient(pat_index).lungs))
       for i =1:numslices
           for j=1:multi
        
      %ysize=size(handles.patient(pat_index).lungs(:, :, i),1);
      %xsize=size(handles.patient(pat_index).lungs(:, :, i),2);
      %totalsize=xsize*ysize/4;
       matrixtemp=imresize(handles.patient(pat_index).lungs(:, :, i),scale);
%matrixtemp =  reshape(handles.patient(pat_index).lungs(:, :, i),4,totalsize);
%matrixtemp=sum(matrixtemp,1)/4;
%matrixtemp=reshape(matrixtemp,ysize/4,xsize)';
%matrixtemp=reshape(matrixtemp,4, totalsize/4);
%matrixtemp=sum(matrixtemp,1)/4;
%matrixtemp=reshape(matrixtemp,ysize/4,xsize/4)';

      matrix= cat(3,matrix,matrixtemp);
           end
       end
            matrix=double(matrix);        
      dlmwrite('z.txt', size(matrix));

               else
                updateStatusBox(handles, 'error', 0);
                imagesc(gray);
        end
if (get(handles.checkbox1, 'value') == get(handles.checkbox1,'Max')) 
  matrix=rotatecustom(matrix);
  
elseif (get(handles.checkbox2, 'value') == get(handles.checkbox2,'Max')) 
     matrix=rotatecustom2(matrix);
end
%xname='X axis';
%yname='y axis';
%zname='z axis';
sliceomatic(matrix);
%xsca=1:size(matrix,1);
%ysca=1:size(matrix, 2);
%zsca=1:size(matrix,3);

%save('new.mat', 'matrix', 'xname', 'yname', 'zname', 'xsca', 'ysca', 'zsca');
end
