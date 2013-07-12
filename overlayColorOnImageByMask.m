function image = overlayColorOnImageByMask(image, mask, color, alpha)
	if alpha>1
		alpha = 1;
	elseif alpha<0
		alpha = 0;
	end
	%
	if alpha==1
		if ~isnan(color(1))
			image(logical([abs(mask-1)<=0.0001,zeros(size(mask)),zeros(size(mask))])) = color(1);
		end
		if ~isnan(color(2))
			image(logical([zeros(size(mask)),abs(mask-1)<=0.0001,zeros(size(mask))])) = color(2);
		end
		if ~isnan(color(3))
			image(logical([zeros(size(mask)),zeros(size(mask)),abs(mask-1)<=0.0001])) = color(3);
		end
	else
		if ~isnan(color(1))
			image(logical([abs(mask-1)<=0.0001,zeros(size(mask)),zeros(size(mask))])) = image(logical([abs(mask-1)<=0.0001,zeros(size(mask)),zeros(size(mask))]))+(color(1)-image(logical([abs(mask-1)<=0.0001,zeros(size(mask)),zeros(size(mask))])))*alpha;
		end
		if ~isnan(color(2))
			image(logical([zeros(size(mask)),abs(mask-1)<=0.0001,zeros(size(mask))])) = image(logical([zeros(size(mask)),abs(mask-1)<=0.0001,zeros(size(mask))]))+(color(2)-image(logical([zeros(size(mask)),abs(mask-1)<=0.0001,zeros(size(mask))])))*alpha;
		end
		if ~isnan(color(3))
			image(logical([zeros(size(mask)),zeros(size(mask)),abs(mask-1)<=0.0001])) = image(logical([zeros(size(mask)),zeros(size(mask)),abs(mask-1)<=0.0001]))+(color(3)-image(logical([zeros(size(mask)),zeros(size(mask)),abs(mask-1)<=0.0001])))*alpha;
		end
	end
end