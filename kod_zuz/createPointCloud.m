%vytvarame point cloud, ak sa podari tak by som toto rada volala ako
%jednorazovy skript - raz to zbehne a potom by to uz malo len pristupovat k
%datam ktore si to samo vyrobi (h o p e f u l l y)

clear all; close all;

%%uvodny check priecinkov na data
status=0;
while status==0
    status=mkdir('pointCloudData'); %vytvori priecinok na ukladanie dat ktore ziskame ako vystup z tohto skriptu
end

status=0;
while status==0
    status=mkdir('niiData'); %vytvori priecinok na ukladanie volume vystupov vo formate .nii
end

status=mkdir('sourceData'); %vytvori priecinok kam idu data s ktorymi pracujeme, ak este neexistuje
sourceContent=dir('sourceData'); %nacita si obsah priecinku so vstupnymi datami
sourceContent(1:2)=[]; %vymaze prve dva zbytocne prvky zo zoznamu priecinkov (. a ..)
if status==0||sum([sourceContent.isdir])==0
    fprintf('Skript sa ukonci kvoli chybajucim vstupnym datam.\nNaplnte vstupny priecinok sourceData DICOM snimkami v prislusnych podpriecinkoch a znovu spustite skript.\nPre pokracovanie stlacte akukolvek klavesu.\n');
    pause;
    return
end
clear status;

%% toto si snimky nacita, umiestni a vytvori volume subor
sourceCount=length(sourceContent); %spocita kolko priecinkov mame (kolko sad obrazkov ideme umiestnovat)

for i=1:sourceCount
    folderPath=string(sourceContent(i).folder);
    outputName(i)=string(sourceContent(i).name);
end
%     folderPath(i)=[string(sourceContent(i).folder)+'\'+string(sourceContent(i).name)+'\'];
%     folderContent=dir([string(folderPath)+'\*.dcm']); %nacita si obsah priecinku so vstupnymi snimkami
%     folderContent(1:2)=[]; %vymaze prve dva zbytocne prvky zo zoznamu suborov (. a ..)
%     snimkaCount=length(folderContent); %zistime kolko toho mame v priecinku
sourceTable = dicomCollection(folderPath,"IncludeSubfolders",true);

for j=1:sourceCount
sourceTable.Filenames{j,1}(1)=[]; %znizime antialiasing eliminaciou prvej a poslednej snimky
sourceTable.Filenames{j,1}(sourceTable.Frames(j)-1)=[]; %znizime antialiasing eliminaciou prvej a poslednej snimky
sourceTable.Frames(j)=sourceTable.Frames(j)-2; %odoberieme z poctu snimok tie dve
end

for i=1:sourceCount
    V=dicomreadVolume(sourceTable,char(sourceTable.Properties.RowNames(i)),"MakeIsotropic",true);
    V=squeeze(V);
    niftiwrite(V,string(["niiData\"+outputName(i)+".nii"]));
    clear V;
end

intensity = [0 20 40 120 220 1024];
alpha = [0 0 0.15 0.3 0.38 0.5];
color = ([0 0 0; 43 0 0; 103 37 20; 199 155 97; 216 213 201; 255 255 255])/255;
queryPoints = linspace(min(intensity),max(intensity),256);
amap = interp1(intensity,alpha,queryPoints)';
cmap = interp1(intensity,color,queryPoints);

for i=1:sourceCount
    V=niftiread(string(["niiData\"+outputName(i)+".nii"]));
    vol=volshow(V,"Colormap",cmap,"Alphamap",amap);
end
%     nazov_suboru=sprintf('/test_export/test%d.png',por);
%     imwrite(cast(snimka,"uint16"),[pwd nazov_suboru],'Alpha',cast(maska,"double"))
%     fprintf('Snimka cislo %d z %d uspesne ulozena!\n',por,pocet);
%     close;