function result = cmpVersions(verA, verB)
	if size(verA,2)==0 || size(verB,2)==0
		error('Versions must not be empty');
	end
	if size(regexp(verA, '[^0-9\.]', 'match'),2)>0 || size(regexp(verB, '[^0-9\.]', 'match'),2)>0
		error('Versions must only contain numeric digits and periods');
	end
	if verA(1)=='.'||verA(end)=='.'||verB(1)=='.'||verB(end)=='.'
		error('Versions must not begin or end with a period');
	end
	%
	result = -2;
	%
	if strcmp(verA,verB)
		result = 0;
		return;
	end
	%
	splitVerA = regexp(verA,'\.', 'split');
	splitVerB = regexp(verB,'\.', 'split');
	%
	for a=1:max([size(splitVerA,2),size(splitVerB,2)])
		if a>size(splitVerA,2)
			splitVerA{a} = '0';
		end
		if a>size(splitVerB,2)
			splitVerB{a} = '0';
		end
		%
		splitVerA{a} = str2num(splitVerA{a});
		splitVerB{a} = str2num(splitVerB{a});
		%
		if splitVerA{a}>splitVerB{a}
			result = 1;
			return;
		elseif splitVerA{a}<splitVerB{a}
			result = -1;
			return;
		end
	end
	%
	result = 0;
	return;
end