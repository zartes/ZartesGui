function ReanalizeTES(list)
%%%Función para (re)analizar los datos de los TES y actualizar la
%%%estructura TESDATA. Puede servir si se modifican o añaden cosas a la
%%%estructura P por ejemplo.

bdir=pwd

for i=1:length(list)
    cmd=strcat('getfield(',list{i},',''datadir'')')
    dir=evalin('base',cmd)
    cd(dir)
    cmd=strcat('getfield(',list{i},',''session'')') %%%%%Ojo a 'sesion' o 'session'.
    ssn=evalin('base',cmd)
    load(ssn,'IVset','TFS','Gset');
    
    cmd=strcat('getfield(',list{i},',''circuit'')')
    circuit=evalin('base',cmd)
    
    cmd=strcat('getfield(',list{i},',''TES'')')
    TES=evalin('base',cmd)
    
    P=FitZset(IVset,circuit,TES,TFS);
    
    cmd=strcat('getfield(',list{i},',''IVset'')');
    IVset=evalin('base',cmd);
    
    if(0) %reanalize Gset
    range=[0.25:0.05:0.8];
    if strcmpi(list{i},'ZTES27DATA') range=[0.2:0.05:0.7];end
    if strcmpi(list{i},'ZTES28DATA') range=[0.4:0.05:0.8];end
    Gset=fitPvsTset(IVset,range);
    end
    
    taux=evalin('base',list{i});
    taux.P=P;
    %taux.Gset2=Gset;
    
    assignin('base',list{i},taux)
    
    cmd=strcat('save(''',list{i},''',''',list{i},''')')
    cd(bdir)
    evalin('base',cmd);
    
end
    
cd(bdir)
