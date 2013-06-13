function [updateAvailable,latestVersionString,latestVersionTagName,latestVersionMessage,latestVersionDownload] ...
= checkForGitHubUpdates(currentVersionString, username, repo)
	% RETURNS:
	%     1  : Not on latest version
	%     0  : Already have latest version
	%     -1 : Error occurred when getting latest version
	%
	useAPI = 1;
	printQuota = 0;
	% for debugging
	%
	latestVersionString = currentVersionString;
	latestVersionDownload = '';
	latestVersionTagName = '';
	latestVersionMessage = '';
	% set output variables
	%
	if useAPI
		try
			tagVersions_HTTP = urlread(['https://api.github.com/repos/',username,'/',repo,'/tags']);
		catch err
			% set values to error and return
			updateAvailable = -1;
			latestVersionDownload = '';
			latestVersionTagName = '';
			latestVersionMessage = '';
			latestVersionString = '';
			return;
		end
	end
	tagVersions = parse_json(tagVersions_HTTP);
	%
	for a=1:size(tagVersions{1},2)
		thisVersionTagName = tagVersions{1}{a}.name;
		if thisVersionTagName(1)=='v'
			thisVersionString = thisVersionTagName(2:end);
			if cmpVersions(thisVersionString, latestVersionString)==1
				latestVersionString = thisVersionString;
				latestVersionDownload = tagVersions{1}{a}.zipball_url;
				latestVersionTagName = thisVersionTagName;
			end
		end
	end
	%
	if strcmp(latestVersionString,currentVersionString)
		updateAvailable = 0;
		latestVersionString = '';
		if printQuota
			try
				urlread('https://api.github.com/rate_limit')
			catch err
				% set values to error and return
				updateAvailable = -1;
				latestVersionDownload = '';
				latestVersionTagName = '';
				latestVersionMessage = '';
				latestVersionString = '';
				return;
			end
		end
		return;
	else
		updateAvailable = 1;
	end
	%
	if useAPI
		try
			tagSHA_URL_HTTP = urlread(['https://api.github.com/repos/',username,'/',repo,'/git/refs/tags','/',latestVersionTagName]);
		catch err
			% set values to error and return
			updateAvailable = -1;
			latestVersionDownload = '';
			latestVersionTagName = '';
			latestVersionMessage = '';
			latestVersionString = '';
			return;
		end
	end
	tagSHA_URL = parse_json(tagSHA_URL_HTTP);
	latestVersionURL = tagSHA_URL{1}.object.url;
	%
	if useAPI
		try
			tagMessage_HTTP = urlread(latestVersionURL);
		catch err
			% set values to error and return
			updateAvailable = -1;
			latestVersionDownload = '';
			latestVersionTagName = '';
			latestVersionMessage = '';
			latestVersionString = '';
			return;
		end
	end
	tagMessage = parse_json(tagMessage_HTTP);
	latestVersionMessage = tagMessage{1}.message;
	%
	if printQuota
		try
			urlread('https://api.github.com/rate_limit')
		catch err
			% set values to error and return
			updateAvailable = -1;
			latestVersionDownload = '';
			latestVersionTagName = '';
			latestVersionMessage = '';
			latestVersionString = '';
			return;
		end
	end
end

