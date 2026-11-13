function anaopt=BuildAnalizeOptions()

%%%Opciones mínimas para poder ejecutar el AnalizeRun.
anaopt.datadir=pwd;
anaopt.ZfitOpt.TFdata='HP';
anaopt.ZfitOpt.Noisedata='HP';
anaopt.ZfitOpt.f_ind=[1 1e5];
anaopt.ZfitOpt.ThermalModel='default';
anaopt.ZfitOpt.NoiseFilterModel.model='default';
anaopt.ZfitOpt.NoiseFilterModel.wmed=40;
anaopt.TES_sides=100e-6;%%%!!!
