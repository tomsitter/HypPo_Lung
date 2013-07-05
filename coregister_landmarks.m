function [reg_bodymask, reg_body, tform] = coregister_landmarks(handles)
%COREGISTER_LANDMARKS aligns a lung mask with a body mask and returns the aligned
%body mask and image.
% function [reg_lungmask, reg_bodymask] = coregister(lungmask, bodymask)
% lungmask and bodymask are both binary images
% The user selects 3 to 7 landmarks, and then the algorithm finds a
% map to register the proton image to the helium image. This function uses 
% Afine method for translation, rotation and scaling the proton images.
%
% The function was modified first by:
%       M. Kirby June 1, 2010.
% 
% Next modification by:
%       M.Reza Heydarian, 
%       Robarts Research Institute, June 17, 2011:
% The function was modified to overlay helium image on the registered
% proton image (including their segmented cotour) and asks confirmation 
% from the user. Then the function applys the same registration map to the
% rest of the proton images.
%
% Modified by:
%   Thomas Sitter
%   TBRRI, March 27, 2013
% Incorporated into HypPo_Lung GUI

index = handles.pat_index;
slice = round(get(handles.slider_slice, 'Value'));
patient = handles.patient(index);

% lungmask = patient.lungmask(:,:,slice);
bodymask = patient.bodymask(:,:,slice);
lungs = patient.lungs(:,:,slice);
body = patient.body(:,:,slice);

target = lungs;
source = body;

while(1)
    axes(handles.axes1);
    imagesc(target)
    title( 'Helium Image', 'fontweight', 'bold', 'fontsize', 12 )

    axes(handles.axes2);
    source = imadjust(source);
    imagesc(source) 
    title( 'Proton Image', 'fontweight', 'bold', 'fontsize', 12 )

    % ---------------> reading mouse clicks
	
	jt = [];
	it = [];
	js = [];
	is = [];
	
	newJ = 1;
	newI = 1;
	
	updateStatusBox(handles, 'Select landmarks in both images. Press ENTER key when done.');  % chose features that are easy to identify
	
	while size(newJ,1)~=0
		[newJ, newI] = ginput(1);
		hold on; plot(newJ, newI, 'y+'); hold off
		if get(handles.figure1,'CurrentAxes')==handles.axes1
			text(newJ, newI, num2str(size(jt,1)+1), 'VerticalAlignment','bottom','HorizontalAlignment','right','color',[0,1,0]);
			jt = [jt; newJ];
			it = [it; newI];
		elseif get(handles.figure1,'CurrentAxes')==handles.axes2
			text(newJ, newI, num2str(size(js,1)+1), 'VerticalAlignment','bottom','HorizontalAlignment','right','color',[0,1,0]);
			js = [js; newJ];
			is = [is; newI];
		end
	end
	
    % Set up the matrix B and the vector k
    N = length( js );
    Sj = sum(js);
    Si = sum(is);
    Sjj = sum(js.*js);
    Sii = sum(is.*is);
    Siip = sum(is.*it);
    Sjjp = sum(js.*jt);
    Sjip = sum(js.*it);
    Sjpi = sum(jt.*is);
    Sjp = sum(jt);
    Sip = sum(it);
    B = [Sjj + Sii, 0, Sj, Si;...
        0, Sjj + Sii, -Si, Sj;...
        Sj, -Si, N, 0;...
        Si, Sj, 0, N];
    k = [Sjjp + Siip, Sjip - Sjpi, Sjp, Sip]';
    % Solve least-squares problem: [B]{a} = {k} using the \ operator, i.e., {a} = [B]\{k}
    a = B\k;
    %tf = isnumeric(a)

    theta = atan2( a(2), a(1) ); % Can convert to degrees or leave as radians
    s = sqrt(a(1)^2 + a(2)^2);
    dj = a(3);
    di = a(4);

    %Apply geometric operations to the target Post-Salbutamol image
    scale = [s, 0, 0; 0, s, 0; 0, 0, 1];
    rot = [cos(theta), sin(theta), 0; -sin(theta), cos(theta), 0;0, 0, 1];
    trans = [1 0 0; 0 1 0; dj di 1];
    geo_op = scale*rot*trans;
    tform = maketform('affine', geo_op);

    reg_body = imtransform(body, tform, 'xdata', [1 size(source,2)], 'ydata', [1, size(source, 1)]);
    % Nov 30 2011
%     size(registeredProton)
%     imagesc(registeredProton),axis off, axis square, colormap gray
%     imshow(registeredProton),axis off, axis square, colormap gray
    reg_body = double(reg_body);
    reg_body = reg_body - min(reg_body(:));
    reg_body = reg_body / max(reg_body(:));
    
    he = lungs;
    % Nov 30 2011
%     he = round(((he - min(he(:)))/max(he(:)))*256);
    he = double(he);
    he = he - min(he(:));
    he = he / max(he(:));
    he = imresize(he, size(reg_body));
%     green = cat(3, zeros(size(reg_body)), ones(size(reg_body)), zeros(size(reg_body)));
%     hold on;
%     imshow(green);
%     hold off;
%     he = uint8(he);
%      green = cat(3, reg_body+he, reg_body, reg_body+he );
%     green = cat(3, zeros(size(registeredProton)), ones(size(registeredProton)), zeros(size(registeredProton)));
%     hold on
    % Nov 30 2011
%     h = imagesc(green);axis off, axis square, colormap gray   
%      h = imshow(green);axis off, axis square, colormap gray
%     imwrite(green,'C:\Users\Marcus\Documents\MATLAB\ClusteringCode_Tom_Jan32013\overlay.jpg','jpg')
%     hold off
%     set(h, 'AlphaData', he)

%     % Plotting contours on the overlaid 1H/3He figure
%     hold on
%     registeredProtonMask = imtransform(H_mask, tform, 'xdata', [1 size(source,2)], 'ydata', [1, size(source, 1)]);
%     contour(registeredProtonMask,[0 0],'r','LineWidth',1);
%     contour(He_mask,[0 0],'g','LineWidth',1);

    confirm = questdlg('Is registration good enough to continue?','Yes');
    if (strcmpi(confirm,'Yes'))
        break;
    end

end

% reg_H = zeros(size(proton));  % Registered Proton images
% reg_H_mask = zeros(size(protonMask));  % Registered Mask for Proton images
% numberOfslices = size(protonMask,3);
% for indx = 1: numberOfslices
% 
%     H_image = proton(:,:,indx);
%     registered = imtransform(H_image, tform, 'xdata', [1 size(source,2)], 'ydata', [1, size(source, 1)]);
%     reg_H(:,:,indx) = registered;
% %     figure;
% %     subplot(1,2,1)
% %     imshow(reg_H(:,:,indx),[])
% 
%     H_mask = protonMask(:,:,indx);

reg_body = imtransform(body, tform, 'xdata', [1 size(source,2)], 'ydata', [1, size(source, 1)]);
reg_bodymask = imtransform(bodymask, tform, 'xdata', [1 size(source,2)], 'ydata', [1, size(source, 1)]);

     %     reg_H_mask(:,:,indx) = registered;
% %     subplot(1,2,2)
% %     imshow(reg_H_mask(:,:,indx),[])
% %     figure, imshow(protonMask(:,:,indx),[])
%      
% end