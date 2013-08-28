function kclass = getJenksBreaks(dataList, numClass)
	% Adapted from the Python code here: http://danieljlewis.org/2010/06/07/jenks-natural-breaks-algorithm-in-python/
	% Minor errors were fixed for neagtive numbers
	% MATLABified a lot of the code to make it run faster
	
	% The code is broken up into parts separated by "%%" characters. The
	% original code taken from Python is in the comments named "Original"
	% and works. A vectorized version is commented with the name
	% "Vectorized". Comment the version that you don't want since there are
	% two.
	
	tic;
	if size(dataList,1)>size(dataList,2)
		dataList = dataList';
	end
	dataList = sort(dataList);
	mat1 = zeros(size(dataList,2)+1,numClass+1);
	mat2 = mat1;
	mat1(2,2:end) = 1;
	%mat2(2,2:end) = 0;% is this needed?
	mat2(3:end,2:end) = Inf;
	%v = 0;
	toc;
	tic;
	for l=3:(size(dataList,2)+1)
		%l/size(dataList,2)
		%%
		%%% Original
		%{
		s1 = 0;
		s2 = 0;
		for m=1:(l-1)
			i3 = l-m;
			val = dataList(i3);
			s2 = s2+(val*val);
			s1 = s1+val;
			v = s2-(s1*s1)/m;
			i4 = i3-1;
		%}
		%%
		%%% Vectorized
		m = 1:(l-1);
		s1 = zeros(1,size(m,2));
		s2 = zeros(1,size(m,2));
		i3 = l-m;
		val = dataList(i3);
		s2(1) = (val(1)*val(1));
		s1(1) = val(1);
		for m2=2:(l-1)
			s2(m2) = s2(m2-1)+(val(m2)*val(m2));
			s1(m2) = s1(m2-1)+val(m2);
		end
		v = s2-(s1.*s1)./m;
		i4 = i3-1;
		for m=1:(l-1)
			if i4(m)~=0
		%%
		%%% Original
			%if i4~=0
				%%
				%%% Vectorized but really slow
				%ch = mat2(l,3:numClass+1)>=(v(m)+mat2(i4(m)+1,(3:numClass+1)-1));
				%mat1(l,logical([0,0,ch])) = i3(m);
				%mat2(l,logical([0,0,ch])) = v(m)+mat2(i4(m)+1,find(ch)+1);
				%
				%
				%%
				%%% Vectorized
				for j=3:numClass+1
					if mat2(l,j)>=(v(m)+mat2(i4(m)+1,j-1))
						mat1(l,j) = i3(m);
						mat2(l,j) = v(m)+mat2(i4(m)+1,j-1);
					end
				end
				%%
				%%% Original
				%
				%{
				for j=3:numClass+1
					if mat2(l,j)>=(v+mat2(i4+1,j-1))
						mat1(l,j) = i3;
						mat2(l,j) = v+mat2(i4+1,j-1);
					end
				end
				%}
				%%
			end
		end
		mat1(l,2) = 1;
		mat2(l,2) = v(end);
	end
	toc;
	tic;
	k = size(dataList,2);
	kclass = zeros(1,numClass+1);
	kclass(numClass+1) = dataList(size(dataList,2));
	kclass(1) = dataList(1);
	countNum = numClass;
	while countNum>=2
		id = int32(mat1(k+1,countNum+1)-2);
		kclass(countNum-1+1) = dataList(id+1);
		k = int32(mat1(k+1,countNum+1)-1);
		countNum = countNum-1;
	end
	toc;
end
%{
function answer = getGVF(dataList, numClass)
	% The Goodness of Variance Fit (GVF) is found by taking the difference
	% between the squared deviations from the array mean (SDAM) and the
	% squared deviations from the class means (SDCM), and dividing by the
	% SDAM
	%
	% This function needs to be modified to use MATLAB and is still in
	% Python
	%
	breaks = getJenksBreaks(dataList, numClass)
	dataList.sort()
	listMean = sum(dataList)/len(dataList)
	print listMean
	SDAM = 0.0
	for i in range(0,len(dataList)):
		sqDev = (dataList[i] - listMean)**2
		SDAM += sqDev
	SDCM = 0.0
	for i in range(0,numClass):
		if breaks[i] == 0:
			classStart = 0
		else:
			classStart = dataList.index(breaks[i])
			classStart += 1
		classEnd = dataList.index(breaks[i+1])
		classList = dataList[classStart:classEnd+1]
		classMean = sum(classList)/len(classList)
		print classMean
		preSDCM = 0.0
		for j in range(0,len(classList)):
			sqDev2 = (classList[j] - classMean)**2
			preSDCM += sqDev2
		SDCM += preSDCM
	answer = (SDAM - SDCM)/SDAM;
%}
	
	
	
	