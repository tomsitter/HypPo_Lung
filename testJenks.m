function testJenks()
	tic
	numClass = 2;
	A = rand(20);
	%A = [2 3 4 5 10 11 12];
	A = A(:);
	dataList = A;
	if size(dataList,1)>size(dataList,2)
		dataList = dataList';
	end
	dataList = sort(dataList);
	mat1 = zeros(size(dataList,2)+1,numClass+1);
	mat2 = mat1;
	mat1(2,2:end) = 1;
	%mat2(2,2:end) = 0;% is this needed?
	mat2(3:end,2:end) = Inf;
	%
	%
	%
	l = 3:(size(dataList,2)+1);
	m = 1:(l(end)-1);
	m = m(ones(size(l,2),1), :);
	l = l(ones(size(m,2),1), :);
	l = l';
	%
	s1 = zeros(size(m));
	s2 = s1;
	%
	i3 = l-m;
	count = 1;
	val = zeros(size(i3));
	val(i3>0) = dataList(i3(i3>0));
	s2(:,1) = val(:,1).*val(:,1);
	s1(:,1) = val(:,1);
	for m2=2:(size(m,2))
		s2(:,m2) = s2(:,m2-1)+(val(:,m2).*val(:,m2));
		s1(:,m2) = s1(:,m2-1)+val(:,m2);
	end
	v = s2-(s1.*s1)./m;
	i4 = i3-1;
	%%%%%
	selectV = eye(size(v));
	selectV = selectV(end:-1:1,end:-1:1);
 	mat2(3:end,2) = v(logical(selectV));
	%%%%%
	%%%
	%for l=3:(size(dataList,2)+1)
	toc
	%{
	for mInd=1:(size(l,1)+1)
		for j=3:numClass+1
			ch = mat2(l(end:-1:mInd,mInd),j) >= v(end:-1:mInd,mInd)+mat2(i4(end:-1:mInd,mInd)+1,j-1);
			ch = ch(1:((size(l,1)+1)-mInd));
			mat1((size(l,1)+1)-find(ch),j) = i3((size(l,1)+1)-find(ch),mInd);%(size(l,1)+1)-find(ch),mInd
			mat1((size(l,1)+1)-find(ch),j)
			i3((size(l,1)+1)-find(ch),mInd)
			mat2((size(l,1)+1)-find(ch),j) = v((size(l,1)+1)-find(ch),mInd)+mat2(i4((size(l,1)+1)-find(ch),mInd)+1,j-1);
			
			
			%if mat2(l(lInd,mInd),j) >= v(lInd,mInd)+mat2(i4(lInd,mInd)+1,j-1)
			%{
			if mat2(i4>-1,j) >= v(i4>-1)+mat2(i4(i4>-1)+1,j-1)
				mat1(l(:),j) = i3(:);
				mat2(l(:),j) = v(:)+mat2(i4(:)+1,j-1);
			end
			%}
		end
	end
	%}
	%
	tic
	for lInd=1:size(l,1)
		%for m=1:(l-1)
		for mInd=1:(lInd+1)
			%
			%display([num2str(lInd),',',num2str(mInd)])
			%if i4(lInd,mInd)~=0
				%display([num2str(lInd),',',num2str(mInd)])
			%if i4~=0
				%ch = mat2(l(lInd,mInd),3:numClass+1)>=(v(lInd,mInd)+mat2(i4(lInd,mInd)+1,(3:numClass+1)-1));
				%mat1(l(lInd,mInd),logical([0,0,ch])) = i3(lInd,mInd);
				%mat2(l(lInd,mInd),logical([0,0,ch])) = v(lInd,mInd)+mat2(i4(lInd,mInd)+1,find(ch)+1);
				%
				%
				for j=3:numClass+1
					count = count+mat2(i4(lInd,mInd)+1,j-1);
					if mat2(l(lInd,mInd),j) >= v(lInd,mInd)+mat2(i4(lInd,mInd)+1,j-1)
						mat1(l(lInd,mInd),j) = i3(lInd,mInd);
						mat2(l(lInd,mInd),j) = v(lInd,mInd)+mat2(i4(lInd,mInd)+1,j-1);
					end
				end
				%
				%{
				for j=3:numClass+1
					if mat2(l,j)>=(v+mat2(i4+1,j-1))
						mat1(l,j) = i3;
						mat2(l,j) = v+mat2(i4+1,j-1);
					end
				end
				%}
			%end
		end
	end
	toc
	%
	tic
	count;
	%%%
	mat1(3:end,2) = 1;
	selectV = eye(size(v));
	selectV = selectV(end:-1:1,end:-1:1);
 	mat2(3:end,2) = v(logical(selectV));
	mat1;
	mat2;
	%%%
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
	toc
	kclass
end














