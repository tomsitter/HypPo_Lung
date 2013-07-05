function hetero_image = heterogeneity(image, mask, noise)

% load roi012
hetero_image = zeros(size(mask));

% lungsize = regionprops(mask, 'BoundingBox');

%clean up holes in lungmask
mask = imclose(mask, strel('disk', 3));

L = bwlabel(mask);
stats = regionprops(L, 'BoundingBox');

% if length(stats) < 2
%     return
% end;

for i = 1:length(stats)

%     leftL = floor(stats(i).BoundingBox(1));
%     leftR = ceil(stats(i).BoundingBox(1) + stats(i).BoundingBox(3));

% rightL = floor(stats(2).BoundingBox(1));
% rightR = ceil(stats(2).BoundingBox(1) + stats(1).BoundingBox(3));

% Lscale = 2 * round((rightL+rightR-leftL-leftR)/40) + 1;
    Lscale = 4;
% noise0=mean2(   image(min(hy):max(hy),min(hx):max(hx)));


    gxL = [floor(stats(i).BoundingBox(1)); ceil(stats(i).BoundingBox(1)+stats(i).BoundingBox(3))];
    gyL = [floor(stats(i).BoundingBox(2)+stats(i).BoundingBox(4)); ceil(stats(i).BoundingBox(2))];

% gxR = [floor(stats(2).BoundingBox(1)); ceil(stats(2).BoundingBox(1)+stats(2).BoundingBox(3))];
% gyR = [floor(stats(2).BoundingBox(2)); ceil(stats(2).BoundingBox(2)+stats(2).BoundingBox(4))];

    upL = max(min(gyL), 1);
    downL = max(gyL);
    leftL = max(min(gxL), 1);
    rightL = max(gxL);
% upR=min(gyR);
% downR=max(gyR);
% leftR=min(gxR);
% rightR=max(gxR);

    % left and right ROIs
    bwL=mask(upL:downL,leftL:rightL);
    % bwR=mask(upR:downR,leftR:rightR);
    LRroi=zeros(size(mask));
    LRroi(upL:downL,leftL:rightL)=1;
    % LRroi(upR:downR,leftR:rightR)=1;

    ave0L = ones(downL-upL+1, rightL-leftL+1);
    stdev0L = zeros(downL-upL+1, rightL-leftL+1);

    % average and standard deviation calculation for each of the 3 image sets
    for i=1:downL-upL+1
        for j=1:rightL-leftL+1
            pixel=zeros(size(image));
            pixel(i+upL-1,j+leftL-1)=1;
            inbw=sum(sum(pixel.*im2double(mask)));
            if inbw==1
    %             sub0=0;  sub1=0;  sub2=0;
                ROI=zeros(size(image));
                ROI(i+ upL -1-round(Lscale):i+ upL -1+round(Lscale),...
                    j+leftL-1-round(Lscale):j+leftL-1+round(Lscale))=1;
                overlap=ROI.*im2double(mask);
                if sum(sum(overlap))==(1+2*round(Lscale))*(1+2*round(Lscale))
                    rage0=mean2(  image (i+ upL -1-round(Lscale):i+ upL -1+round(Lscale),...
                                      j+leftL-1-round(Lscale):j+leftL-1+round(Lscale))-noise);
                    if rage0>noise
                        ave0L(i,j)=rage0;
                        stdev0L(i,j)=std2(image(i+ upL -1-round(Lscale):i+ upL -1+round(Lscale),...
                                             j+leftL-1-round(Lscale):j+leftL-1+round(Lscale)));
                    else
                        stdev0L(i,j)=NaN;
                    end
                else
                    [iroi,jroi]=find(overlap);
                    lroi=length(iroi);
                    valroi0=zeros(1, lroi);
                    for k=1:lroi
                        valroi0(k)=image(iroi(k),jroi(k));
                    end

                    rage0=mean(valroi0); %-noise;
                    if rage0>noise
                        ave0L(i,j)=rage0;
                        stdev0L(i,j)=std(valroi0);
                    else
                        stdev0L(i,j)=NaN;
                    end
                end
            end
        end
    end

% ave0R = ones(downR-upR+1, rightR-leftR+1);
% stdev0R = zeros(downR-upR+1, rightR-leftR+1);
% 
% for i=1:downR-upR+1
%     for j=1:rightR-leftR+1
%         pixel=zeros(size(image));
%         pixel(i+upR-1,j+leftR-1)=1;
%         inbw=sum(sum(pixel.*im2double(mask)));
%         if inbw==1
% %             sub0=0;  sub1=0;  sub2=0;
%             ROI=zeros(size(image));
%             ROI(i+ upR -1-round(Lscale):i+ upR -1+round(Lscale),...
%                 j+leftR-1-round(Lscale):j+leftR-1+round(Lscale))=1;
%             overlap=ROI.*im2double(mask);
%             if sum(sum(overlap))==(1+2*round(Lscale))*(1+2*round(Lscale))
%                 rage0=mean2(  image (i+ upR -1-round(Lscale):i+ upR -1+round(Lscale),...
%                                   j+leftR-1-round(Lscale):j+leftR-1+round(Lscale))-noise);
%                 if rage0>noise
%                     ave0R(i,j)=rage0;
%                     stdev0R(i,j)=std2(image(i+ upR -1-round(Lscale):i+ upR -1+round(Lscale),...
%                                          j+leftR-1-round(Lscale):j+leftR-1+round(Lscale)));
%                 else
%                     stdev0R(i,j)=-0.1;
%                 end
%             else
%                 [iroi,jroi]=find(overlap);
%                 lroi=length(iroi);
%                 valroi0=zeros(1, lroi);
%                 for k=1:lroi
%                     valroi0(k)=image(iroi(k),jroi(k));
%                 end
%                 rage0=mean(valroi0)-noise;
%                 if rage0>noise
%                     ave0R(i,j)=rage0;
%                     stdev0R(i,j)=std(valroi0);
%                 else
%                     stdev0R(i,j)=-0.1;
%                 end
%             end
%         end
%     end
% end

    ave0(upL:downL,leftL:rightL)=ave0L.*im2double(bwL);
    % ave0(upR:downR,leftR:rightR)=ave0R.*im2double(bwR);
    stdev0(upL:downL,leftL:rightL)=stdev0L.*im2double(bwL);
    % stdev0(upR:downR,leftR:rightR)=stdev0R.*im2double(bwR);

    NDdev0=stdev0./ave0;

    % up=min(upL,upR);
    % down=max(downL,downR);
    % left1=min(leftL,leftR);
    % right=max(rightL,rightR);
    bwroi=LRroi(upL:downL,leftL:rightL).*im2double(mask(upL:downL,leftL:rightL));
    hetero=NDdev0(upL:downL,leftL:rightL).*bwroi;

    hetero_image(upL:downL,leftL:rightL) = hetero;
end