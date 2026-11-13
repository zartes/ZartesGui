%script para cargar una base de datos access y poder trabajar con ella en matlab.
name='series.accdb';
dir='C:\Users\Carlos\Desktop\ATHENA\medidas\Mo_INA\';
dbpath = [dir name];
url = [['jdbc:odbc:Driver={Microsoft Access Driver (*.mdb, *.accdb)};DSN='';DBQ='] dbpath];
conn = database('','','','sun.jdbc.odbc.JdbcOdbcDriver',url);

tabla='Series'
cursor = exec(conn,['SELECT serie FROM ' tabla])
data=fetch(cursor)

%fastinsert(conn,'Hoja1',{'Observaciones'},{'prueba'}) %mete un nuevo
%regsitro
%commit(conn) %%commit changes

%cursor = exec(conn,['SELECT serie FROM ' tabla ' WHERE  observaciones LIKE
%''% TES%'' '])