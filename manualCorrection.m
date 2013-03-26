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