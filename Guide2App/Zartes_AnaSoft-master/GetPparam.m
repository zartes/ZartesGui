function par=GetPparam(p,name)
    %%%Funcion para devolver el array con los valores de un parámetro
    %%%determinado. Pasamos la estructura p a una temperatura fija, no la P()
    %%% V1: simplifico la llamada al parámetro y modifico para que devuelva
    %%% también el parray y p0.
    %par=eval(strcat('[','p.',name,']')); %%%old version.
    par=[p.(name)];
    n=length(p);
    np=length(par);
    par=reshape(par,[np/n, n]);
