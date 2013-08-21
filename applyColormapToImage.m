function imageWithColormap = applyColormapToImage(image, map)
	imageWithColormap = zeros([size(image,1),size(image,2),3]);
	interval = 256/size(map,1);
	%{
	for a=1:size(map,1)
		imageWithColormap(logical([image>=(interval*(a-1))&image<=(interval*(a)),zeros(size(image)),zeros(size(image))])) = map(a,1);
		imageWithColormap(logical([zeros(size(image)),image>=(interval*(a-1))&image<=(interval*(a)),zeros(size(image))])) = map(a,2);
		imageWithColormap(logical([zeros(size(image)),zeros(size(image)),image>=(interval*(a-1))&image<=(interval*(a))])) = map(a,3);
	end
	%}
	image(isnan(image)) = 0;
	if sum(image(:))==0
		imageWithColormap(:,:,1) = map(1,1);
		imageWithColormap(:,:,2) = map(1,2);
		imageWithColormap(:,:,3) = map(1,3);
		return;
	end
	rangeMax = max(image(:));%256
	locations = ceil(double(image(:))./(double(rangeMax)/double(size(map,1))));
	%locations = (image(:)-mod(image(:),(double(rangeMax)/double(size(map,1))))) / (double(rangeMax)/double(size(map,1)));
	locations(locations==0) = 1;
	%
	imageWithColormap(logical([ones(size(image)),zeros(size(image)),zeros(size(image))])) = map(locations,1);
	imageWithColormap(logical([zeros(size(image)),ones(size(image)),zeros(size(image))])) = map(locations,2);
	imageWithColormap(logical([zeros(size(image)),zeros(size(image)),ones(size(image))])) = map(locations,3);
end