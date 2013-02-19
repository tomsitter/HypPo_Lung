function [handles, final_mask] = threshold_mask(hObject, handles)
%function final_mask = threshold_mask(images, threshold, mean_noise)

%%%%%%%%%%%%%%%%%%%%% Binarization of Hypex Images %%%%%%%%%%%%%%%%%%%%%

% Determines threshold that yields the lowest error function
%[vals,ix] = sort(ef);
%thres = ix(1);

% Calculates the mean of the noise distribution
% noise_mean = mean(noise_array);

% Create image mask
%figure(3);
%for n = 1:slices
    % Finds pixel intensity values that exceed the threshold
    %mask(:,:,n) = images(:,:,n) > thres;
    
    % Displays initial segmentation results
    %subplot(m,4,n); 
    %imshow(mask(:,:,n))
%end

%Get lung images of current patient and slice
index = handles.pat_index;
slice = get(handles.slider_slice, 'Value');
patient = handles.patient(index);
images = patient.lung(:,:,slice);
final_mask = ones(size(images));

if (length(patient.threshold) < slice) || (isempty(patient.threshold{slice}))
    updateStatusBox(handles, 'Threshold value missing, calculate noise first' , 0);
    return;
elseif (length(patient.mean_noise) < slice) || (isempty(patient.mean_noise{slice}))
    updateStatusBox(handles, 'Mean noise value missing, calculate noise first' , 0);
    return;
end

%Get threshold values;
thres = patient.threshold{slice};
mean_noise = patient.mean_noise{slice};

images = double(images);

mask = images > thres;
% figure;
% imshow(mask);


%%%%%%%%%%%%%%%%%%%%%%%%% Manual Correction %%%%%%%%%%%%%%%%%%%%%%%%%%

% In the event that manual removal is needed
% manual_remove = menu('Do any of these images need manual correction?', 'Yes', 'No');
% 
% while manual_remove == 1
% 
%     % Enter the slice for artifact removal
%     slice_remove = input('Enter slice for artifact removal: ');
%     
%     % Selection of artifact regions not to be included in ventilation calculations
%     temp_slice = mask(:,:,slice_remove);
%     figure(4)
%     art_select = 2;
%     while art_select == 2
%         disp('Select out any artifact region');
%         artifact = roipoly(temp_slice);
%         temp_slice = temp_slice - artifact;
%         imshow(temp_slice)
%         art_select = menu('Done with artifact removal?', 'Yes', 'No');
%     end
%     close(4)
%     
%     % Error-checking to ensure intensities are not negative
%     mask(:,:,slice_remove) = temp_slice.*(temp_slice > 0);
%     
%     % Update plot 
%     figure(3);
%     subplot(m,4,slice_remove);
%     imshow(mask(:,:,slice_remove))
%     
%     % Check to see if other slices need correction
%     manual_remove = menu('Do any of these images need manual correction?', 'Yes', 'No');  
% end

%%%%%%%%%%%%%%%%%%%%% Corrects hypex image by mask %%%%%%%%%%%%%%%%%%%%%

% Initialize array noise corrected signal data
% signal_vals = [];

% for n = 1:slices

    % Stores pixel intensities of entire hypex image into an array
    %max_slice(n) = max(max(images(:,:,n)));
    max_intensity = max(max(images)); 
    
    
    % Subtracts noise from signal image
    noise_subtracted = sqrt(images.^2-2/pi*mean_noise^2);
    
    % Multiplies mask to MR image
%     segmented(:,:,n) = noise_subtracted(:,:,n).*mask(:,:,n);
    segmented = noise_subtracted .* mask;

    % Stores pixel intensities of adjusted hypex image into an array
%     adjusted_images = segmented(:,:,n);
%     signal_vals = vertcat(signal_vals,adjusted_images(:));
    
% end

% Normalizes images and segmented image
signal = segmented(:);
norm_images = images/max(max_intensity);
norm_segmented = segmented/max(signal);

%%%%%%%%%%%%%%%%%%%%%%% FCM Clustering Refinement %%%%%%%%%%%%%%%%%%%%%%

% Create object for image dilation and erosion
se = strel('disk',1);

% Applies FCM clustering
norm_signal = signal./max(signal);
[center,member] = fcm(norm_signal,5);
[center,cidx] = sort(center);
member = member';
member_n = member(:,cidx);
[maxmember,label] = max(member_n,[],2);
level_bw = (max(norm_signal(label == 1)) + ...
    min(norm_signal(label == 2)))/2;

% Create final mask
% figure(3)
% hold on
% for n = 1:slices
    
    % Binarizes the image based on the threshold level by FCM clustering
%     bw = im2bw(norm_segmented(:,:,n),level_bw);
    bw = im2bw(norm_segmented,level_bw);

    % Labels connective regions and passes through area filter
    bw_erode = imerode(bw,se);
    L = bwlabel(bw_erode);
    R = regionprops(L,'Area');
    Area_vec = [R.Area];
    idx = find([R.Area] > 40);   % Area threshold
%     bw_filt(:,:,n) = ismember(L,idx);
    bw_filt = ismember(L,idx);
%     final_mask(:,:,n) = imdilate(bw_filt(:,:,n),se);
    final_mask = imdilate(bw_filt,se);

    % Displays resultant binary mask
%     subplot(m,4,n); 
%     imshow(final_mask(:,:,n))
%      imshow(final_mask)
% end

% Show final segmented images with outline
%figure(5);
% for n = 1:slices
    
    % Finds outline of segmented lung
%     p0 = bwperim(final_mask(:,:,n));
    p0 = bwperim(final_mask);
    [i0,j0]=find(p0);
    
    % Displays outline of segmented lung
%     subplot(m,4,n);
%     imshow(norm_images(:,:,n))

%    plot(j0,i0,'r.','MarkerSize',5)
    
%     hold off;
% end


%Save mask
handles.patient(index).seglung{slice} = mask;
guidata(hObject, handles);

%Display to user
axes(handles.axes2);
imagesc(mask);