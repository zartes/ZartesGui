function ExportData(src,evnt)
% Auxiliary function to handle right-click mouse options of IC and BVscan representation
% Last update: 22/10/2019


d = src.UserData;
cmenu = uicontextmenu('Visible','on');
c1 = uimenu(cmenu,'Label','Export Data to txt file','Callback',{@ExportD},'UserData',d);

set(src,'uicontextmenu',cmenu);

function ExportD(src,evnt)

d = src.UserData;
[FileName, PathName] = uiputfile('.txt', 'Select a file name for storing data');
if isequal(FileName,0)||isempty(FileName)
    return;
end
file = strcat([PathName FileName]);
fid = fopen(file,'a+');


data = d.data;
fprintf(fid,[d.Label '\n']);
save(file,'data','-ascii','-tabs','-append');
fclose(fid);
