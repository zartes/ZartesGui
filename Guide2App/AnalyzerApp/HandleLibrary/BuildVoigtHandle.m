function fh=BuildVoigtHandle(file)
%%%Funcion para crear un handle con una suma de lorenzianas correspondientes
%%%a varias lineas de emision con ciertas Energy, fwhm e Intentity
%%%guardadas en formato .json. Creado expresamente para el caso Mn55.
%%%15-Nov-2023.
data=loadjson(file);
Lines=data.Lines;

fh=@(E)0;
for i=1:length(Lines)
    A=Lines{i}.Intensity;
    E0=Lines{i}.Energy;
    %S=Lines{i}.fwhm/2.35482;%%%gaussian
    S=Lines{i}.fwhm/2;%%%Lorentzian.
    %fh=@(E) fh(E)+A*exp(-(E-E0).^2./2/S.^2)/(S*sqrt(2*pi));
    fh=@(E) fh(E)+(A*S*pi)*S./((E-E0).^2+S.^2)/pi;%Ojo a la definicion de la Lorentziana.
    %Usamos lineas de la ref. Eckart et. al 2016 que normaliza en Amp, no
    %en area.(En realidad saco las tablas del art. de Maite y Bea).
end
