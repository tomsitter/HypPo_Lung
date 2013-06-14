function res = heteroimages( patients )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
res = 0;

% num_patients = length(patients);

map = [0 0 0; 1/3 0 1/2; 0 0 1; 0 1/2 1; 0 1 1; 0 1 0; ...
       2/3 1 0; 1 1 0; 1 3/4 0; 1 1/2 0; 1 0 0; 0.85 0 0];

for i = 1:size(patients(1).hetero_images, 3)

    h = figure;
    for p = 1:length(patients)
        subplot(2,2,p);
        imshow(patients(p).hetero_images(:,:,i));
        ttl = patients(p).id;
        title(ttl)
    end
    colormap(map)
    saveas(gcf, sprintf('%s, Slice %d', patients(1).id, i), 'tif'); 
end

res = 1;

end


