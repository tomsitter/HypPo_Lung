function checkAndGetUpdates(username, repo, projectFolderPath)
	% checkAndGetUpdates() will connect to GitHub and check for/download the
	% latest version.
	% 
	% Steps:
	% 	1) get the tags for the repo
	%	2) find the version tags
	%	3) compare the version tags to find the latest version
	%	4) compare the current version to the latest version
	%	5) download the latest version if needed
	% 
	% Directory Structure:
	%	- project folder
	%		- Updates
	%			- Latest_Version
	%				- ZIP project (example folder name: user-repo-sha)
	%					- versionNumber.txt
	%			- lastUpdateCheck.txt
	%		- versionNumber.txt
	% 
	if exist([projectFolderPath,'/versionNumber.txt'],'file')==0
		% the current program doesn't have a file with the version number,
		% so the current version is a development version
		disp 'Running development version.'
		return;
	end
	%
	if exist([projectFolderPath,'/Updates'],'dir')==0
		% if the 'Updates' folder doesn't exist, create it
		mkdir([projectFolderPath,'/Updates']);
	end
	%
	if exist([projectFolderPath,'/Updates/DONT STORE FILES HERE'],'file')==0
		% if the 'DONT STORE FILES HERE' file doesn't exist, create it
		fileID = fopen([projectFolderPath,'/Updates/DONT STORE FILES HERE'],'w');
		fclose(fileID);
	end
	%
	if exist([projectFolderPath,'/Updates/lastUpdateCheck.txt'],'file')==0
		% if the 'Updates/lastUpdateCheck.txt' file doesn't exist, create it
		fileID = fopen([projectFolderPath,'/Updates/lastUpdateCheck.txt'],'w');
		fclose(fileID);
	end
	%
	fileID = fopen([projectFolderPath,'/Updates/lastUpdateCheck.txt'],'r');
	lastUpdateCheckDate = fscanf(fileID, '%s');
	fclose(fileID);
	%
	fileID = fopen([projectFolderPath,'/Updates/lastUpdateCheck.txt'],'w');
	currentDate = date;
	% date is a MATLAB variable
	%
	if strcmp(lastUpdateCheckDate,'')==1
		% if the date of the last update check did not exist, force an
		% update and set the last update check to the current date
		updateCheck = 1;
		fprintf(fileID, '%s', currentDate);
	else
		formatIn = 'dd-mmm-yyyy';
		if datenum(currentDate,formatIn)>datenum(lastUpdateCheckDate,formatIn)
			% the current date is at least a day past the last update check
			updateCheck = 1;
			fprintf(fileID, '%s', currentDate);
		else
			updateCheck = 0;
			fprintf(fileID, '%s', lastUpdateCheckDate);
		end
	end
	fclose(fileID);
	%
	if updateCheck
		fileID = fopen([projectFolderPath,'/versionNumber.txt'],'r');
		currentVersionString = fscanf(fileID,'%s');
		if currentVersionString(1)=='v'
			% remove the 'v' from the beginning if there is one
			currentVersionString = currentVersionString(2:end);
		end
		% get the current version
		fclose(fileID);
		%
		downloadedVersionString = '0';
		latestVersions = dir([projectFolderPath,'/Updates/Latest_Version']);
		% get all files and folders in the directory
		%
		for updateFolder=1:size(latestVersions,1)
			% loop through all files and folders in the 'Latest_Version' directory 
			if latestVersions(updateFolder).isdir&&strcmp(latestVersions(updateFolder).name,'.')==0&&strcmp(latestVersions(updateFolder).name,'..')==0
				% if the current object is a folder and not '.' OR '..'
				if exist([projectFolderPath,'/Updates/Latest_Version/',latestVersions(updateFolder).name,'/versionNumber.txt'],'file')
					% if the version number file exists in the folder
					fileID = fopen([projectFolderPath,'/Updates/Latest_Version/',latestVersions(updateFolder).name,'/versionNumber.txt'],'r');
					downloadedVersionString = fscanf(fileID,'%s');
					if downloadedVersionString(1)=='v'
						% remove the 'v' from the beginning if there is one
						downloadedVersionString = downloadedVersionString(2:end);
					end
					fclose(fileID);
				end
			end
		end
		%
		if cmpVersions(currentVersionString,downloadedVersionString)==1
			% check if the downloaded version is greater than the current
			% version
			% this is to make sure that the downloaded version will not be
			% re-downloaded if the user hasn't updated their version yet
			greatestVersionString = currentVersionString;
		else
			greatestVersionString = downloadedVersionString;
		end
		%
		updatesFigure = checkingForUpdatesGUI;
		% show a GUI so that the user knows the program is checking for
		% updates
		[updateAvailable,latestVersionString,latestVersionTagName,...
			latestVersionMessage,latestVersionDownload]...
			= checkForGitHubUpdates(greatestVersionString, username, repo);
		% this function actually checks GitHub for the latest version
		close(updatesFigure);
		% close the updates figure
		if updateAvailable==-1
			% there was an error while checking for updates
			disp 'Could not check for updates (connection to server timed out or GitHub API limit reached).';
		end
		if updateAvailable==0
			if cmpVersions(downloadedVersionString,currentVersionString)==1
				msgbox('You have downloaded the latest version, but haven''t installed it yet. You are currently running an old version.','','warn')
			end
		end
		if updateAvailable==1
			% if there is an update available
			updatesFigure = downloadingUpdateGUI;
			% show a GUI so that the user knows the program is downloading
			% updates
			if exist([projectFolderPath,'/Updates/Latest_Version'],'dir')
				% remove any existing versions
				rmdir([projectFolderPath,'/Updates/Latest_Version'], 's');
			end
			newVersionFiles = unzip(latestVersionDownload,[projectFolderPath,'/Updates/Latest_Version']);
			% download the latest version from the server and unzip it
			newVersionPath = '';
			for a=1:size(newVersionFiles,2)
				locations = findstr(newVersionFiles{a},'README.md');
				% the location of the new folder will be where the README
				% file is
				if size(locations,2)~=0
					directoryLocationsInString = [strfind(newVersionFiles{a},'\'),strfind(newVersionFiles{a},'/')];
					parentDirectoryIndex = max(directoryLocationsInString);
					newVersionPath = newVersionFiles{a}(1:parentDirectoryIndex-1);
					% get the path to the downloaded folder
				end
			end
			if strcmp(newVersionPath,'')
				error('A README file was not found in the repo, cannot update without it.');
			end
			fileID = fopen([newVersionPath,'/versionNumber.txt'],'w');
			fprintf(fileID,'%s',latestVersionString);
			% write the latest version to the downloaded folder because the
			% version number might not have been downloaded with the ZIP
			fclose(fileID);
			close(updatesFigure);
			%
			updatesFigure = updateMessageGUI;
			handles = allchild(updatesFigure);
			hMessageText = findobj(handles,'Tag','message');
			messageText = {...
				[...
				'The latest version ('...
				latestVersionString...
				') has been downloaded and is stored in the folder "'...
				'/Updates/Latest_Version'...
				'". Please copy these files to the main program folder to complete the update.'...
				]...
				''...
				'Release Notes:'...
				''...
				latestVersionMessage...
				};
			set(hMessageText, 'String', messageText);
			%close(updatesFigure);
		end
	end
	%
end