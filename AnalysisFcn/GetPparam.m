function par = GetPparam(p,name)
    %%%Funcion para devolver el array con los valores de un parámetro
    %%%determinado. Pasamos la estructura p a una temperatura fija, no la P()

par = eval(strcat('[','p.',name,'];'));