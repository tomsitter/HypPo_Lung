function  area = BWregionGrowing(img,cx,cy)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is a seeded region growing algoritm on logical images 
% (pixel intensities equal to 0 or 1).
% 
% inputs: 
%         img: a logical matrix (0/1)
%         cx: X-position of seed
%         cy: Y-position of seed
% 
% output:
%         area: a logical matrix (0 and 1) for the grown region
% 
% Author: M.Reza Heydarian
% lab: Applied Computersystem Group, McMaster University, Hamilton, On
% http://www.acsg.mcmaster.ca/group/
% Date: Feb 2006 (last modified: Nov. 4, 2010)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%-------+++++++===== Initialization and constants ========++++++++++-------
[nrow,ncol] = size(img);

%-------+++++++++++========== Region Growing part ========++++++++++-------
Current_Region = false(nrow,ncol);
Current_Region(cx,cy) = 1;
avg = 1; 

while (1)
    currentBoundary = imdilate(Current_Region,ones(3,3));
    currentBoundary(Current_Region) = 0;
    %  Check new pixels to add to the selected region
    indx_vec = find(currentBoundary);
    dist = abs(img(indx_vec) - avg);
    indx_vec = indx_vec(dist == 0);
    if (isempty(indx_vec))
        break;
    else
        Current_Region(indx_vec) = 1; 
    end
end %while(1)
area = imfill(Current_Region, 'holes');

