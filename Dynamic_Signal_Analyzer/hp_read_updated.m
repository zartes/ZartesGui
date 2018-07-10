function [freq, data, header] = hp_read_updated(dsa)
% Function to read ASCII header of DSA HP3562A device
%
% Input:
% - dsa: Object class DSA (dsa.ObjHandle)
%
% Output:
% - freq: frequencies (units)
% - data: power spectral density (PSD)
% - header: ASCII header
%
% Example:
% [freq, data, header] = hp_read_updated(dsa)
%
% Last update: 05/07/2018

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%  ASCII read header %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Str15 = 'str2double(char(fread(dsa.ObjHandle,15,''char'')))';

fprintf(dsa.ObjHandle,'DDAS');
fread(dsa.ObjHandle,2,'char');          % se leen los 2 primeros caracteres. #I

header.n_tot = eval(Str15);             % se lee el numero total de entries
header.df = eval(Str15);                % se lee la 'display function'
header.n_points = eval(Str15);          % se lee el numero de puntos debe ser n_tot-66
header.d_points = eval(Str15);          % se lee num diplayed points
header.n_avg = eval(Str15);             % numero de averages
header.ch = eval(Str15);                % channels

fread(dsa.ObjHandle,15*30,'char');      % next 30 entries in header maximum resd_size 512 chars.
fread(dsa.ObjHandle,15*5,'char');       % next 5 entries in header

header.loglin = eval(Str15);            % log linear boolean
fread(dsa.ObjHandle,15*2,'char');

header.measmode = eval(Str15);          % modo medida. 0:linear res,1:log res,2:swept sine
fread(dsa.ObjHandle,15*11,'char');      % next 10 entries in header

header.Dx = eval(Str15);                % deltaX. 10Dx si measmod=1.
fread(dsa.ObjHandle,15*8,'char');       % next 8 entries

header.start_values = fread(dsa.ObjHandle,25*2,'char'); % last 2 entries.
header.size = 66;                       % length of header in entries.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n_data = (header.n_tot-header.size)/header.n_points; %segun el modo de lectura tenemos un array con los
%datos o dos arrays (real e imag).

% ASCII read data
data = NaN(2,header.n_points);
for i = 1:header.n_points
    %data(j,i)=str2double(char(fread(dsa.ObjHandle,15,'char')));
    %los datos se devuelven como un array simple o como parejas (Re, Im).
    data(1,i) = eval(Str15);
    if (n_data == 2)
        data(2,i) = eval(Str15);
    end
end
if (n_data ~= 2)
    data(2,:) = [];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf(dsa.ObjHandle,'SF?');
st_freq = str2double(fscanf(dsa.ObjHandle));

fprintf(dsa.ObjHandle,'FRS?');
sp_freq = str2double(fscanf(dsa.ObjHandle));

if header.loglin == 0 %header.measmode==0
    freq = st_freq:header.Dx:st_freq+sp_freq;
elseif header.loglin == 1 %header.measmode==1
    %freq=10.^(log10(st_freq):header.Dx:log10(st_freq)+sp_freq); %A veces
    %Dx no es suficientemente preciso y da un size(freq) erroneo.
    freq = logspace(log10(st_freq), log10(st_freq) + sp_freq, header.n_points);
    %header.Dx,size(freq)
    %freq(1),freq(end)
end