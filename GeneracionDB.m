
% conectarse a una base de datos generada en matlab 
conn = database('TESdb','','');

% Crear una tabla
% Nota: es muy importante darle una length a las variables de tipo varchar

sqlquery = ['CREATE TABLE Enfriada (ID_Enfriada numeric,'...
    'ID_SQUID numeric, invMf numeric, invMin numeric,'...
    'ID_TES numeric, Date varchar(100), ID_RUN numeric, BField numeric, Comment varchar(255),'...
    'Location varchar(255))'];
curs = exec(conn,sqlquery);
curs = fetch(curs);

sqlquery = ['CREATE TABLE RT (ID_TES numeric, Ch numeric, '...
    'R300 numeric, RN numeric, RRR numeric, Tc numeric, Location varchar(255))'];
curs = exec(conn,sqlquery);
curs = fetch(curs);

sqlquery = ['CREATE TABLE TES_Analysis(ID_TES numeric, ID_RUN numeric,'...
    'Rf numeric, Rsh numeric, L numeric, RN numeric, Rpar numeric, '...
    'n numeric, K numeric, G numeric, G100 numeric, Tc numeric,'...
    'IVcurvesLocation varchar(255), ICriticas varchar(255), ZwLocation varchar(255), RuidoLocation varchar(255))'];
curs = exec(conn,sqlquery);
curs = fetch(curs);


sqlquery = ['CREATE TABLE TES_Device(ID_TES numeric, Sputtering varchar(255),Espesores varchar(255),'...
    'Area_Largo numeric, Area_Ancho numeric, '...
    'Membrana boolean, Membrana_grosor numeric, Membrana_Largo numeric,  Membrana_Ancho numeric,'...
    'Absorbente boolean, Absorbente_material varchar(100), Absorbente_grosor numeric)'];    
curs = exec(conn,sqlquery);
curs = fetch(curs);



exec(conn,'ALTER TABLE TesZar2 Alter Column Name varchar(30)') %30 can be any other value

% close(curs);
% commit(conn);

% Extraer los nombres de las columnas
curs = exec(conn,'SELECT * FROM TesZar2');
curs = fetch(curs);
colnames = columnnames(curs,true);

% % Añadir nuevos datos a la tabla
% colnames = {'TESID','Name','FirstName','Address','Age'};
data = {2 1 'Torres' 'Eva' 'Argel 19' 37};
tablename = 'TesZar2';
datainsert(conn,tablename,colnames,data)


% Modificar un valor de la base de datos
update(conn,'TesZar2',{'Name'},{'Boul'},'where Name = ''Bolea''')

update(conn,'TesZar2',colnames,Data,'where ZTESID <> 0')


% Eliminar una tabla o contenido
sqlquery = 'DELETE TABLE Person';
curs = exec(conn,sqlquery);
curs = fetch(curs);

% Hacer una variable como incremental que la pondremos como ID

% Crear una Tabla del proceso de Fabricación
  % Layer (SL,ML) , Material (Mo4, Mo5, Mo4/Au, Mo5/Au), Sustrato, Holder, 

% Crear una Tabla del proceso de Medidas
    % RTs  (TESID, Fecha, Fichero de medida, Canal, Tc)
    
    % Analysis  (TESID, Fecha, Ficheros de medida, n, Tc, K, G, G100, Rn,
    % Rpar
    % Parametros del circuito: invMf, invMin, L, Rshunt, Rf.
    
    %%%
    
    conn = database('JuanPrueba','','');

sqlquery = ['CREATE TABLE TesZar2(ZTESID INT, TESNAME NUMERIC, Name VARCHAR(255), '...
    'FirstName VARCHAR(255), Address VARCHAR(255), Age NUMERIC)'];

curs = exec(conn,sqlquery);
curs = fetch(curs);

curs = exec(conn,'SELECT * FROM TesZar2');
curs = fetch(curs);
colnames = columnnames(curs,true);

% % Añadir nuevos datos a la tabla
% colnames = {'TESID','Name','FirstName','Address','Age'};
data = {1 1 'Torres' 'Eva' 'Argel 19' 35};
tablename = 'TesZar2';
datainsert(conn,tablename,colnames,data);

data = {2 1 'Bolea' 'Juan' 'Argel 19' 37};
tablename = 'TesZar2';
datainsert(conn,tablename,colnames,data);

exec(conn,'ALTER TABLE TesZar2 Alter Column Name varchar(30)')

query = 'update TesZar2 SET Name = ''Boul'' where Name = ''Bolea''';
exec(conn, query);

update(conn,'TesZar2',{'Name'},{'Boul'},'where Name = ''Bolea''')

curs = exec(conn,'SELECT * FROM TesZar2');
curs = fetch(curs);
curs.Data

