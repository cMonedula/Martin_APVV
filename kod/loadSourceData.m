function [sourceContent,sourcePath,inputName,volumeContent,volumePath,volumeName] = loadSourceData(progress_message_handle)
%LOADSOURCEDATA does exactly what it says on the tin
%   Detailed explanation goes here

arguments
    progress_message_handle = false
end

    function logMsg(msg)
        if nargin >= 1
            if ~isempty(progress_message_handle) && isvalid(progress_message_handle)
                progress_message_handle.Text = msg;
                drawnow;
            else
                disp(msg); % pri zavolani bez appky sa to vypise do command window
            end
        end
    end

sourceContent = []; % podpriecinky sourceData
sourcePath = ''; % adresa odkazujuca na sourceData 
inputName = [];
volumeContent = []; % ulozene rekonstruovane modely v savedData
volumePath = ''; % adresa na savedData
volumeName = [];

%% uvodny check priecinkov na data

status = 0;
while status == 0
    status = mkdir('savedData'); %vytvori priecinok na ukladanie volume vystupov vo formate .nii
end

status = mkdir('sourceData'); %vytvori priecinok kam idu data s ktorymi pracujeme, ak este neexistuje
sourceContent = dir('sourceData'); %nacita si obsah priecinku so vstupnymi datami
sourceContent(1:2) = []; %vymaze prve dva zbytocne prvky zo zoznamu priecinkov (. a ..)

if status == 0 || sum([sourceContent.isdir]) == 0
    logMsg("Vstupné dáta neboli úspešne načítané. Naplňte vstupný priečinok sourceData DICOM snímkami rozdelenými do podpriečinkov a znovu spustite ich načítavanie.");
    return;
end

clear status; logMsg("Vstupné dáta úspešne načítané.");

sourceCount = length(sourceContent); %spocita kolko priecinkov mame (kolko sad obrazkov mame k dispozicii)

if sourceCount > 0
    inputName = strings(1, sourceCount); 
    
    for i = 1:sourceCount
        sourcePath = string(sourceContent(i).folder);
        inputName(i) = string(sourceContent(i).name);
    end
end

volumeContent = dir('savedData'); %nacita si obsah priecinku so spracovanymi volume datami
volumeContent(1:2) = []; %vymaze prve dva zbytocne prvky zo zoznamu priecinkov (. a ..)
volumeCount = length(volumeContent);

if volumeCount > 0
    volumeName = strings(1, sourceCount); 

    for i = 1:volumeCount
        volumePath = string(volumeContent(i).folder);
        volumeName(i) = string(volumeContent(i).name);
        volumeName(i) = erase(volumeName(i),".nii");
    end

    logMsg("Uložené modely boli úspešne načítané.")
end

logMsg("Dáta pripravené.")
end

