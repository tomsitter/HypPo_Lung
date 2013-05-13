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

if not(isreal(norm_signal))
    final_mask = zeros(size(image));
    return;
end

[center,member] = fcm(norm_signal,5);
[c, m] = kmeans(norm_signal, 5, 'EmptyAction', 'singleton', 'Replicates', 5);

temp_mask = reshape(c, size(image));

threshmask = temp_mask > 1;


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
bw_erodek = imerode(threshmask, se);
L = bwlabel(bw_erode);
Lk = bwlabel(bw_erodek);
R = regionprops(L,'Area');
Rk = regionprops(Lk, 'Area');
idx = find([R.Area] > 40);   % Area threshold
idxk = find([Rk.Area] > 40);
bw_filt = ismember(L,idx);
bw_filtk = ismember(Lk, idxk);
final_maskk = uint8(imdilate(bw_filtk, se));
% figure(3), imagesc(final_maskk);
final_mask = uint8(imdilate(bw_filt,se));