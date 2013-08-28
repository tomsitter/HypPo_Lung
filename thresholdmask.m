function binary_mask = thresholdmask(image, thres, mean_noise)


%%%%%%%%%%%%%%%%%%%%% Binarization of Hypex Images %%%%%%%%%%%%%%%%%%%%%
image = double(image);
mask = image > thres;
binary_mask = zeros(size(image));


%%%%%%%%%%%%%%%%%%%%% Corrects hypex image by mask %%%%%%%%%%%%%%%%%%%%%
    
% Subtracts noise from signal image
if mean_noise~=0
	noise_subtracted = sqrt(image.^2-2/pi*mean_noise^2);
else
	noise_subtracted = image;
end

% Multiplies mask to MR image
segmented = noise_subtracted .* mask;

% Normalizes images and segmented image
signal = segmented(:);
% norm_images = image/max(max_intensity);
if max(signal)~=0
	norm_segmented = segmented/max(signal);
else
	norm_segmented = segmented;
end

%%%%%%%%%%%%%%%%%%%%%%% FCM Clustering Refinement %%%%%%%%%%%%%%%%%%%%%%

% Create object for image dilation and erosion
se = strel('disk',1);

% Applies FCM clustering
if max(signal)~=0
	norm_signal = signal./max(signal);
else
	norm_signal = signal;
end

if not(isreal(norm_signal))
    final_mask = zeros(size(image));
    return;
end

%{
% [center,member] = fcm(norm_signal,5);
s = warning('off','stats:kmeans:EmptyCluster');
[c, m] = kmeans(norm_segmented(:), 5, 'EmptyAction', 'singleton', 'Replicates', 5);
warning(s);
%restore state

% temp_mask = reshape(c, size(image));

first_mask = zeros(size(image(:)));

[val m_ind] = sort(m);

for i = 1:length(m)
    first_mask(c == m_ind(i)) = i;
end
%}
avgSize = 2;
filter = fspecial('average',avgSize);
norm_segmented_averaged = filter2(filter,norm_segmented);
norm_segmented_averaged = norm_segmented_averaged(1:(2*avgSize+1):end, 1:(2*avgSize+1):end);
breaks = getJenksBreaks(norm_segmented_averaged(:), 5);
breaks = breaks(2:end-1);
c = clusterDataByBreaks(norm_segmented(:), breaks);

first_mask = c;

first_mask = reshape(first_mask, size(image));

threshmask = first_mask > 1;

%second level kmeans of noise region, not yet implemented

cluster1 = first_mask == 1;

second_signal = norm_signal(cluster1);

%{
s = warning('off','stats:kmeans:EmptyCluster');
[c2, m2] = kmeans(second_signal, 4, 'EmptyAction', 'singleton', 'Replicates', 5);
warning(s);
%restore state
%}
avgSize = 7;
filter = fspecial('average',avgSize);
second_signal_averaged = filter2(filter,second_signal);
second_signal_averaged = second_signal_averaged(1:(2*avgSize+1):end, 1:(2*avgSize+1):end);
breaks = getJenksBreaks(second_signal_averaged(:), 5);
breaks = breaks(2:end-1);
c2 = clusterDataByBreaks(second_signal(:), breaks);

% tmask = reshape(c2, size(image));

c3 = c2 > 2;

newcluster1 = zeros(size(cluster1));
newcluster1(cluster1) = c3;
newcluster2 = reshape(newcluster1, size(image));

% newcluster1(newcluster1 == 1) = 0; 
% newcluster1 = newcluster1 .* 2;

final_mask = first_mask + newcluster2;

threshmask = final_mask > 1;

% [~,cidx] = sort(center);
% member = member';
% member_n = member(:,cidx);
% [~,label] = max(member_n,[],2);
% level_bw = (max(norm_signal(label == 1)) + ...
% min(norm_signal(label == 2)))/2;

    
% Binarizes the image based on the threshold level by FCM clustering
% bw = im2bw(norm_segmented,level_bw);

% Labels connective regions and passes through area filter
% bw_erode = imerode(bw,se);
bw_erode = imerode(threshmask, se);
% L = bwlabel(bw_erode);
L = bwlabel(bw_erode);
% R = regionprops(L,'Area');
R = regionprops(L, 'Area');
% idx = find([R.Area] > 40);   % Area threshold
idx = find([R.Area] > 40);
% bw_filt = ismember(L,idx);
bw_filt = ismember(L, idx);
final_mask = uint8(imdilate(bw_filt, se) .* final_mask);
binary_mask = final_mask > 0;

% figure(3), imagesc(final_maskk);
% final_mask = uint8(imdilate(bw_filt,se));