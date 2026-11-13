function Kbfhandle=BuildMnKbHandle()
%%%funcion para devolver el handle a las lineas Kb del Mn incluyendo
%%%resolucion gaussiana.
name = getenv('COMPUTERNAME');
if strcmp(name,'DESKTOP-DNDSVBJ')
    HandleDir='C:\Users\nico\Documents\GitHub\Zartes_AnaSoft\HandleLibrary';
else
    HandleDir='C:\Users\Carlos\Documents\GitHub\zartes\HandleLibrary';
end
LinesFile=strcat(HandleDir,'\','MnKb-Voigt-Lines.json');
fhMnKb=BuildVoigtHandle(LinesFile);
%x=[-10:0.1:10];%%%! ojo, la y que usemos como vector de energia tiene que tener el mismo step de 0.1
normalizacion='amplitud';%amplitud o area.
Low=-100;
High=100;
switch normalizacion
    %%% p(1): Scale factor, p(2):fwhm.
    case 'amplitud'
        Kbfhandle=@(p,y)p(1)*conv(fhMnKb(y),normpdf([Low:(y(2)-y(1)):High],0,p(2)/2.35482)./max(conv(fhMnKb(y),normpdf([Low:(y(2)-y(1)):High],0,p(2)/2.35482))),'same');
    case 'area'
        Kbfhandle=@(p,y)p(1)*conv(fhMnKb(y),normpdf([Low:(y(2)-y(1)):High],0,p(2)/2.35482)./sum(conv(fhMnKb(y),normpdf([Low:(y(2)-y(1)):High],0,p(2)/2.35482))),'same');
end