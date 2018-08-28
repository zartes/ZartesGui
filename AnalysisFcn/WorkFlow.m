
IVmeasure=importIVs();
load('G:\Unidades de equipo\ZARTES\DATA\2018\Junio\circuit.mat')
IVstruct=GetIVTES(circuit,IVmeasure);
TF = importTF();
