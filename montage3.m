function m = montage3( images )

[x y z] = size(images);

% figure;
m = montage(reshape(images, [x y 1 z]));

end