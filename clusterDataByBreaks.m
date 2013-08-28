function clusters = clusterDataByBreaks(data, middleBreaks)
	clusters = zeros(size(data));
	clusters(data<=middleBreaks(1)) = 1;
	for a=2:size(middleBreaks,2)
		clusters(data<=middleBreaks(a)&data>middleBreaks(a-1)) = a;
	end
	clusters(data>middleBreaks(end)) = size(middleBreaks,2)+1;
end