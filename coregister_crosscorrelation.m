%function [volume, uplo_stat] = coregister_auto(lungs, lungmask, body, bodymask, fov, thk)
function tform = coregister_crosscorrelation(lungmask, bodymask)

%%%%%%%%%%%%xdim = size(lungs, 1);
%%%%%%%%%%%%ydim = size(lungs, 2);
xdim = size(lungmask, 1);
ydim = size(lungmask, 2);

%%%%%%%%%%%%pixeldim = fov/xdim; % mm
%%%%%%%%%%%%voxelvol = pixeldim^2*thk*1e-6; %[L]

%Set limits for maximum shift in image registration;
yrange = round(ydim/2);
xrange = round(xdim/2);

% Initialize empty arrays
%%%%%%%%%%%%UL_array = {[], []};
%%%%%%%%%%%%LL_array = {[], []};
%%%%%%%%%%%%UR_array = {[], []};
%%%%%%%%%%%%LR_array = {[], []};

% Final images bound by binary mask
%%%%%%%%%%%%lungs = double(lungs).*lungmask;
%%%%%%%%%%%%body = double(body).*bodymask;

% Initialize volume array
%%%%%%%%%%%%volume = {'Slice','Pre Volume','Post Volume'};

%%%%%%%%%%%%slices = size(lungmask, 3);

% Perform Slice-by-Slice Image Registration
%%%%%%%%%%%%for n = 1:slices
    
    % Get the current image masks
    %%%%%%%%%%%%maskpre = lungmask(:,:,n);
    %%%%%%%%%%%%maskpost = bodymask(:,:,n);
    maskpre = lungmask;
    maskpost = bodymask;
    
    % Get the current images
    %%%%%%%%%%%%imgpre = lungs(:,:,n);
    %%%%%%%%%%%%imgpost = body(:,:,n);
    
    % Perform cross-correlation
    reg01 = xcorr2(maskpre,maskpost);
    
    % Correct cross-correlation for pixel overlap
    for i = 1:ydim*2-1
        for j = 1:xdim*2-1
            normmtx(i,j) = (ydim-abs(i-ydim))*(xdim-abs(j-xdim));
        end
    end
    normreg01=reg01./normmtx;
    
    % Find position of maximum cross correlation
    [ymaxs01,idx_s01] = max(normreg01(ydim-yrange:ydim+yrange,xdim-xrange:xdim+xrange));
    [maxval01,idx_x01] = max(ymaxs01);
    %%%%%%%%%%%%yshift01(n) = (yrange+1) - idx_s01(idx_x01);
    %%%%%%%%%%%%xshift01(n) = (xrange+1) - idx_x01;
    yshift01 = (yrange+1) - idx_s01(idx_x01);
    xshift01 = (xrange+1) - idx_x01;
    %%%%%%%%%%%%ymove01 = yshift01(n);
    %%%%%%%%%%%%xmove01 = xshift01(n);
    ymove01 = yshift01;
    xmove01 = xshift01;
	
	tform = maketform('affine',[1 0 0; 0 1 0; -xmove01 -ymove01 1]);
    
	%{
	
    % Apply translation to mask
    mod0_01 = zeros(ydim+abs(ymove01),xdim+abs(xmove01));
    mod0_01(1+(abs(ymove01)+ymove01)/2:ydim+(abs(ymove01)+ymove01)/2,...
        1+(abs(xmove01)+xmove01)/2:xdim+(abs(xmove01)+xmove01)/2) = maskpre;
    mod1_01 = zeros(ydim+abs(ymove01),xdim+abs(xmove01));
    mod1_01(1+(abs(ymove01)-ymove01)/2:ydim+(abs(ymove01)-ymove01)/2,...
        1+(abs(xmove01)-xmove01)/2:xdim+(abs(xmove01)-xmove01)/2) = maskpost;
    
    % Show mask translation in figure
    overlay0_01 = (mat2gray(im2double(maskpre))+2*mat2gray(im2double(maskpost)))/3;
    overlay1_01 = (mat2gray(mod0_01)+2*mat2gray(mod1_01))/3;
    figure
    subplot(1,2,1)
    imshow(overlay0_01)
    title('Original Images')
    subplot(1,2,2)
    imshow(overlay1_01)
    title('Registered Images')
    orient landscape
    % map colors:  black, blue, green, yellow
    map = [0 0 0; 0 0.75 1; 1 1 0; 0 1 0];
    colormap(map)
    
    % Apply translation to image
    modimg0_01 = zeros(ydim+abs(ymove01),xdim+abs(xmove01));
    modimg0_01(1+(abs(ymove01)+ymove01)/2:ydim+(abs(ymove01)+ymove01)/2,...
        1+(abs(xmove01)+xmove01)/2:xdim+(abs(xmove01)+xmove01)/2) = imgpre;
    modimg1_01 = zeros(ydim+abs(ymove01),xdim+abs(xmove01));
    modimg1_01(1+(abs(ymove01)-ymove01)/2:ydim+(abs(ymove01)-ymove01)/2,...
        1+(abs(xmove01)-xmove01)/2:xdim+(abs(xmove01)-xmove01)/2) = imgpost;
	
    % Find the intersection of the pre and post masks
    combined = modimg1_01 ~= 0 | modimg0_01 ~= 0;
    [x0,y0] = find(combined);
    
    % Finds the minimum and maximum bounds mask
    xmin = min(x0);
    xmax = max(x0);
    ymin = min(y0);
    ymax = max(y0);
    
    % Calculates the dimensions of the difference image
    xspan = xmax - xmin;
    yspan = ymax - ymin;
    
    % Find the upper/lower right/left boundaries
    ul_bd = xmin + round(xspan/2);
    rl_bd = ymin + round(yspan/2);
    
    % Compile data from current slice
    regist = {modimg0_01,modimg1_01};
    mask_regist = {mod0_01,mod1_01};
    
    % Add slice number to volume array
    volume{n+1,1} = n;
    
    % Segment images into 4 regions for pre and post
    for data_set = 1:2
        
        % Use current pre or post slice
        current = regist{data_set};
        
        % Extract UL data in second image
        UR_img = current(1:ul_bd,1:rl_bd);
        UR_nonzero = nonzeros(UR_img);
        UR_array{data_set} = vertcat(UR_array{data_set},UR_nonzero(:));
        
        % Extract LL data in second image
        LR_img = current(ul_bd+1:end,1:rl_bd);
        LR_nonzero = nonzeros(LR_img);
        LR_array{data_set} = vertcat(LR_array{data_set},LR_nonzero(:));
        
        % Extract UR data in second image
        UL_img = current(1:ul_bd,rl_bd+1:end);
        UL_nonzero = nonzeros(UL_img);
        UL_array{data_set} = vertcat(UL_array{data_set},UL_nonzero(:));
        
        % Extract LR data in second image
        LL_img = current(ul_bd+1:end,rl_bd+1:end);
        LL_nonzero = nonzeros(LL_img);
        LL_array{data_set} = vertcat(LL_array{data_set},LL_nonzero(:));
        
        % Calculate volume in second image
        volumes(n,data_set) = length(nonzeros(mask_regist{data_set}))*voxelvol;
        volume{n+1,data_set+1} = volumes(n,data_set);
    end


	% Calculate total ventilated volume
	pre_volume = sum(volumes(:,1));
	post_volume = sum(volumes(:,2));
	volume{slices+2,1} = 'Total';
	volume{slices+2,2} = pre_volume;
	volume{slices+2,3} = post_volume;

	% Calculate mean and std dev in each distribution
	uplo_stat = {'','UL Mean','UL STD','LL Mean','LL STD','UR Mean','UR STD',...
		'LR Mean','LR STD','Whole Mean','Whole STD','Norm Factor'};
	uplo_stat{2,1} = 'Pre'; uplo_stat{3,1} = 'Post';
	for jj = 1:2

		uplo_stat{jj+1,2} = mean(UL_array{jj});
		uplo_stat{jj+1,3} = std(UL_array{jj});
		uplo_stat{jj+1,4} = mean(LL_array{jj});
		uplo_stat{jj+1,5} = std(LL_array{jj});
		uplo_stat{jj+1,6} = mean(UR_array{jj});
		uplo_stat{jj+1,7} = std(UR_array{jj});
		uplo_stat{jj+1,8} = mean(LR_array{jj});
		uplo_stat{jj+1,9} = std(LR_array{jj});

		% Compile whole lung data
		whole_lung{jj} = vertcat(UL_array{jj},LL_array{jj},UR_array{jj},LR_array{jj});
		uplo_stat{jj+1,10} = mean(whole_lung{jj});
		uplo_stat{jj+1,11} = std(whole_lung{jj});

		% Calculates histogram
		minxdata = 0;
		if isempty(whole_lung{jj})
			maxxdata(jj) = 0;
		else
			maxxdata(jj) = max(whole_lung{jj});
		end
		xx = [minxdata-10*eps + (0:maxxdata(jj)-1), maxxdata(jj)];
		x{jj} = xx(1:length(xx)-1) + 1/2;
		whole_dist{jj} = hist(whole_lung{jj},x{jj});
		if isempty(whole_dist{jj})
			max_whole_dist(jj) = 0;
		else
			max_whole_dist(jj) = max(whole_dist{jj});
		end
	end

	% Add normalization factor to array
	% uplo_stat{2,12} = norm_factor(1);
	% uplo_stat{3,12} = norm_factor(2);

	uplo_stat
	
	%}

%%%%%%%%%%%%end
% % Display histograms
% figure
% for jj = 1:2
%     subplot(1,2,jj);
%     bar(x{jj},whole_dist{jj});
%     title(['EXP ' num2str(jj)]);
%     axis([0 max(maxxdata) 0 max(max_whole_dist)]);
% end





%%%%%%%%%%%%%%%%%%%%% ORIGINAL FUNCTION %%%%%%%%%%%%%%%%%%%%%%%%%%





%{
function [volume, uplo_stat] = coregister(lungs, lungmask, body, bodymask, fov, thk, norm_factor)

[xdim, ydim] = size(lungs);

pixeldim = fov/xdim; % mm
voxelvol = pixeldim^2*thk*1e-6; %[L]

%Set limits for maximum shift in image registration;
yrange = 128;
xrange = 128;

% Initialize empty arrays
UL_array = {[], []};
LL_array = {[], []};
UR_array = {[], []};
LR_array = {[], []};

% Final images bound by binary mask
lungs = lungs.*lungmask;
body = body.*bodymask;

% Initialize volume array
volume = {'Slice','Pre Volume','Post Volume'};

% Perform Slice-by-Slice Image Registration
%for n = 1:slices
    
    % Get the current image masks
    maskpre = lungmask(:,:,n);
    maskpost = bodymask(:,:,n);
    
    % Get the current images
    imgpre = lungs(:,:,n);
    imgpost = body(:,:,n);
    
    % Perform cross-correlation
    reg01 = xcorr2(imgpre,imgpost);
    
    % Correct cross-correlation for pixel overlap
    for i = 1:ydim*2-1
        for j = 1:xdim*2-1
            normmtx(i,j) = (ydim-abs(i-ydim))*(xdim-abs(j-xdim));
        end
    end
    normreg01=reg01./normmtx;
    
    % Find position of maximum cross correlation
    [ymaxs01,idx_s01] = max(normreg01(ydim-yrange:ydim+yrange,xdim-xrange:xdim+xrange));
    [maxval01,idx_x01] = max(ymaxs01);
    yshift01(n) = (yrange+1) - idx_s01(idx_x01);
    xshift01(n) = (xrange+1) - idx_x01;
    ymove01 = yshift01(n);
    xmove01 = xshift01(n);
    
    % Apply translation to mask
    mod0_01 = zeros(ydim+abs(ymove01),xdim+abs(xmove01));
    mod0_01(1+(abs(ymove01)+ymove01)/2:ydim+(abs(ymove01)+ymove01)/2,...
        1+(abs(xmove01)+xmove01)/2:xdim+(abs(xmove01)+xmove01)/2) = maskpre;
    mod1_01 = zeros(ydim+abs(ymove01),xdim+abs(xmove01));
    mod1_01(1+(abs(ymove01)-ymove01)/2:ydim+(abs(ymove01)-ymove01)/2,...
        1+(abs(xmove01)-xmove01)/2:xdim+(abs(xmove01)-xmove01)/2) = maskpost;
    
    % Show mask translation in figure
    overlay0_01 = (mat2gray(im2double(maskpre))+2*mat2gray(im2double(maskpost)))/3;
    overlay1_01 = (mat2gray(mod0_01)+2*mat2gray(mod1_01))/3;
    figure
    subplot(1,2,1)
    imshow(overlay0_01)
    title('Original Images')
    subplot(1,2,2)
    imshow(overlay1_01)
    title('Registered Images')
    orient landscape
    % map colors:  black, blue, green, yellow
    map = [0 0 0; 0 0.75 1; 1 1 0; 0 1 0];
    colormap(map)
    
    % Apply translation to image
    modimg0_01 = zeros(ydim+abs(ymove01),xdim+abs(xmove01));
    modimg0_01(1+(abs(ymove01)+ymove01)/2:ydim+(abs(ymove01)+ymove01)/2,...
        1+(abs(xmove01)+xmove01)/2:xdim+(abs(xmove01)+xmove01)/2) = imgpre;
    modimg1_01 = zeros(ydim+abs(ymove01),xdim+abs(xmove01));
    modimg1_01(1+(abs(ymove01)-ymove01)/2:ydim+(abs(ymove01)-ymove01)/2,...
        1+(abs(xmove01)-xmove01)/2:xdim+(abs(xmove01)-xmove01)/2) = imgpost;
    
    % Find the intersection of the pre and post masks
    combined = modimg1_01 ~= 0 | modimg0_01 ~= 0;
    [x0,y0] = find(combined);
    
    % Finds the minimum and maximum bounds mask
    xmin = min(x0);
    xmax = max(x0);
    ymin = min(y0);
    ymax = max(y0);
    
    % Calculates the dimensions of the difference image
    xspan = xmax - xmin;
    yspan = ymax - ymin;
    
    % Find the upper/lower right/left boundaries
    ul_bd = xmin + round(xspan/2);
    rl_bd = ymin + round(yspan/2);
    
    % Compile data from current slice
    regist = {modimg0_01,modimg1_01};
    mask_regist = {mod0_01,mod1_01};
    
    % Add slice number to volume array
    volume{n+1,1} = n;
    
    % Segment images into 4 regions for pre and post
    for data_set = 1:2
        
        % Use current pre or post slice
        current = regist{data_set};
        
        % Extract UL data in second image
        UR_img = current(1:ul_bd,1:rl_bd);
        UR_nonzero = nonzeros(UR_img);
        UR_array{data_set} = vertcat(UR_array{data_set},UR_nonzero(:));
        
        % Extract LL data in second image
        LR_img = current(ul_bd+1:end,1:rl_bd);
        LR_nonzero = nonzeros(LR_img);
        LR_array{data_set} = vertcat(LR_array{data_set},LR_nonzero(:));
        
        % Extract UR data in second image
        UL_img = current(1:ul_bd,rl_bd+1:end);
        UL_nonzero = nonzeros(UL_img);
        UL_array{data_set} = vertcat(UL_array{data_set},UL_nonzero(:));
        
        % Extract LR data in second image
        LL_img = current(ul_bd+1:end,rl_bd+1:end);
        LL_nonzero = nonzeros(LL_img);
        LL_array{data_set} = vertcat(LL_array{data_set},LL_nonzero(:));
        
        % Calculate volume in second image
        volumes(n,data_set) = length(nonzeros(mask_regist{data_set}))*V_voxel;
        volume{n+1,data_set+1} = volumes(n,data_set);
    end
end

% Calculate total ventilated volume
pre_volume = sum(volumes(:,1));
post_volume = sum(volumes(:,2));
volume{slices+2,1} = 'Total';
volume{slices+2,2} = pre_volume;
volume{slices+2,3} = post_volume;

% Calculate mean and std dev in each distribution
uplo_stat = {'','UL Mean','UL STD','LL Mean','LL STD','UR Mean','UR STD',...
    'LR Mean','LR STD','Whole Mean','Whole STD','Norm Factor'};
uplo_stat{2,1} = 'Pre'; uplo_stat{3,1} = 'Post';
for jj = 1:2
    
    uplo_stat{jj+1,2} = mean(UL_array{jj});
    uplo_stat{jj+1,3} = std(UL_array{jj});
    uplo_stat{jj+1,4} = mean(LL_array{jj});
    uplo_stat{jj+1,5} = std(LL_array{jj});
    uplo_stat{jj+1,6} = mean(UR_array{jj});
    uplo_stat{jj+1,7} = std(UR_array{jj});
    uplo_stat{jj+1,8} = mean(LR_array{jj});
    uplo_stat{jj+1,9} = std(LR_array{jj});
    
    % Compile whole lung data
    whole_lung{jj} = vertcat(UL_array{jj},LL_array{jj},UR_array{jj},LR_array{jj});
    uplo_stat{jj+1,10} = mean(whole_lung{jj});
    uplo_stat{jj+1,11} = std(whole_lung{jj});
    
    % Calculates histogram
    minxdata = 0;
    maxxdata(jj) = max(whole_lung{jj});
    xx = [minxdata-10*eps + (0:maxxdata(jj)-1), maxxdata(jj)];
    x{jj} = xx(1:length(xx)-1) + 1/2;
    whole_dist{jj} = hist(whole_lung{jj},x{jj});
    max_whole_dist(jj) = max(whole_dist{jj});
%end

% Add normalization factor to array
uplo_stat{2,12} = norm_factor(1);
uplo_stat{3,12} = norm_factor(2);

uplo_stat
 
% % Display histograms
% figure
% for jj = 1:2
%     subplot(1,2,jj);
%     bar(x{jj},whole_dist{jj});
%     title(['EXP ' num2str(jj)]);
%     axis([0 max(maxxdata) 0 max(max_whole_dist)]);
% end
%}