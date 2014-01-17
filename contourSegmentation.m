function [binary_mask, thresh] = thresholdmask(image)
	image = double(image);
	image = image/max(image(:));

	holeSize = 30;

	thresholds = [];
	metrics = [];
	bestSeg = [];
	for a=0.08:0.01:0.4
		%{
		thresholds = [thresholds,a];
		bwImage = image;

		bwImage = medfilt2(bwImage, [3 3]);
		bwImage = medfilt2(bwImage, [3 3]);
		bwImage = medfilt2(bwImage, [3 3]);
		bwImage = medfilt2(bwImage, [3 3]);
		bwImage = medfilt2(bwImage, [3 3]);
		bwImage = medfilt2(bwImage, [3 3]);

		%figure;
		%imshow(bwImage);

		bwImage = bwImage>a;
		bwImage = imfill(bwImage,'holes');
		bwImage = bwareaopen(bwImage, holeSize);
		%{
		bwImageSmoothed = imdilate(imerode(bwImage, ones(4)),ones(4));
		bwImageSmoothed = imdilate(imerode(bwImageSmoothed, ones(4)),ones(4));
		bwImageSmoothed = imdilate(imerode(bwImageSmoothed, ones(4)),ones(4));
		bwImageSmoothed = imdilate(imerode(bwImageSmoothed, ones(4)),ones(4));
		bwImageSmoothed = imdilate(imerode(bwImageSmoothed, ones(4)),ones(4));
		bwImageSmoothed = imdilate(imerode(bwImageSmoothed, ones(4)),ones(4));
		%}
		h = fspecial('average', 8);
		bwImageSmoothed = filter2(h, bwImage);
		bwImageSmoothed(bwImageSmoothed>0.5) = 1;
		bwImageSmoothed(bwImageSmoothed<=0.5) = 0;

		perimImage = bwperim(bwImage);
		perimImageSmoothed = bwperim(bwImageSmoothed);
		%figure;
		%imshow(0.5*perimImage+0.5*perimImageSmoothed);
		%imshow(maskOverlay(image,bwImageSmoothed));

		%overlappingImage = perimImage&perimImageSmoothed;
		overlappingImage = bwImage&bwImageSmoothed;

		%figure;
		%imshow(overlappingImage);
		%metrics = [metrics, 2*sum(overlappingImage(:))/(sum(perimImage(:))+sum(perimImageSmoothed(:)))];
		thisMetric = 2*sum(overlappingImage(:))/(sum(bwImage(:))+sum(bwImageSmoothed(:)));
		if size(metrics,1)==0 || thisMetric > max(metrics)
			bestSeg = bwImage;
		end
		metrics = [metrics, thisMetric];
		metrics
		%}
		%
		thresholds = [thresholds,a];
		%
		bwImage = image;
		bwImage = bwImage>a;
		bwImage = imfill(bwImage,'holes');
		bwImage = bwareaopen(bwImage, 70);
		%
		%{
		bwImageSmoothed = bwImage;
		bwImageSmoothed = imdilate(imerode(bwImageSmoothed, ones(4)),ones(4));
		bwImageSmoothed = imdilate(imerode(bwImageSmoothed, ones(4)),ones(4));
		%}
		h = fspecial('average', 8);
		bwImageSmoothed = filter2(h, bwImage);
		bwImageSmoothed(bwImageSmoothed>0.5) = 1;
		bwImageSmoothed(bwImageSmoothed<=0.5) = 0;
		%
		perimImage = bwperim(bwImage);
		perimImageSmoothed = bwperim(bwImageSmoothed);
		%figure;
		%imshow(0.5*perimImage+0.5*perimImageSmoothed);
		%imshow(maskOverlay(image,bwImageSmoothed));
		%
		%overlappingImage = perimImage&perimImageSmoothed;
		overlappingImage = bwImage&bwImageSmoothed;
		%
		%thisMetric = 2*sum(overlappingImage(:))/(sum(perimImage(:))+sum(perimImageSmoothed(:)));
		thisMetric = 2*sum(overlappingImage(:))/(sum(bwImage(:))+sum(bwImageSmoothed(:)));
		metrics = [metrics, thisMetric];
		%
		%{
		thresholds = [thresholds,a];
		bwImage = image>a;
		bwImage = imfill(bwImage,'holes');
		perimImage = bwperim(bwImage);
		%imshow(perimImage);
		area = sum(bwImage(:));
		perim = sum(perimImage(:));
		metrics = [metrics, perim*perim/area];
		%}
	end

	thresh = thresholds(metrics==max(metrics));
	thresh = thresh(1);

	%figure;
	%imshow(image);
	newImage = image;
	newImage(newImage>thresh) = 1;
	newImage(newImage<=thresh) = 0;
	newImage = imfill(newImage,'holes');
	newImage = bwareaopen(newImage, holeSize);
	%figure;
	%imshow(maskOverlay(image,newImage));
	binary_mask = newImage;
end