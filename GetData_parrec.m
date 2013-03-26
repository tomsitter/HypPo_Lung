function [MR_data,parms,dims] = GetData_parrec(parfile,output_format,info)
% Reads Philips PAR/REC files 
% Syntax: [MR_data,parms,dims] = GetData_parrec(filename,output_format,info);
% Modified by Iain Ball
% Inputs:
%           If no inputs, via UI, select name of PAR file
%           ASSUMES the REC file in the SAME FOLDER as the PAR file
%           output is then SV
%           With inputs:
%                       filename = filename (with path) of PAR file
%                       output_format = data output type - FP, DV, SV (default)
%                       info = if exists, prints information to command window
%
% Outputs: MR_data: matrix of the images (as SV values, by default)
%          parms: structure containing PAR file info
%          dims: [stride nline nslice necho nphase ntype ndyn]
%
% Can process both V3 and V4 (V4.1 and V4.2) types of PAR files automatically
%=============================================================================================================================================

%% *CHECK INPUT*
if nargin < 2
    output_format = 'SV';                                                  % format of outputed images: can be 'FP', 'DV' or 'SV (default)'
end

%% *CHECK FOR VALID FORMATS*
if ~(strcmp(output_format,'FP') || strcmp(output_format,'DV') || strcmp(output_format,'SV'))
    error('Format needs to be one of: FP, DV, SV (default)');
end

if nargin < 1
    [fname,pname] = uigetfile('*.PAR','Select *.PAR file');
    parfile=[pname fname];
end

tic;
[parms,ver] = read_parfile(parfile);
[MR_data,dims] = read_recfile([parfile(1:(end-4)) '.REC'],parms,ver,output_format);

if nargin > 2
    
    fprintf('This is a %s PAR file\n',ver)
    fprintf('Output of images is in %s format\n',output_format);
    fprintf('Read %d images of size [%d x %d]\n',prod(dims(3:end)),dims(1:2));
    fprintf('# slices: %d, # echoes: %d, # phases: %d, # types: %d, # dynamics: %d\n',dims(3:end));
    disp(['Total execution time = ' num2str(toc)]);
    
end

return;

%=============================================================================================================================================

function [parms,ver] = read_parfile(filename)

%% *READ ALL LINES OF THE PAR FILE*
nlines  = 0;                                                               % initialise number of lines
fid = fopen(filename,'r');                                                 % read file

if (fid < 1)
    error(['.PAR file ', filename, ' not found.']);
end

while ~feof(fid)                                                           % feof tests for end of file - whilst not EOF.
    curline = fgetl(fid);                                                  % current line - fget1 removes newline \n character 
%     curline = fgets(fid);                                                % fgets keeps newline characters resulting in more lines  
    if ~isempty(curline)                                                   % if current line not empty then... 
        nlines = nlines + 1;                                               % increase loop counter
        lines(nlines) = cellstr(curline);                                  % allows variable line size - doesn't matter if fgetl or fgets
    end
end
fclose(fid);

%% *IDENTIFY HEADER FILE LINES*
NG = 0;

for L = 1:size(lines,2)
    curline = char(lines(L));
    if (size(curline,2) > 0 && curline(1) == '.')                          % character strings of length greater than 0 and with . at 
       NG = NG + 1;                                                        % start are identified as a header line and stored in cell array
       geninfo(NG) = lines(L);                                             % geninfo - i.e GENERAL INFORMATION section of PAR file. 
    end
end

if (NG < 1)
    error('.PAR file has invalid format');
end

%% *FIGURE OUT IF v3 OR v4 PAR FILES*
test_key = '.    Image pixel size [8 or 16 bits]    :';                    % only V3 has that key in the headers

if strcmp(test_key,geninfo);
    ver = 'V3';
    template = get_template_v3;
else
    ver = 'V4.2';
    template = get_template_v42;                                           % even if .PAR file is v4.1 code will still work but will have
end;                                                                       % empty fields in parms structure

%% *PARSE HEADER INFORMATION*
for S = 1:size(template,1)
    line_key = char(template(S,1));                                        % e.g. EPI Factor
    value_type = char(template(S,2));                                      % e.g. int  scalar
    field_name = char(template(S,3));                                      % e.g. epi_factor
    L = strncmp(line_key,geninfo,size(line_key,2));                        % strncmp returns index of line_key within geninfo
%     L = strmatch(line_key,geninfo);  
    
    if ~isempty(L)
        curline = char(geninfo(L));
        value_start = 1 + strfind(curline,':');                            % find index of : within curline and start 1 after it 
        value_end = size(curline,2);
    else
        value_type = ':-( VALUE NOT FOUND )-:';                            % allows code to still run even if nothing is found...this is a 
    end                                                                    % redundancy should v4.1 .PAR files be loaded

    switch (value_type)                                                    % parse header with field_names taking value_type into account
    case { 'float scalar' 'int   scalar' 'float vector' 'int   vector'}    % floats are multiple number fields or parameters that need the decimal place.
         parms.(field_name) = str2num(curline(value_start:value_end));
    case { 'char  scalar' 'char  vector' }
         parms.(field_name) = strtrim(curline(value_start:value_end));     % justify string and trim any whitespace/null characters
    otherwise
         parms.(field_name) = '';
    end

end

%% *PARSE THE TAGS FOR EACH LINE OF DATA*
nimg  = 0;

for L = 1:size(lines,2)
    curline = char(lines(L));                                                     % read lines in one at a time
    firstc = curline(1);                                                          % identify 1st character of each line                                                   
    if (size(curline,2) > 0 && firstc ~= '.' && firstc ~= '#' && firstc ~= '*')   % conditions for tag parsing
       nimg = nimg + 1;
       parms.tags(nimg,:) = str2num(curline);                                     % parms.tags is nimgx49 row of data
    end
end

if (isfield(parms,'recon_resolution'))                                     % if upsampled then need to know this parameter in order to read .REC file correctly
    nline = parms.recon_resolution(1);                                     % the field recon_resolution is unique to v3 PAR files.
    stride = parms.recon_resolution(2);
else
    nline = parms.tags(1,10);                                              % nline and stride are essentially the number of samples and views unless upsampled
    stride = parms.tags(1,11);                                             % these values are used to specify the interimage spacing within the .REC file 
end

slice_orientation = parms.tags(1,26);                                      % TRANSVERSE = 1, SAGITTAL = 2, CORONAL = 3
                                                                           % assumes same for all images - localiser scans won't work!
switch (slice_orientation)
    case { 1 }, parms.slice_orientation = 'TRANSVERSE';
    case { 2 }, parms.slice_orientation = 'SAGITTAL';
    case { 3 }, parms.slice_orientation = 'CORONAL';
    otherwise
        error('Unknown oblique orientation')
end

% if parms.max_slices == parms.fov(1)/parms.slice_thickness
%     parms.slice_orientation = 'CORONAL';
% elseif parms.max_slices == parms.fov(2)/parms.slice_thickness            % less efficient way!                    !
%     parms.slice_orientation = 'TRANSVERSE';
% else
%     parms.slice_orientation = 'SAGITTAL';
% end

parms.reconstruction_res = [nline stride];                                         % reconstruction resolution
parms.image_types = unique(parms.tags(:,5)');                                      % image types
parms.slice_thickness = unique(parms.tags(:,23));                                  % (mm)
parms.slice_gap = unique(parms.tags(:,24));                                        % (mm)
parms.b_factor = unique(parms.tags(:,34));                                         % b-factors
parms.b_factor_number = unique(parms.tags(:,42));                                  % number of diffusion b-factors/weightings                             
parms.echo_time = unique(parms.tags(:,31));                                        % TE (ms)
parms.num_averages = unique(parms.tags(:,35));                                     % number of signal averages            
parms.flip_angle = unique(parms.tags(:,36));                                       % flip angle
parms.turbo_factor = unique(parms.tags(:,40));                                     % turbo factor 
parms.receiver_bandwidth = 0.22*parms.scan_resolution(1)/parms.water_fat_shift;    % +/- bandwidth in kHz - 0.22 scaling for 3T - 0.11 for 1.5T

if (nimg < 1)
    error('Missing scan information in .PAR file') 
end

return

%=============================================================================================================================================

function [image_data,dims] = read_recfile(recfile_name,parms,ver,output_format)

%% *MATCH TAGS TO IMAGE INFORMATION*
types_list = unique(parms.tags(:,5)');              % handles multiple image types - 0,1,2,3 - mag, real, imag, phase - unique avoids repetitions
scan_tag_size = size(parms.tags);
nimg = scan_tag_size(1);                            % number of images does not always equal number slices - may have numerous image types per slice
nslice = parms.max_slices;                          % number of slices 
nphase = parms.max_card_phases;                     % number of cardiac phases
necho = parms.max_echoes;                           % number of echoes
ndyn = parms.max_dynamics;                          % number of dynamics
ntype = size(types_list,2);                         % number of image types

if (isfield(parms,'recon_resolution'))              
    nline = parms.recon_resolution(1);                                     % same code as previously written needed for execution of nested read_recfile function        
    stride = parms.recon_resolution(2);                                    % nline*stride used for error catching and interimage spacing specifications
else
    nline = parms.tags(1,10);                       
    stride = parms.tags(1,11);                       
end

switch(ver)
    case {'V3'}, pixel_bits = parms.pixel_bits;
    case {'V4.2'}, pixel_bits = parms.tags(1,8);                           % assume same for all images - 16 bit unsigned integers
end

switch (pixel_bits)
    case { 8 },  read_type = 'uint8';
    case { 16 }, read_type = 'short';                                      % default for short is 16 or could just write uint16                    
    otherwise,   read_type = 'uchar';
end

%% *READ .REC FILE*
fid = fopen(recfile_name,'r','l');                                                 % read bits in file with little endian ordering
[binary_1D,read_size] = fread(fid,inf,read_type);                                  % read everything (inf) as read_type
fclose(fid);

if (read_size ~= nimg*nline*stride)
    fprintf('Expected %d int.  Found %d int\n',nimg*nline*stride,read_size);       % error catching - this section of code is now redundant  
    if (read_size > nimg*nline*stride)
        error('.REC file has more data than expected from .PAR file')
    else
        error('.REC file has less data than expected from .PAR file')
    end
else
    fprintf('%s\n','.REC file read sucessfully');
end

%% *GENERATE MATRIX OF IMAGES*
dims = [stride nline nslice necho nphase ntype ndyn];                         % dimensions of image
image_data = zeros(dims);

for I  = 1:nimg
    slice = parms.tags(I,1);
    echo = parms.tags(I,2);
    dyn = parms.tags(I,3);
    phase = parms.tags(I,4);
    type = parms.tags(I,5);                                                   % 0,1,2,3
    type_idx = types_list == type;                                            % images to be displayed slice 1, type 0, slice 1 type 1 etc
    seq = parms.tags(I,6);                                                    % scanning sequence number
    rec = parms.tags(I,7);                                                    % index in .REC file          

    start_image = 1+rec*nline*stride;                                         % need the 1 because rec index starts at zero!
    end_image = start_image + stride*nline - 1;                               % now need to subtract the 1!
    img = reshape(binary_1D(start_image:end_image),stride,nline);             % reshape 1D matrix into 2D matrix 

    %% *RESCALE DATA TO PRODUCE SV INFORMATION (not FP, not DV)*
    img = permute(rescale_rec(img,parms.tags(I,:),ver,output_format), [2 1]); % permute matrix otherwise image rotated 90 degs
    image_data(:,:,slice,echo,phase,type_idx,dyn) = img;
end
return;
    
%=============================================================================================================================================

function img = rescale_rec(img,tag,ver,output_format)

%% *TRANSFORMS SV DATA IN REC FILES TO SV, DV OR FP DATA FOR OUTPUT*
switch( ver )
    case { 'V3' }, ri_i = 8; rs_i = 9; ss_i = 10;
    case { 'V4.2' }, ri_i = 12; rs_i = 13; ss_i = 14;   % recon resolution is one field but occupies two cells resulting in index being 12 instead of 11
end;
 
RI = tag(ri_i);                                                  % Rescale Intercept
RS = tag(rs_i);                                                  % Rescale Slope
SS = tag(ss_i);                                                  % Scale Slope

switch (output_format)
    case { 'FP' }, img = (RS*img + RI)./(RS*SS);
    case { 'DV' }, img = (RS*img + RI);
    case { 'SV' }, img = img;
end

return;

%=============================================================================================================================================
%% *PAR FILE VERSION TEMPLATES*

function [template] = get_template_v3                                    % header information for V3 PAR files

template = { ...                                  
'.    Patient name                       :'    'char  scalar'    'patient';    ...   
'.    Examination name                   :'    'char  scalar'    'exam_name';   ... 
'.    Protocol name                      :'    'char  vector'    'protocol';   ... 
'.    Examination date/time              :'    'char  vector'    'exam_date';  ...
'.    Acquisition nr                     :'    'int   scalar'    'acq_nr';    ...
'.    Reconstruction nr                  :'    'int   scalar'    'recon_nr';  ...
'.    Scan Duration [sec]                :'    'float scalar'    'scan_dur';        ...
'.    Max. number of cardiac phases      :'    'int   scalar'    'max_card_phases'; ...
'.    Max. number of echoes              :'    'int   scalar'    'max_echoes'; ...
'.    Max. number of slices/locations    :'    'int   scalar'    'max_slices'; ... 
'.    Max. number of dynamics            :'    'int   scalar'    'max_dynamics'; ... 
'.    Max. number of mixes               :'    'int   scalar'    'max_mixes'; ... 
'.    Image pixel size [8 or 16 bits]    :'    'int   scalar'    'pixel_bits'; ... 
'.    Technique                          :'    'char  scalar'    'technique'; ...  
'.    Scan mode                          :'    'char  scalar'    'scan_mode'; ... 
'.    Scan resolution  (x, y)            :'    'int   vector'    'scan_resolution'; ... 
'.    Scan percentage                    :'    'int   scalar'    'scan_percentage'; ... 
'.    Recon resolution (x, y)            :'    'int   vector'    'recon_resolution'; ... 
'.    Number of averages                 :'    'int   scalar'    'num_averages'; ... 
'.    Repetition time [msec]             :'    'float scalar'    'repetition_time'; ...   
'.    FOV (ap,fh,rl) [mm]                :'    'float vector'    'fov'; ... 
'.    Slice thickness [mm]               :'    'float scalar'    'slice_thickness'; ...
'.    Slice gap [mm]                     :'    'float scalar'    'slice_gap'; ... 
'.    Water Fat shift [pixels]           :'    'float scalar'    'water_fat_shift'; ... 
'.    Angulation midslice(ap,fh,rl)[degr]:'    'float vector'    'angulation'; ...
'.    Off Centre midslice(ap,fh,rl) [mm] :'    'float vector'    'offcenter'; ... 
'.    Flow compensation <0=no 1=yes> ?   :'    'int   scalar'    'flowcomp'; ...
'.    Presaturation     <0=no 1=yes> ?   :'    'int   scalar'    'presaturation';... 
'.    Cardiac frequency                  :'    'int   scalar'    'card_frequency'; ...
'.    Min. RR interval                   :'    'int   scalar'    'min_rr_interval'; ...
'.    Max. RR interval                   :'    'int   scalar'    'max_rr_interval'; ...
'.    Phase encoding velocity [cm/sec]   :'    'float vector'    'venc'; ... 
'.    MTC               <0=no 1=yes> ?   :'    'int   scalar'    'mtc'; ...
'.    SPIR              <0=no 1=yes> ?   :'    'int   scalar'    'spir'; ...
'.    EPI factor        <0,1=no EPI>     :'    'int   scalar'    'epi_factor'; ...
'.    TURBO factor      <0=no turbo>     :'    'int   scalar'    'turbo_factor'; ...
'.    Dynamic scan      <0=no 1=yes> ?   :'    'int   scalar'    'dynamic_scan'; ...
'.    Diffusion         <0=no 1=yes> ?   :'    'int   scalar'    'diffusion'; ...
'.    Diffusion echo time [ms]           :'    'float scalar'    'diffusion_echo_time'; ...
'.    Inversion delay [ms]               :'    'float scalar'    'inversion_delay'; ...
};

return;

%=============================================================================================================================================

function [template] = get_template_v41                                         % header information for V4 PAR files

template = { ...                                  
'.    Patient name                       :' 'char  scalar' 'patient';    ...   
'.    Examination name                   :' 'char  vector' 'exam_name';   ... 
'.    Protocol name                      :' 'char  vector' 'protocol';   ... 
'.    Examination date/time              :' 'char  vector' 'exam_date';  ...
'.    Series Type                        :' 'char  vector' 'series_type';  ...
'.    Acquisition nr                     :' 'int   scalar' 'acq_nr';    ...
'.    Reconstruction nr                  :' 'int   scalar' 'recon_nr';  ...
'.    Scan Duration [sec]                :' 'float scalar' 'scan_dur';        ...
'.    Max. number of cardiac phases      :' 'int   scalar' 'max_card_phases'; ...
'.    Max. number of echoes              :' 'int   scalar' 'max_echoes'; ...
'.    Max. number of slices/locations    :' 'int   scalar' 'max_slices'; ... 
'.    Max. number of dynamics            :' 'int   scalar' 'max_dynamics'; ... 
'.    Max. number of mixes               :' 'int   scalar' 'max_mixes'; ... 
'.    Patient position                   :' 'char  vector' 'patient_position'; ... 
'.    Preparation direction              :' 'char  vector' 'preparation_dir'; ... 
'.    Technique                          :' 'char  scalar' 'technique'; ...  
'.    Scan resolution  (x, y)            :' 'int   vector' 'scan_resolution'; ... 
'.    Scan mode                          :' 'char  scalar' 'scan_mode'; ... 
'.    Repetition time [ms]               :' 'float scalar' 'repetition_time'; ...   
'.    FOV (ap,fh,rl) [mm]                :' 'float vector' 'fov'; ... 
'.    Water Fat shift [pixels]           :' 'float scalar' 'water_fat_shift'; ... 
'.    Angulation midslice(ap,fh,rl)[degr]:' 'float vector' 'angulation'; ...
'.    Off Centre midslice(ap,fh,rl) [mm] :' 'float vector' 'offcenter'; ... 
'.    Flow compensation <0=no 1=yes> ?   :' 'int   scalar' 'flowcomp'; ...
'.    Presaturation     <0=no 1=yes> ?   :' 'int   scalar' 'presaturation';... 
'.    Phase encoding velocity [cm/sec]   :' 'float vector' 'venc'; ... 
'.    MTC               <0=no 1=yes> ?   :' 'int   scalar' 'mtc'; ...
'.    SPIR              <0=no 1=yes> ?   :' 'int   scalar' 'spir'; ...
'.    EPI factor        <0,1=no EPI>     :' 'int   scalar' 'epi_factor'; ...
'.    Dynamic scan      <0=no 1=yes> ?   :' 'int   scalar' 'dynamic_scan'; ...
'.    Diffusion         <0=no 1=yes> ?   :' 'int   scalar' 'diffusion'; ...
'.    Diffusion echo time [ms]           :' 'float scalar' 'diffusion_echo_time'; ...
};

return;

%=============================================================================================================================================

function [template] = get_template_v42                                            % header information for V4.2 PAR files

template = { ...                                  
'.    Patient name                       :' 'char  scalar' 'patient';    ...   
'.    Examination name                   :' 'char  vector' 'exam_name';   ... 
'.    Protocol name                      :' 'char  vector' 'protocol';   ... 
'.    Examination date/time              :' 'char  vector' 'exam_date';  ...
'.    Series Type                        :' 'char  vector' 'series_type';  ...
'.    Acquisition nr                     :' 'int   scalar' 'acq_nr';    ...
'.    Reconstruction nr                  :' 'int   scalar' 'recon_nr';  ...
'.    Scan Duration [sec]                :' 'float scalar' 'scan_dur';        ...
'.    Max. number of cardiac phases      :' 'int   scalar' 'max_card_phases'; ...
'.    Max. number of echoes              :' 'int   scalar' 'max_echoes'; ...
'.    Max. number of slices/locations    :' 'int   scalar' 'max_slices'; ... 
'.    Max. number of dynamics            :' 'int   scalar' 'max_dynamics'; ... 
'.    Max. number of mixes               :' 'int   scalar' 'max_mixes'; ... 
'.    Patient position                   :' 'char  vector' 'patient_position'; ... 
'.    Preparation direction              :' 'char  vector' 'preparation_dir'; ... 
'.    Technique                          :' 'char  scalar' 'technique'; ...  
'.    Scan resolution  (x, y)            :' 'int   vector' 'scan_resolution'; ... 
'.    Scan mode                          :' 'char  scalar' 'scan_mode'; ... 
'.    Repetition time [ms]               :' 'float scalar' 'repetition_time'; ...   
'.    FOV (ap,fh,rl) [mm]                :' 'float vector' 'fov'; ... 
'.    Water Fat shift [pixels]           :' 'float scalar' 'water_fat_shift'; ... 
'.    Angulation midslice(ap,fh,rl)[degr]:' 'float vector' 'angulation'; ...
'.    Off Centre midslice(ap,fh,rl) [mm] :' 'float vector' 'offcenter'; ... 
'.    Flow compensation <0=no 1=yes> ?   :' 'int   scalar' 'flowcomp'; ...
'.    Presaturation     <0=no 1=yes> ?   :' 'int   scalar' 'presaturation';... 
'.    Phase encoding velocity [cm/sec]   :' 'float vector' 'venc'; ... 
'.    MTC               <0=no 1=yes> ?   :' 'int   scalar' 'mtc'; ...
'.    SPIR              <0=no 1=yes> ?   :' 'int   scalar' 'spir'; ...
'.    EPI factor        <0,1=no EPI>     :' 'int   scalar' 'epi_factor'; ...
'.    Dynamic scan      <0=no 1=yes> ?   :' 'int   scalar' 'dynamic_scan'; ...
'.    Diffusion         <0=no 1=yes> ?   :' 'int   scalar' 'diffusion'; ...
'.    Diffusion echo time [ms]           :' 'float scalar' 'diffusion_echo_time'; ...
'.    Max. number of diffusion values    :' 'int   scalar' 'num_diffusion'; ...
'.    Max. number of gradient orients    :' 'int   scalar' 'num_orients'; ...
'.    Number of label types   <0=no ASL> :' 'int   vector' 'num_label_types';...
};

return;
%=============================================================================================================================================
