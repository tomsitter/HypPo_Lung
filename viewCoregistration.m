function viewCoregistration( body, bodymask, lungmask )
%VIEWCOREGISTRATION Displays overlap of lung and proton mask on proton image
imagesc(body);
colormap gray;
hold on;
overlap = imshowpair(bodymask, lungmask);
alpha(overlap, .4);
hold off;

end