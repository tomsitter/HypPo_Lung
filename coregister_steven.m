function tform = coregister_steven(baseImg, imgToRegister)
	output = dftregistration(fft2(baseImg),fft2(imgToRegister),100);
	T = [1 0 0; 0 1 0; output(4) output(3) 1];
	tform = maketform('affine', T);
	%fixedImages(:,:,i) = imtransform(fixedImages(:,:,i), tform, 'XYScale', 1, 'XData',[1 256],'YData',[1 256]);
end