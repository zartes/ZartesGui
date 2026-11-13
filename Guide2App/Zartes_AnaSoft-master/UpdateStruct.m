function S=UpdateStruct(Sbig,ssmall)
%%%Actualiza una estructura grande con los campos de la pequeña. Esto
%%%debería evitar los errores al intentar actualizar una estructura a
%%%partir de otra que no contiene todos los campos de la original y es útil
%%%porque a veces sólo se quiere actualizar parte.
S=Sbig;
fnames=fieldnames(ssmall);
for i=1:length(fnames)
    if isfield(Sbig,fnames{i})
        S.(fnames{i})=ssmall.(fnames{i});
    end
end