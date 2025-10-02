function [sourceContent,sourcePath,inputName,volumeContent,volumePath,volumeName] = loadSourceData()
%LOADSOURCEDATA does exactly what it says on the tin
%   Detailed explanation goes here

sourceContent = [];
sourcePath = '';
% inputName = [];
volumeContent = [];
volumePath = '';
% volumeName = [];

%% uvodny check priecinkov na data

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

sourceCount=length(sourceContent); %spocita kolko priecinkov mame (kolko sad obrazkov mame k dispozicii)

inputName = strings(1, sourceCount); 

for i=1:sourceCount
    sourcePath=string(sourceContent(i).folder);
    inputName(i)=string(sourceContent(i).name);
end

volumeContent=dir('niiData'); %nacita si obsah priecinku so spracovanymi volume datami
volumeContent(1:2)=[]; %vymaze prve dva zbytocne prvky zo zoznamu priecinkov (. a ..)
volumeCount=length(volumeContent);

volumeName = strings(1, sourceCount); 

if volumeCount~=0
    for i=1:volumeCount
        volumePath=string(volumeContent(i).folder);
        volumeName(i)=string(volumeContent(i).name);
        volumeName(i)=erase(volumeName(i),".nii");
    end
end
end

