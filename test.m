%{
img2 = double(pat_He_014.lungs(:,:,3))/255;
img3 = img2;
filter = fspecial('average',100);
img3 = filter2(filter,img3);
filter = fspecial('unsharp');
img3 = 5*(img3-img2);
%img3 = img3/(max(max(img3))-min(min(img3)));
%img3 = img3-min(min(img3));
%max(max(img3))
%min(min(img3))
%img3(160,90) = 1;
img3(img3<0) = 0;
img4 = regiongrowing([img3], 160, 90,0.03);
filter = fspecial('laplacian');
img4 = filter2(filter,img4);

%img3(160,100) = 1;
%img3 = img3-filter2(img2,2);
%filter = fspecial('unsharp');
%img3 = filter2(filter,img3);
%img3 = filter2(filter,img3);
imshow([img3,img4+img2,img2]);
%}
%{
imagesAverage = [];
%regions = [];
%imagesOutline = [];

starting = 8;
ending = 12;

images = double(pat_He_014.lungs(:,:,:))/255;
images2 = log(double(pat_He_014.lungs(:,:,:))*100)/log(1000);
images2 = images2/max(max(max(images2)));
%images2(images2<0.6) = 0;
filterAverage = fspecial('average',20);
filterGaussian = fspecial('gaussian',1);
filterOutline = fspecial('laplacian');
%{
for a=starting:ending
	abc = zeros(256);
	abc(1:256,1:256) = minfilt2(images(:,:,a),7);
	images2(:,:,a) = abc;
end
images2(images2<0) = 0;
for a=starting:ending
	abc = zeros(256);
	abc(1:256,1:256) = maxfilt2(images2(:,:,a),5);
	images2(:,:,a) = abc;
end
%}
%images2(images2<0) = 0;
%images2(images2<0.7) = 0;
%images2(images<0.06) = 0;
for a=starting:ending
	imagesAverage(:,:,a) = filter2(filterAverage,images2(:,:,a));
end
%imagesAverage = 5*(imagesAverage-images2(:,:,1:ending));
imagesAverage(imagesAverage<0) = 0;
for a=starting:ending
	imagesAverage2(:,:,a) = filter2(filterAverage,images(:,:,a));
end
imagesAverage2 = 100*(imagesAverage2-imagesAverage(:,:,1:ending));
imagesAverage2(imagesAverage2<0) = 0;
%
%{
for a=starting:ending
	regions(:,:,a) = regiongrowing(imagesAverage(:,:,a), 160, 90,0.04);%0.03
	regions(:,:,a) = 1-regiongrowing(regions(:,:,a), 1, 1, 0.5);
	disp(a);
end
%}
for a=starting:ending
	imagesOutline(:,:,a) = filter2(filterOutline,images2(:,:,a));%regions
end
%
combinedImage = [];
for a=starting:ending
	combinedImage(1:256,(256*(a-starting)+1):(256*(a-starting+1))) = imagesAverage(:,:,a);%imagesOutline(:,:,a)+
end
imshow(combinedImage);
figure;
combinedImage = [];
for a=starting:ending
	combinedImage(1:256,(256*(a-starting)+1):(256*(a-starting+1))) = images2(:,:,a);%imagesOutline(:,:,a)+
end
imshow(combinedImage);
%
figure;
combinedImage = [];
for a=starting:ending
	combinedImage(1:256,(256*(a-starting)+1):(256*(a-starting+1))) = images(:,:,a);%imagesOutline(:,:,a)+
end
imshow(combinedImage);
%
%imagesOutline = reshape(imagesOutline(:,:,3:11),[size(imagesOutline,1)*3,size(imagesOutline,2)*3,1]);
%imshow(imagesOutline);
%imshow(imagesOutline(:,:,5));
%}





imagesAverage = [];
regions = [];
imagesOutline = [];
regionGrow = true;

starting = 8;
ending = 12;

images = double(pat_He_014.lungs(:,:,:))/255;
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

