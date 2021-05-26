function [ephm info units] = getrinexephGal(varargin)
% [ephm info units] = getrinexeph(vargargin)
%
% Reads RINEX navigation file for Galileo and reformats
% the ephemerides (ephm) into a matrix with 32=4x8 rows
% for each satellite (column).
% 'info' contains a name (string) for each row
% 'units' contrains the corresponding unit
%
% Options:
%
% [myeph,info] = getrinexeph('filename.*n')
%                  o opens filename*.n
% [myeph,info] = getrinexeph()
%                  o prompt for an input file appears

% $Jan Skaloud
% $Revision 1.0 $  $Date: 2013-02-07  $
%
% adapted from getrinexph $Date: 2019-02-19$ by Lea B.


%% Open file
fid = [];

if nargin >0
    fid = fopen(varargin{1}) ;
end

if nargin <1 || fid <= 0,
    [filename, pathname, filterindex] = uigetfile( ...
       {'*.*', 'GPS ephemerides in Rinex  (*n)';
         '*.*',  'All Files (*.*)'}, ...
        'Pick a file');
    fn = sprintf('%s\%s',pathname,filename);
    fid = fopen(filename, 'r');
    if fid <= 0,
        error('Cannot open input file');
    end
end

%% Skip header
hdr_ln = 0;
while 1
   hdr_ln = hdr_ln+1;
   ln = fgetl(fid);
   is_leapsec = strfind(ln,'LEAP SECONDS');
   if ~isempty(is_leapsec)
       leapsec = str2double(ln(1:6));
   end
   is_end = strfind(ln,'END OF HEADER');
   if ~isempty(is_end), break;  end;
end;
msg = sprintf('Leap seconds: %d', leapsec); disp(msg);

%% Count lines/ephm in file
disp('Counting ephemerides ...');
noeph = -1;
while 1
   noeph = noeph+1;
   ln = fgetl(fid);
   if ln == -1, break;  end
end;
if mod(noeph,8), warning('Ephemerides incomplete or file corrupted!'); end
noeph = noeph/8;
frewind(fid);

%% Read ephemerides
disp('Reading ephemerides ...')
for i = 1:hdr_ln, ln = fgetl(fid); end; % skips header
ephm = zeros(32,noeph); % allocates memory for all
e = zeros(32,1);  % allocates memory for one sv
info = {'prn';  'af0';   'af1';    'af2'; ...
        'iodnav'; 'crs';   'deltan'; 'm0'; ...
        'cuc';  'ecc';   'cus';    'sqrta'; ...
        'toe';  'cic';   'omega0'; 'cis'; ...
        'i0';   'crc';   'omega';  'omegadot'; ...
        'idot'; 'source'; 'week';   'spare'; ...
        'svstd';'svok';  'bgda';    'bgdb'; ...
        %'tom';  'fitint';'spare1'; 'spare2'};
        'tom';  'fitint';'spare1'; 'toc'};
units ={'#';    's';     's/s';    's/s/s'; ...
        '#';    'm';     'rad/s';  'rad'; ...
        's';    'rad';   'rad';    'rad'; ...
        'rad';  'm';     'rad';    'rad/s'; ...
        'rad/s';'flag';  '#';      'NaN'; ...
        'm';    'bits';  's';      's'; ...
        %'s';    'NaN';  'NaN';    'NaN' };
        's';    'NaN';  'NaN';    's' };

for i = 1:noeph
   ln = fgetl(fid);     % -- LINE 1 --
   ln = strtrim(strrep(ln,'D','e'));
   ln = strsplit(ln);
   e(0+1) = str2double(strrep(ln{1},'E',''));    % 'prn'
   year   = ln{2};
   month  = ln{3};
   day    = ln{4};
   hour   = ln{5};
   minute = ln{6};
   second = ln{7};
   e(0+2) = str2double(ln{8});  % 'af0'
   e(0+3) = str2double(ln{9});  % 'af1'
   e(0+4) = str2double(ln{10});  % 'af2'
   ln = fgetl(fid);     % -- LINE 2 --
   ln = strtrim(strrep(ln,'D','e'));
   ln = strsplit(ln);
   e(4+1)  = str2double(ln{1});  % 'iode'
   e(4+2)  = str2double(ln{2}); % 'crs'
   e(4+3)  = str2double(ln{3}); % 'deltan' 7
   e(4+4)  = str2double(ln{4}); % 'm0'     8
   ln = fgetl(fid);	    % -- LINE 3 --
   ln = strtrim(strrep(ln,'D','e'));
   ln = strsplit(ln);
   e(8+1)  = str2double(ln{1});  % 'cuc'
   e(8+2)  = str2double(ln{2}); % 'ecc'
   e(8+3)  = str2double(ln{3}); % 'cus'
   e(8+4)  = str2double(ln{4}); % 'sqrta' 12
   ln = fgetl(fid);     % -- LINE 4 ---
   ln = strtrim(strrep(ln,'D','e'));
   ln = strsplit(ln);
   e(12+1) = str2double(ln{1});  % 'toe'   13
   e(12+2) = str2double(ln{2}); % 'cic'
   e(12+3) = str2double(ln{3}); % 'omega0'
   e(12+4) = str2double(ln{4}); % 'cis'
   ln = fgetl(fid);     % -- LINE 5 --
   ln = strtrim(strrep(ln,'D','e'));
   ln = strsplit(ln);
   e(16+1) =  str2double(ln{1}); % 'i0'
   e(16+2) = str2double(ln{2}); % 'crc'
   e(16+3) = str2double(ln{3}); % 'omega'
   e(16+4) = str2double(ln{4}); % 'omegadot'
   ln = fgetl(fid);	    % -- LINE 6 --
   ln = strtrim(strrep(ln,'D','e'));
   ln = strsplit(ln);
   e(20+1) = str2double(ln{1});  % 'idot'
   e(20+2) = str2double(ln{2}); % 'codes'
   e(20+3) = str2double(ln{3}); % 'week'
   if length(ln) > 3
    e(20+4) = str2double(ln{4}); % 'spare'
   end
   ln = fgetl(fid);	    % -- LINE 7 --
   ln = strtrim(strrep(ln,'D','e'));
   ln = strsplit(ln);
   e(24+1) = str2double(ln{1});  % 'svstd'
   e(24+2) = str2double(ln{2}); % 'svok'
   e(24+3) = str2double(ln{3}); % 'bgda'
   e(24+4) = str2double(ln{4}); % 'bgdb'
   ln = fgetl(fid);	    % -- LINE 8 --
   ln = strtrim(strrep(ln,'D','e'));
   ln = strsplit(ln);
   e(28+1) = str2double(ln{1});  % 'tom'
   if length(ln) > 1
    e(28+2) = str2double(ln{2}); % 'spare1'
    e(28+3) = str2double(ln{3}); % 'spare2'
   end
   % add 'toc' in sow (sec of week) instead of 'spare3'
   % e(28+4) = str2double(ln(61:79)); % 'spare2'
   dow = floor(e(12+1)/(24*3600));              %  day of week
   clock_tod = str2double(hour)*3600 + str2double(minute)*60 ...
              + str2double(second);  % time of day
   clock_tow = clock_tod + (24*3600)*dow;       % time of week
   e(28+4) = clock_tow;              % 'toc'
   ephm(:,i) = e(:,1);
   e = e.*0;
end

%% Terminate
msg = sprintf('No of ephmerides read: %d', noeph);
disp(msg);
fclose(fid);
