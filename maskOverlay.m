function maskOverlay(image, mask)
%MASKOVERLAY Overlay mask as contour on image.

if nargin ~= 2
    error('Wrong number of arguments; two expected.')
end

imagesc(image);

if sum(mask(:)) == 0
    return;
end

hold on;
contour(mask,'g','LineWidth', 1);
hold off;