function montage3( images )

[x y z] = size(images);
figure;
montage(reshape(images, [x y 1 z]));

end