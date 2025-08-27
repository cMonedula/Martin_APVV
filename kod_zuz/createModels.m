%vytvarame point cloud, ak sa podari tak by som toto rada volala ako
%jednorazovy skript - raz to zbehne a potom by to uz malo len pristupovat k
%datam ktore si to samo vyrobi (h o p e f u l l y)

clear all; close all;

recalc=true; %premenna ktora urcuje ci data pocitame znova!!!
needsRegistration=true; %debug premenna na preskocenie registracie

%%uvodny check priecinkov na data
[sourceContent,sourcePath,inputName]=loadSourceData();
sourceCount=length(sourceContent);

%% toto si snimky nacita, umiestni a vytvori volume subor
%     sourcePath(i)=[string(sourceContent(i).folder)+'\'+string(sourceContent(i).name)+'\'];
%     folderContent=dir([string(sourcePath)+'\*.dcm']); %nacita si obsah priecinku so vstupnymi snimkami
%     folderContent(1:2)=[]; %vymaze prve dva zbytocne prvky zo zoznamu suborov (. a ..)
%     snimkaCount=length(folderContent); %zistime kolko toho mame v priecinku
% sourceTable = dicomCollection(sourcePath,"IncludeSubfolders",true);

% for j=1:sourceCount
%     sourceTable.Filenames{j,1}(1)=[]; %znizime aliasing eliminaciou prvej a poslednej snimky
%     sourceTable.Filenames{j,1}(sourceTable.Frames(j)-1)=[]; %znizime aliasing eliminaciou prvej a poslednej snimky
%     sourceTable.Frames(j)=sourceTable.Frames(j)-2; %odoberieme z poctu snimok tie dve
% end

% for i=1:sourceCount
%     V=dicomreadVolume(sourceTable,char(sourceTable.Properties.RowNames(i)),"MakeIsotropic",true);
%     V=squeeze(V);
%     niftiwrite(V,string(["niiData\"+inputName(i)+".nii"]));
%     clear V;
% end

intensity = [0 20 40 120 220 1024];
alpha = [0 0 0.15 0.3 0.38 0.5];
color = ([0 0 0; 43 0 0; 103 37 20; 199 155 97; 216 213 201; 255 255 255])/255;
queryPoints = linspace(min(intensity),max(intensity),256);
amap = interp1(intensity,alpha,queryPoints)';
cmap = interp1(intensity,color,queryPoints);

volumeList=dir('niiData'); %nacita si obsah priecinku so spracovanymi volume datami
volumeList(1:2)=[]; %vymaze prve dva zbytocne prvky zo zoznamu priecinkov (. a ..)
volumeCount=length(volumeList);

for i=1:volumeCount
    outputPath=string(volumeList(i).folder);
    resultName(i)=string(volumeList(i).name);
    resultName(i)=erase(resultName(i),".nii");
end

if volumeCount~=sourceCount||recalc==true
    for i=1:sourceCount
        if contains(sourceContent(i).name,'3D')
            single=makeModelSingle(sourcePath,sourceContent(i).name,resultName(i));
            view=volshow(single,"Colormap",cmap,"Alphamap",amap);
        elseif contains(upper(sourceContent(i).name),'SWI')
            [axial,coronal,cor_address,sagittal,sag_address] = makeModelMultiple(sourcePath,sourceContent,resultName);
            if exist('axial','var')&&exist('coronal','var')&&exist('sagittal','var')
                interpVolume=spatialMatrixInterp(axial,coronal,sagittal,cor_address,sag_address,needsRegistration);
%                 view_a=volshow(axial,"Colormap",cmap,"Alphamap",amap);
%                 view_c=volshow(cor_address,"Colormap",cmap,"Alphamap",amap);
%                 view_s=volshow(sag_address,"Colormap",cmap,"Alphamap",amap);
                view_fin=volshow(interpVolume,"Colormap",cmap,"Alphamap",amap);
            end
        else
            fprintf("Nebolo mozne urcit o aky rez ide! Skontrolujte nazov priecinka a spustite spracovanie znovu.\nStlacte akukolvek klavesu pre pokracovanie.\n");
            pause;
            break;
        end
    end
end
%     nazov_suboru=sprintf('/test_export/test%d.png',por);
%     imwrite(cast(snimka,"uint16"),[pwd nazov_suboru],'Alpha',cast(maska,"double"))
%     fprintf('Snimka cislo %d z %d uspesne ulozena!\n',por,pocet);
%     close;