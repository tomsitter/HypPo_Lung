function SNR = calculate_SNR(ROI_masks, data)
	%{
	rect1=round(getrect());
	xmin=rect1(1);
	xmax=xmin + rect1(3);
	ymin=rect1(2);
	ymax=ymin + rect1(4);

	dataSelected=data([ymin:ymax],[xmin:xmax]);

	N=rows(dataSelected);
	M=cols(dataSelected);

	dataSelectedReshaped=reshape(dataSelected,N*M,1);

	S=mean(dataSelectedReshaped)
	STD=std(dataSelectedReshaped)

	%Get Noise
	rect2=round(getrect());
	xmin=rect2(1);
	xmax=xmin + rect2(3);
	ymin=rect2(2);
	ymax=ymin + rect2(4);

	dataSelected=data([ymin:ymax],[xmin:xmax]);

	N=rows(dataSelected);
	M=cols(dataSelected);

	dataSelectedReshaped=reshape(dataSelected,N*M,1);

	Noise=std(dataSelectedReshaped)

	SNR=S/Noise
	%}
	data = im2double(data);
	S = [];
	for a=1:size(data,3)
		sliceData = data(:,:,a);
		dataSelected = sliceData(ROI_masks(:,:,a)==1);
		S(a) = mean(dataSelected);
	end
	%
	Noise = [];
	for a=1:size(data,3)
		sliceData = data(:,:,a);
		dataSelected = sliceData(ROI_masks(:,:,a)==0);
		Noise(a) = std(dataSelected);
	end
	%
	SNR=S./Noise;
end





