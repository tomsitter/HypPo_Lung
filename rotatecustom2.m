function matrix = rotatecustom2(matrix)
sizex=size(matrix, 1);
sizey=size(matrix,2);
sizez=size(matrix, 3);

temp3d=[];

for i=1:sizex
    temp2d =[];
    for j=1:sizez
        temp2d=cat(2, temp2d, matrix(i,:,j)');
    end
   temp3d=cat(3, temp3d, temp2d);
end

matrix=temp3d;

end

