function filtNoise=filterNoise(noisedata,varargin)
%%%función para filtrar los datos de ruido si es necesario.El input puede
%%%ser en corriente o potencia. el varargin puede ser un option con modelo
%%%o parametros.

if nargin==1
    option.model='default';
    option.wmed=40;
else
    option=varargin{1};
end

switch option.model
    case {'default','medfilt'}
        filtNoise=medfilt1(noisedata(:),option.wmed);
    case 'nofilt'
        filtNoise=noisedata;
    case 'minfilt'
        filtNoise=colfilt(noisedata(:),[option.wmin 1],'sliding',@min);
    case 'minfilt+medfilt'
        ydata=colfilt(noisedata(:),[option.wmin 1],'sliding',@min);
        filtNoise=medfilt1(ydata,option.wmed);
    case 'movingMean'
        filtNoise=movingMean(noisedata(:),option.wmed,option.thr);
    case 'quantile'
        fh=@(data)quantile(data,option.perc);
        filtNoise=colfilt(noisedata(:),[option.wmed 1],'sliding',fh);    
      
end