
% conectarse a una base de datos generada en matlab 
conn = database('ZarTESDB','','');

% Crear una tabla
% Nota: es muy importante darle una length a las variables de tipo varchar
sqlquery = 'DROP TABLE ';
curs = exec(conn,sqlquery);
curs = fetch(curs);

sqlquery = 'ALTER TABLE Enfriada MODIFY ID_Enfriada varchar(255);';
curs = exec(conn,sqlquery);
curs = fetch(curs);

sqlquery = ['CREATE TABLE Enfriada(ID_Enfriada varchar(255),'...
    'ID_SQUID varchar(255),'...
    'ID_TES varchar(255), Date_dd_mm_yy  varchar(255), Location_Enfriada varchar(255), Complete_Y_N varchar(255))'];
curs = exec(conn,sqlquery);
curs = fetch(curs);

sqlquery = ['CREATE TABLE TES_RT(ID_TES varchar(255), Ch numeric, '...
    'Rn_RT_mOhm numeric, Tc0_RT_mK numeric, Tc90_RT_mK numeric, DeltaT_RT_mK numeric, Location_RT varchar(255), Complete_Y_N varchar(255))'];
curs = exec(conn,sqlquery);
curs = fetch(curs);

sqlquery = ['CREATE TABLE BULK_RT(ID_BULK varchar(255), Ch numeric, '...
    'R300_RT_Ohm numeric, Rn_RT_Ohm numeric, RRR numeric, Tc0_mK_RT numeric , Tc90_mK_RT numeric, DeltaT_RT_mK numeric, Location_RT varchar(255), Complete_Y_N varchar(255))'];
curs = exec(conn,sqlquery);
curs = fetch(curs);

sqlquery = ['CREATE TABLE TES_Analysis(ID_TES_Analysis varchar(255), ID_TES varchar(255), ID_Enfriada varchar(255), RUN numeric, BField_uA numeric, Comment varchar(255),'...    
    'Rf_Ohm numeric, Rsh_Ohm numeric, L_H numeric, Rn_mOhm numeric, Rpar_uOhm numeric, '...
    'n varchar(255), K_nW_Kn varchar(255), G_pW_K varchar(255), G100_pW_K varchar(255), Tc_mK_Analysis varchar(255),'...
    'C_fJ_K varchar(255),alpha varchar(255), beta varchar(255), tau_eff_us varchar(255),'...
    'IVcurves_Location varchar(255), CriticalCurrents_Location varchar(255), Zw_Location varchar(255), Noise_Location varchar(255), Complete_Y_N varchar(255))'];
curs = exec(conn,sqlquery);
curs = fetch(curs);

sqlquery = ['CREATE TABLE SQUID(ID_SQUID varchar(255), invMin_uA_phi numeric,'...
    'invMf_uA_phi numeric, Noise_pA_sqrtHz numeric, Complete_Y_N varchar(255))'];
curs = exec(conn,sqlquery);
curs = fetch(curs);

sqlquery = ['CREATE TABLE TES_Device(ID_TES varchar(255), ID_Sputtering varchar(255), Thicknesses varchar(255),'...
    'Bilayer_um_um varchar(255), Membrane_Y_N varchar(255), Membrane_Thickness numeric, Membrane_Length numeric, Membrane_Width numeric,'...
    'Absorbent_Y_N varchar(255), Absorbent_Material varchar(255), Absorbent_Thickness numeric, Banks_Y_N varchar(255), Complete_Y_N varchar(255))'];    
curs = exec(conn,sqlquery);
curs = fetch(curs);

sqlquery = ['CREATE TABLE Sputtering_Tech(ID_Sputtering varchar(255), Date_dd_mm_yy varchar(255), Mlayer varchar(255),'...
    'Mater varchar(255), Substrate varchar(255), Sample_holder varchar(255), Pressure_Ar_mTorr varchar(255), Method varchar(255),'...
    'Power_W varchar(255), Bias_V varchar(255), Current_mA varchar(255), Time_min_sec varchar(255),NOM_Th_nm varchar(255),Real_Th_nm varchar(255),Notes varchar(255), Complete_Y_N varchar(255))'];    
curs = exec(conn,sqlquery);
curs = fetch(curs);

sqlquery = ['CREATE TABLE Sputtering_params(working_distance varchar(255), Ar_flow varchar(255), dep_Temperature varchar(255),'...
    'Substrates varchar(255), corning_glass varchar(255), Pre_sputtering_shutter_closed varchar(255), RF_bias_cleaning varchar(255), NOM_Th_thickness_nm varchar(255),'...
    'Real_Th_thickness_nm varchar(255), Complete_Y_N varchar(255))'];    
curs = exec(conn,sqlquery);
curs = fetch(curs);

% sqlquery = ['CREATE TABLE BULK(ID_BULK varchar(255), Sputtering varchar(255), Thicknesses varchar(255),'...
%     'Bilayer varchar(255), Membrane varchar(255), Membrane_Thickness numeric, Membrane_Length numeric, Membrane_Width numeric,'...
%     'Absorbent varchar(255), Absorbent_Material varchar(255), Absorbent_Thickness numeric, Banks varchar(255))'];    
% curs = exec(conn,sqlquery);
% curs = fetch(curs);

ALTER TABLE Enfriada
    ADD( 
% %%
% exec(conn,'ALTER TABLE TesZar2 Alter Column Name varchar(30)') %30 can be any other value
% 
% % close(curs);
% % commit(conn);
% 
% % Extraer los nombres de las columnas
% curs = exec(conn,'SELECT * FROM TesZar2');
% curs = fetch(curs);
% colnames = columnnames(curs,true);
% 
% % % Añadir nuevos datos a la tabla
% % colnames = {'TESID','Name','FirstName','Address','Age'};
% data = {2 1 'Torres' 'Eva' 'Argel 19' 37};
% tablename = 'TesZar2';
% datainsert(conn,tablename,colnames,data)
% 
% 
% % Modificar un valor de la base de datos
% update(conn,'TesZar2',{'Name'},{'Boul'},'where Name = ''Bolea''')
% 
% update(conn,'TesZar2',colnames,Data,'where ZTESID <> 0')
% 
% 
% % Eliminar una tabla o contenido
% sqlquery = 'DELETE TABLE Person';
% curs = exec(conn,sqlquery);
% curs = fetch(curs);
% 
% % Hacer una variable como incremental que la pondremos como ID
% 
% % Crear una Tabla del proceso de Fabricación
%   % Layer (SL,ML) , Material (Mo4, Mo5, Mo4/Au, Mo5/Au), Sustrato, Holder, 
% 
% % Crear una Tabla del proceso de Medidas
%     % RTs  (TESID, Fecha, Fichero de medida, Canal, Tc)
%     
%     % Analysis  (TESID, Fecha, Ficheros de medida, n, Tc, K, G, G100, Rn,
%     % Rpar
%     % Parametros del circuito: invMf, invMin, L, Rshunt, Rf.
%     
%     %%%
%     
%     conn = database('JuanPrueba','','');
% 
% sqlquery = ['CREATE TABLE TesZar2(ZTESID INT, TESNAME NUMERIC, Name VARCHAR(255), '...
%     'FirstName VARCHAR(255), Address VARCHAR(255), Age NUMERIC)'];
% 
% curs = exec(conn,sqlquery);
% curs = fetch(curs);
% 
% curs = exec(conn,'SELECT * FROM TesZar2');
% curs = fetch(curs);
% colnames = columnnames(curs,true);
% 
% % % Añadir nuevos datos a la tabla
% % colnames = {'TESID','Name','FirstName','Address','Age'};
% data = {1 1 'Torres' 'Eva' 'Argel 19' 35};
% tablename = 'TesZar2';
% datainsert(conn,tablename,colnames,data);
% 
% data = {2 1 'Bolea' 'Juan' 'Argel 19' 37};
% tablename = 'TesZar2';
% datainsert(conn,tablename,colnames,data);
% 
% exec(conn,'ALTER TABLE TesZar2 Alter Column Name varchar(30)')
% 
% query = 'update TesZar2 SET Name = ''Boul'' where Name = ''Bolea''';
% exec(conn, query);
% 
% update(conn,'TesZar2',{'Name'},{'Boul'},'where Name = ''Bolea''')
% 
% curs = exec(conn,'SELECT * FROM TesZar2');
% curs = fetch(curs);
% curs.Data

