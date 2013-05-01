function final_mask = thresholdmask(image, thres, mean_noise)


%%%%%%%%%%%%%%%%%%%%% Binarization of Hypex Images %%%%%%%%%%%%%%%%%%%%%
image = double(image);
mask = image > thres;

%%%%%%%%%%%%%%%%%%%%% Corrects hypex image by mask %%%%%%%%%%%%%%%%%%%%%
    
% Subtracts noise from signal image
noise_subtracted = sqrt(image.^2-2/pi*mean_noise^2);
    
% Multiplies mask to MR image
segmented = noise_subtracted .* mask;

% Normalizes images and segmented image
signal = segmented(:);
% norm_images = image/max(max_intensity);
norm_segmented = segmented/max(signal);

%%%%%%%%%%%%%%%%%%%%%%% FCM Clustering Refinement %%%%%%%%%%%%%%%%%%%%%%

% Create object for image dilation and erosion
se = strel('disk',1);

% Applies FCM clustering
norm_signal = signal./max(signal);
[center,member] = fcm(norm_signal,5);
[~,cidx] = sort(center);
member = member';
member_n = member(:,cidx);
[~,label] = max(member_n,[],2);
level_bw = (max(norm_signal(label == 1)) + ...
min(norm_signal(label == 2)))/2;

    
% Binarizes the image based on the threshold level by FCM clustering
bw = im2bw(norm_segmented,level_bw);

% Labels connective regions and passes through area filter
bw_erode = imerode(bw,se);
L = bwlabel(bw_erode);
R = regionprops(L,'Area');
idx = find([R.Area] > 40);   % Area threshold
bw_filt = ismember(L,idx);
final_mask = uint8(imdilate(bw_filt,se));