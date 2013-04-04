function viewCoregistration( body, bodymask, lungmask )

imagesc(body);
colormap gray;
hold on;
overlap = imshowpair(bodymask, lungmask);
alpha(overlap, .4);
hold off;

end