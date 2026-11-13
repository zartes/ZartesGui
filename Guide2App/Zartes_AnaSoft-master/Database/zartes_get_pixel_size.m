function info = zartes_get_pixel_size(device_name, varargin)
% ZARTES_GET_PIXEL_SIZE  Get TES geometry from the design (series+chip+pixel),
%                        WITHOUT requiring the device/wafer to exist in the DB.
%
%   info = zartes_get_pixel_size(device_name)
%   info = zartes_get_pixel_size(device_name, 'host','192.168.1.10', ...)
%   info = zartes_get_pixel_size(device_name, opts_struct)
%
%   Use this instead of zartes_get_device when:
%     - Measuring a new wafer for the first time (pixels not yet in DB)
%     - Building the Init JSON before registering measurements
%
%   The wafer run number is ignored: '4Z6_62_14' and '4Z2_62_14' return
%   the same TES design (XIFU-8, 40x80 �m) because it depends only on
%   series=4Z, chip_code=62, pixel=14.
%
%   INPUT
%     device_name : string or cell array, e.g. '4Z6_62_14'
%                   or {'4Z6_62_14', '3Z10_44_14', '5Z1_37_31'}
%     Optional name-value pairs (or struct):
%       'host'     DB hostname/IP  (default same as zartes_db_query.py)
%       'dbname'   database name   (default 'zartesdb')
%       'user'     DB user
%       'password' DB password
%       'python'   python executable (default 'python')
%       'script'   path to zartes_get_pixel_size.py (auto-detected)
%
%   OUTPUT
%     info : struct array, one per device:
%       .device_name   input name (e.g. '4Z6_62_14')
%       .found         true/false
%       .series        '4Z'
%       .chip_code     62
%       .pixel_code    14
%       .nickname      chip nickname e.g. 'XIFU-8'
%       .size          '40x80'
%       .tes_width_um
%       .tes_length_um
%       .abs_width_um
%       .stem_type
%       .has_membrane  0 or 1
%       .has_absorber  0 or 1
%
%   EXAMPLE
%     % New wafer 4Z6 not yet in DB — still works:
%     info = zartes_get_pixel_size('4Z6_62_14');
%     fprintf('%s → %s (%s)\n', info.device_name, info.size, info.nickname);

% Parse options
p = inputParser();
p.addParameter('host',     '',             @ischar);
p.addParameter('dbname',   'zartesdb',     @ischar);
p.addParameter('user',     'invitado',     @ischar);
p.addParameter('password', 'invitado',     @ischar);
p.addParameter('python',   'python',       @ischar);
p.addParameter('script',   '',             @ischar);

if numel(varargin) == 1 && isstruct(varargin{1})
    s = varargin{1};
    args = {};
    flds = fieldnames(s);
    for k = 1:numel(flds)
        args = [args, {flds{k}, s.(flds{k})}]; %#ok<AGROW>
    end
    p.parse(args{:});
else
    p.parse(varargin{:});
end
opts = p.Results;

% Normalise device list 
if iscell(device_name)
    devices = device_name;
elseif ischar(device_name)
    devices = {device_name};
else
    devices = cellstr(device_name);
end

% Locate Python script
if isempty(opts.script)
    this_dir  = fileparts(mfilename('fullpath'));
    py_script = fullfile(this_dir, '..', 'python', 'zartes_get_pixel_size.py');
    py_script = char(py_script);
else
    py_script = opts.script;
end

if exist(py_script, 'file') ~= 2
    error('zartes_get_pixel_size:scriptNotFound', ...
          'Cannot find zartes_get_pixel_size.py at: %s', py_script);
end

% Build and run command
device_args = strjoin(cellfun(@(d) ['"' d '"'], devices, ...
                              'UniformOutput', false), ' ');
cmd = sprintf('%s "%s" %s', opts.python, py_script, device_args);

[status, result] = system(cmd);
if status ~= 0
    error('zartes_get_pixel_size:queryFailed', ...
          'Python query failed (exit %d):\n%s', status, result);
end

% Decode JSON
json_str = strtrim(result);

if exist('jsondecode', 'builtin') || exist('jsondecode', 'file')
    raw = jsondecode(json_str);
    if isstruct(raw)
        raw = arrayfun(@(x) x, raw, 'UniformOutput', false);
    end
elseif exist('loadjson', 'file')
    raw = loadjson(json_str);
    if ~iscell(raw), raw = {raw}; end
else
    error('zartes_get_pixel_size:noDecoder', ...
          'No JSON decoder found. Requires MATLAB R2016b+ or JSONlab.');
end

if numel(raw) == 1 && isstruct(raw{1}) && isfield(raw{1}, 'error') && ~isfield(raw{1}, 'found')
    error('zartes_get_pixel_size:dbError', 'DB error: %s', raw{1}.error);
end

% Build output struct
info = struct();
for k = 1:numel(raw)
    r = raw{k};
    info(k).device_name   = zs_str(r, 'device_name');
    info(k).found         = logical(zs_num(r, 'found'));
    info(k).series        = zs_str(r, 'series');
    info(k).chip_code     = zs_num(r, 'chip_code');
    info(k).pixel_code    = zs_num(r, 'pixel_code');
    info(k).nickname      = zs_str(r, 'nickname');
    info(k).size          = zs_str(r, 'size');
    info(k).tes_width_um  = zs_num(r, 'tes_width_um');
    info(k).tes_length_um = zs_num(r, 'tes_length_um');
    info(k).abs_width_um  = zs_num(r, 'abs_width_um');
    info(k).stem_type     = zs_str(r, 'stem_type');
    info(k).has_membrane  = zs_num(r, 'has_membrane');
    info(k).has_absorber  = zs_num(r, 'has_absorber');

    if ~info(k).found
        msg = zs_str(r, 'error');
        if isempty(msg), msg = info(k).device_name; end
        warning('zartes_get_pixel_size:notFound', 'Design not found: %s', msg);
    end
end
end

% Helpers
function v = zs_str(s, f)
    if isfield(s, f) && ~isempty(s.(f)), v = char(s.(f)); else, v = ''; end
end
function v = zs_num(s, f)
    if isfield(s, f) && ~isempty(s.(f)), v = double(s.(f)); else, v = NaN; end
end
