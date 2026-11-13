function zartes_crear_init_json(config, output_file, varargin)
% ZARTES_CREAR_INIT_JSON  Genera el JSON de configuración inicial de medidas
%                         consultando automáticamente ZarTESDB.
%
%   zartes_crear_init_json(config, output_file)
%   zartes_crear_init_json(config, output_file, opts)
%
%   DEFINICIÓN DEL CONFIG 
%
%   config.RTs   : struct con campos CH0..CH5, cada uno con campo 'name'
%   config.SQUIDs: struct con campos CH1..CH2, cada uno con campo 'name'
%
%   Si 'name' es un device_name reconocido (ej. '4Z2_62_14'), se consulta
%   la BD para obtener el 'size' automÃ¡ticamente.
%   Si 'name' es un texto libre (ej. 'Interdigital', 'GAP'), se conserva
%   tal cual y 'size' debe especificarse manualmente o queda como '?'.
%
%   EJEMPLO DE USO
%
%   config.RTs.CH0.name  = 'Interdigital';   % texto libre â†’ size manual
%   config.RTs.CH0.size  = '?';
%   config.RTs.CH1.name  = '4Z2_62_14';      % device DB â†’ size automÃ¡tico
%   config.RTs.CH2.name  = '3Z10_44_14';
%   config.RTs.CH3.name  = '5Z1_37_31';
%   config.RTs.CH4.name  = '4Z4_34_13';
%   config.RTs.CH5.name  = 'GAP';
%   config.RTs.CH5.size  = 'bulk';
%
%   config.SQUIDs.CH1.name = '4Z2_62_24';
%   config.SQUIDs.CH2.name = '4Z2_62_14';
%
%   zartes_crear_init_json(config, 'Init_Abril_2026.json');
%
%   PARÁMETROS OPCIONALES (opts)
%     opts.host / .dbname / .user / .password  â†’ conexión BD
%     opts.python  â†’ ejecutable python (default 'python3')
%     opts.script  â†’ ruta a zartes_db_query.py (autodetectado si vacÃ­o)
%     opts.verbose â†’ true para mostrar info por pantalla (default true)

% Parse optional arguments
if nargin < 2 || isempty(output_file)
    output_file = 'Init_new.json';
end

p = inputParser();
p.addParameter('host',     'localhost',    @ischar);
p.addParameter('dbname',   'zartesdb',     @ischar);
p.addParameter('user',     'zartes_admin', @ischar);
p.addParameter('password', '',             @ischar);
p.addParameter('python',   'python',        @ischar);  % 'python' en Windows, 'python3' en Linux/Mac
p.addParameter('script',   '',             @ischar);
p.addParameter('verbose',  true,           @islogical);

% Accept a struct as third argument
if numel(varargin) == 1 && isstruct(varargin{1})
    s = varargin{1};
    fields = fieldnames(s);
    args = {};
    for k = 1:numel(fields)
        args = [args, {fields{k}, s.(fields{k})}]; %#ok<AGROW>
    end
    p.parse(args{:});
else
    p.parse(varargin{:});
end
opts = p.Results;

RT_CHANNELS    = {'CH0','CH1','CH2','CH3','CH4','CH5'};
SQUID_CHANNELS = {'CH1','CH2'};

% Recopilar todos los device_names que necesitan consulta BD
device_pattern = '^[2-9]Z\d';   % empieza con dígito+Z+número â†’ es device BD
to_query = {};

for ch_list = {RT_CHANNELS, SQUID_CHANNELS}
    channels = ch_list{1};
    if isequal(channels, RT_CHANNELS),    section = 'RTs';
    else,                                  section = 'SQUIDs'; end

    if ~isfield(config, section), continue; end
    for k = 1:numel(channels)
        ch = channels{k};
        if ~isfield(config.(section), ch), continue; end
        name = config.(section).(ch).name;
        if ~isfield(config.(section).(ch), 'size') && ~isempty(regexp(name, device_pattern, 'once'))
            to_query{end+1} = name; %#ok<AGROW>
        end
    end
end
to_query = unique(to_query);

% 2. Consultar BD por diseño (no requiere que el device exista)
% Usa zartes_get_pixel_size: busca por (series, chip_code, pixel) en chip_design
% + tes_design, independientemente de si la oblea concreta está registrada.
db_info = containers.Map();
if ~isempty(to_query)
    if opts.verbose
        fprintf('Consultando diseÃ±o TES para %d device(s)...\n', numel(to_query));
    end
    db_opts.host     = opts.host;
    db_opts.dbname   = opts.dbname;
    db_opts.user     = opts.user;
    db_opts.password = opts.password;
    db_opts.python   = opts.python;
    db_opts.script   = '';   % auto-detect zartes_get_pixel_size.py

    infos = zartes_get_pixel_size(to_query, db_opts);
    for k = 1:numel(infos)
        db_info(infos(k).device_name) = infos(k);
    end
end

% 3. Construir estructura JSON
out.RTs    = struct();
out.SQUIDs = struct();

for ch_list = {RT_CHANNELS, SQUID_CHANNELS}
    channels = ch_list{1};
    if isequal(channels, RT_CHANNELS),    section = 'RTs';
    else,                                  section = 'SQUIDs'; end

    if ~isfield(config, section)
        for k = 1:numel(channels)
            out.(section).(channels{k}) = struct('name','â€”','size','â€”');
        end
        continue
    end

    for k = 1:numel(channels)
        ch   = channels{k};
        if ~isfield(config.(section), ch)
            out.(section).(ch) = struct('name','â€”','size','â€”');
            continue
        end
        entry = config.(section).(ch);
        name  = entry.name;

        % size: manual > BD > '?'
        if isfield(entry, 'size')
            sz = entry.size;
        elseif db_info.isKey(name)
            inf_ = db_info(name);
            if inf_.found
                sz = inf_.size;
            else
                sz = '??';
                warning('zartes_crear_init_json:notFound', ...
                        '%s: device no encontrado en BD', name);
            end
        else
            sz = '?';
        end

        out.(section).(ch) = struct('name', name, 'size', sz);

        % Info en consola
        if opts.verbose && db_info.isKey(name) && db_info(name).found
            d = db_info(name);
            fprintf('  %-6s %-18s  %s  nick=%-10s  mem=%d  abs=%d\n', ...
                    [section '.' ch], name, sz, d.nickname, ...
                    d.has_membrane, d.has_absorber);
        end
    end
end

% 4. Serializar y guardar 
%jsonencode produce una sola línea; re-formateamos para que sea legible
%json_raw = jsonencode(out);
json_raw = savejson(out);

% Añadir saltos de línea tras cada campo de canal (estilo del formato original)
json_pretty = format_init_json(out);

fid = fopen(output_file, 'w', 'n', 'UTF-8');
if fid == -1
    error('zartes_crear_init_json:fileError', ...
          'No se puede crear el fichero: %s', output_file);
end
fwrite(fid, json_pretty, 'char');
fclose(fid);

if opts.verbose
    fprintf('\nJSON guardado en: %s\n', output_file);
    fprintf('%s\n', json_pretty);
end
end


% Serialización con el formato exacto del proyecto
function s = format_init_json(out)
% Produce el mismo formato que los JSON existentes:
%   {"RTs":{\n"CH0":{...},\n...},\n"SQUIDs":{\n"CH1":{...},...}\n}

NL = sprintf('\n');   % compatible con MATLAB < R2016b (evita 'newline')

RT_CH    = {'CH0','CH1','CH2','CH3','CH4','CH5'};
SQUID_CH = {'CH1','CH2'};

s = '{"RTs":{';
lines = {};
for k = 1:numel(RT_CH)
    ch = RT_CH{k};
    if isfield(out.RTs, ch)
        e = out.RTs.(ch);
        lines{end+1} = sprintf('"%s":{"name":"%s","size":"%s"}', ...
                               ch, e.name, e.size); %#ok<AGROW>
    end
end
s = [s NL strjoin(lines, [',' NL])];
s = [s NL '},'];

s = [s NL '"SQUIDs":{'];
lines = {};
for k = 1:numel(SQUID_CH)
    ch = SQUID_CH{k};
    if isfield(out.SQUIDs, ch)
        e = out.SQUIDs.(ch);
        lines{end+1} = sprintf('"%s": {"name":"%s","size":"%s"}', ...
                               ch, e.name, e.size); %#ok<AGROW>
    end
end
s = [s NL strjoin(lines, [',' NL])];
s = [s NL '}' NL '}'];
end