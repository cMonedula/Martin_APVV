function [sourceContent] = loadSourceData()
%LOADSOURCEDATA does exactly what it says on the tin
%   Detailed explanation goes here

%% uvodny check priecinkov na data
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
end

