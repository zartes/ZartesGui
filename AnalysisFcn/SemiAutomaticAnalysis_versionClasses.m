
%%
DataPath = uigetdir('', 'Pick a Data path named Z(w)-Ruido');
if DataPath ~= 0
    DataPath = [DataPath filesep];
else
    errordlg('Invalid Data path name!','ZarTES v1.0','modal');
    return;
end
% Creamos la superestructura del TES
TESDATA = TES_Struct;
TESDATA = TESDATA.Constructor;
TESDATA.circuit = TESDATA.circuit.IVcurveSlopesFromData(DataPath);
TESDATA.TFS = TESDATA.TFS.TFfromFile(DataPath);
[TESDATA.IVsetP, TempLims] = TESDATA.IVsetP.ImportFromFiles(TESDATA,DataPath);
TESDATA.IVsetN = TESDATA.IVsetN.ImportFromFiles(TESDATA,TESDATA.IVsetP(1).IVsetPath, TempLims);
TESDATA = TESDATA.CheckIVCurvesVisually;

TESDATA = TESDATA.fitPvsTset;
TESDATA = TESDATA.plotNKGTset;
TESDATA = TESDATA.EnterDimensions;
TESDATA = TESDATA.FitZset;
TESDATA.plotABCT;
% Recopila las gráficas más importantes,
TESDATA.PlotTFTbathRp;
TESDATA.PlotNoiseTbathRp;
TESDATA.GraphsReport;
TESDATA.Save;
