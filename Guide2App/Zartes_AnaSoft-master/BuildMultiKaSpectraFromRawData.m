function Pdata=BuildMultiKaSpectraFromRawData(RawPdata)
%debug%
%Pdata=RawPdata;
if ~isfield(RawPdata,'circuit')
    error('Añade circuit a RawData')
end
if ~isfield(RawPdata,'filename')
    error('Añade filenames RawData')
end

%%%%Ka Energies.
Epeaks=[0 5887.65 5898.5];

%%%default opts
Ebins=5870:0.5:5915;
Kaoptions.nbins=200;
Kaoptions.finecal=1;
Kaoptions.xlimits=[5875 5910];
Kaoptions.p0=[120 3];
Kaoptions.title='default %Rn';
Kaoptions.plot_format='bar';
Kaoptions.Data=[];
Kaoptions.Ecal=@(x)x;
Kaoptions.exclude=[];
%Kaoptions.Ebins=Ebins;

[ofts,index]=BuildAutomaticOFTs(RawPdata);
for i=1:length(ofts)
    if isfield(RawPdata(i),'polarity')
        OP.polarity=RawPdata(i).polarity;
    else
        OP.polarity=1;
    end
    file=RawPdata(i).filename;
    OP.circuit=RawPdata(i).circuit;
    OP.oft=ofts{i};
    if OP.polarity ~= 1
        OP.oft(:,2)=-OP.oft(:,2)/max(-OP.oft(:,2));
    end
    %%%filter DC level
    if isfield(RawPdata(i),'Nbaselines')
        Nbaselines=RawPdata(i).Nbaselines;
    else
        Nbaselines=1000;
    end
    dclevel(i)=mode(RawPdata(i).dc(1:Nbaselines));%%%!!!use Nbselines!
    indDC=find(RawPdata(i).dc>dclevel(i)-0.01 & RawPdata(i).dc<dclevel(i)+0.01);
    index(i).NoiseIndex=intersect(index(i).NoiseIndex,indDC);
    index(i).KaIndex=intersect(index(i).KaIndex,indDC);
    OP.index=union(index(i).NoiseIndex,index(i).KaIndex);%Analizamos solo Ruidos y Kas.

    %%%Analize Data
    Pdata(i)=AnalizaPulseFITS(file,OP);
    %Pdata(i).NoiseIndex=index(i).NoiseIndex;
    %Pdata(i).KaIndex=index(i).KaIndex;
    %%%%automatic set options
    infor=fitsinfo(file);
    ix=strcmp(infor.BinaryTable.Keywords(:,1),'RP');
    rp=infor.BinaryTable.Keywords{ix,2}*100;

    %%%DC correction
    dcdata_0=Pdata(i).dc(index(i).KaIndex);
    oftdata_0=Pdata(i).OFT_Energy(index(i).KaIndex);
    [~,tf1]=removeOutliersMAD(dcdata_0);
    [~,tf2]=removeOutliersMAD(oftdata_0);
    tf=(~tf1)&(~tf2);
    DCfit=fit(dcdata_0(tf)',oftdata_0(tf)','poly1');
    dcmean=mean(removeOutliersMAD(Pdata(i).dc(index(i).KaIndex)));
    correction=DCfit(Pdata(i).dc(index(i).KaIndex))-DCfit(dcmean);
    data=Pdata(i).OFT_Energy(index(i).KaIndex)-correction';

    %%%Kaoptions
    %data
    %data=Pdata(i).OFT_Energy(index(i).KaIndex);
    %data=removeOutliersMAD(Pdata(i).OFT_Energy(index(i).KaIndex));
    data=removeOutliersMAD(data,5);
    Kaoptions.Data=data;

    %Cal
    [h,x]=hist(Pdata(i).OFT_Energy(index(i).NoiseIndex),50);
    f1=fit(x(:),h(:),'gauss1');
    a1=f1.b1;
    [h,x]=hist(data,Kaoptions.nbins);
    f2=fit(x(:),h(:),'gauss2');
    a2=f2.b2;a3=f2.b1;
    Ecal{i}=fit([a1 a2 a3]',Epeaks','poly2');
    Kaoptions.Ecal=Ecal{i};
    Kaoptions.title=[sprintf('%2.0f',rp) '%Rn'];
    FormatKaSpectrumWithResidues(Kaoptions)
end
for i=1:length(ofts)
    Pdata(i).NoiseIndex=index(i).NoiseIndex;
    Pdata(i).KaIndex=index(i).KaIndex;
    Pdata(i).oft=ofts{i};
    Pdata(i).Ecal=Ecal{i};
end