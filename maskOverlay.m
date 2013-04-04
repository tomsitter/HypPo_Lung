function maskOverlay(image, mask)
%Overlay mask as contour on image. Used in manual correction steps.

imagesc(image);

if sum(mask(:)) == 0
    return;
end

hold on;
contour(mask,'g','LineWidth', 1);
hold off;