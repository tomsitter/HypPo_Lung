function stevefunction(handles)


imagesAverage = [];
regions = [];
imagesOutline = [];
regionGrow = true;

starting = 8;
ending = 12;

images = double(handles.patient.lungs(:,:,:))/255;
filterAverage = fspecial('average',100);
filterGaussian = fspecial('gaussian',1);
filterOutline = fspecial('laplacian');
%
for a=starting:ending
	imagesAverage(:,:,a) = filter2(filterAverage,images(:,:,a));
end
%
imagesAverage = 5*(imagesAverage-images(:,:,1:ending));
%imagesAverage = (0.7-images(:,:,1:ending))/2;
imagesAverage(imagesAverage<0) = 0;
%median(median(median(imagesAverage)))
%imagesAverage(imagesAverage>average(average(average(imagesAverage)))) = 1;
%imagesAverage(imagesAverage<average(average(average(imagesAverage)))) = 0;
%{
for a=starting:ending
	imagesAverage(:,:,a) = medfilt2(imagesAverage(:,:,a),[10,10]);
end
%}
%
if regionGrow
	for a=starting:ending
		regions(:,:,a) = regiongrowing(imagesAverage(:,:,a), 160, 90, 0.03);%0.03
		regions(:,:,a) = 1-bwareaopen(1-regions(:,:,a),500);
		%se = strel('disk', 6);
		%regions(:,:,a) = imclose(regions(:,:,a),se);
		%regions(:,:,a) = 1-regiongrowing(regions(:,:,a), 1, 1, 0.5);
		disp(a);
	end
	%
	for a=starting:ending
		imagesOutline(:,:,a) = filter2(filterOutline,regions(:,:,a));%regions
	end
end
%
combinedImage = [];
for a=starting:ending
	combinedImage(1:256,(256*(a-starting)+1):(256*(a-starting+1))) = imagesAverage(:,:,a);%imagesOutline(:,:,a)+
end
imshow(combinedImage);
if regionGrow
	figure;
	combinedImage = [];
	for a=starting:ending
		combinedImage(1:256,(256*(a-starting)+1):(256*(a-starting+1))) = imagesOutline(:,:,a)+images(:,:,a);%
	end
	imshow(combinedImage);
	%
	figure;
	combinedImage = [];
	for a=starting:ending
		combinedImage(1:256,(256*(a-starting)+1):(256*(a-starting+1))) = regions(:,:,a);%imagesOutline(:,:,a)+
	end
	imshow(combinedImage);
end
%
%imagesOutline = reshape(imagesOutline(:,:,3:11),[size(imagesOutline,1)*3,size(imagesOutline,2)*3,1]);
%imshow(imagesOutline);
%imshow(imagesOutline(:,:,5));




end

