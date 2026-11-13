function Kafhandle=BuildMnKaHandle()
%%%funcion para devolver el handle a las lineas Ka del Mn incluyendo
%%%resolucion gaussiana.
% name = getenv('COMPUTERNAME');
% if strcmp(name,'DESKTOP-DNDSVBJ')
%     HandleDir='C:\Users\nico\Documents\GitHub\Zartes_AnaSoft\HandleLibrary';
% else
%     HandleDir='C:\Users\Athena\Documents\Carlos Software\Zartes_AnaSoft-master\HandleLibrary';
% end
LinesFile=strcat('.\HandleLibrary\','MnKa-Voigt-Lines.json');
fhMnKa=BuildVoigtHandle(LinesFile);
%x=[-10:0.1:10];%%%! ojo, la y que usemos como vector de energia tiene que tener el mismo step de 0.1
normalizacion='amplitud';%amplitud o area.
Low=-100;
High=100;
switch normalizacion
    case 'amplitud'
        Kafhandle=@(p,y)p(1)*conv(fhMnKa(y),normpdf([Low:(y(2)-y(1)):High],0,p(2)/2.355)./max(conv(fhMnKa(y),normpdf([Low:(y(2)-y(1)):High],0,p(2)/2.355))),'same');
    case 'area'
        Kafhandle=@(p,y)p(1)*conv(fhMnKa(y),normpdf([Low:(y(2)-y(1)):High],0,p(2)/2.355)./sum(conv(fhMnKa(y),normpdf([Low:(y(2)-y(1)):High],0,p(2)/2.355))),'same');
end