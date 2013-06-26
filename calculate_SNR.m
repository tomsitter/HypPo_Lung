function SNR = calculate_SNR(signal_masks, noise_masks, data)
	data = im2double(data);
	S = [];
	for a=1:size(data,3)
		sliceData = data(:,:,a);
		dataSelected = sliceData(signal_masks(:,:,a)==1);
		S(a) = mean(dataSelected);
	end
	S
	%
	Noise = [];
	for a=1:size(data,3)
		sliceData = data(:,:,a);
		dataSelected = sliceData(noise_masks(:,:,a)==1);
		Noise(a) = std(dataSelected);
	end
	Noise
	%
	SNR=S./Noise;
end





