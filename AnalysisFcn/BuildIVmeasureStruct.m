function IVmeasure=BuildIVmeasureStruct(data,Tbath)
%%Creamos la estructura de medida para usar con el resto de funciones.

  IVmeasure.ib=data(:,1);%%%
  IVmeasure.vout=data(:,2);%%%
  IVmeasure.Tbath=Tbath;
