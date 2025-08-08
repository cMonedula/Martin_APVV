%vytvarame point cloud, ak sa podari tak by som toto rada volala ako
%jednorazovy skript - raz to zbehne a potom by to uz malo len pristupovat k
%datam ktore si to samo vyrobi (h o p e f u l l y)

clear all; close all;

%%uvodny check priecinkov na data
status=0;
while status==0
    status=mkdir('pointCloudData'); %vytvori priecinok na ukladanie dat ktore ziskame ako vystup z tohto skriptu
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

%% v tejto casti kodu by sa vytvorila maska, ALE kedze budeme nacitavat data z roznych uhlov tak som sa rozhodla to radsej nechat na denoising podla confidence skore
% pocet=length(dir('..\Data_Dano_poslat\P1_control\3D\P1_T1_FLASH_3D\*.dcm'));
% 
% info=dicominfo("..\Data_Dano_poslat\P1_control\3D\P1_T1_FLASH_3D\MRIm001.dcm");
% snimka=dicomread(info);
% 
% figure
% imshow(snimka,[]);
% 
% maska_elipsa=drawellipse('SemiAxes',[98.2730073590999 101.126692004371],...
%         'Center',[135.695774647887 142.185915492958],'RotationAngle',9.79775988274304,'Color',[0.0588235294117647 1 1],...
%         'LineWidth',1);
% 
% maska=createMask(maska_elipsa);
% close;
%% toto si snimky nacita a umiestni (no masking involved)
sourceCount=length(sourceContent); %spocita kolko priecinkov mame (kolko sad obrazkov ideme umiestnovat)
for i=1:sourceCount
    folderPath(i)=[string(sourceContent(i).folder)+'\'+string(sourceContent(i).name)+'\'];
%     folderContent=dir([string(folderPath)+'\*.dcm']); %nacita si obsah priecinku so vstupnymi snimkami
%     folderContent(1:2)=[]; %vymaze prve dva zbytocne prvky zo zoznamu suborov (. a ..)
%     snimkaCount=length(folderContent); %zistime kolko toho mame v priecinku
    sourceTable(i) = dicomCollection(folderPath(i));
    
    V(i) = dicomreadVolume(sourceTable(i),"s1",MakeIsotropic=true);
    V(i) = squeeze(V(i));

    intensity = [0 20 40 120 220 1024];
    alpha = [0 0 0.15 0.3 0.38 0.5];
    color = ([0 0 0; 43 0 0; 103 37 20; 199 155 97; 216 213 201; 255 255 255])/255;
    queryPoints = linspace(min(intensity),max(intensity),256);
    amap = interp1(intensity,alpha,queryPoints)';
    cmap = interp1(intensity,color,queryPoints);

    vol=volshow(V(i),Colormap=cmap,Alphamap=amap);
end

% for por=1:snimkaCount
%     info=dicominfo([folderPath+"\Data_Dano_poslat\P1_control\3D\P1_T1_FLASH_3D\MRIm"+sprintf("%03d",por)+".dcm"]);
%     snimka=dicomread(info);
%     
%     %     figure
%     %     imshow(snimka,[]);
%     
%     %     maska_elipsa=drawellipse('SemiAxes',[98.2730073590999 101.126692004371],...
%     %         'Center',[135.695774647887 142.185915492958],'RotationAngle',9.79775988274304,'Color',[0.0588235294117647 1 1],...
%     %         'LineWidth',1);
%     
%     %     maska=createMask(maska_elipsa);
%     %     imshow(maska)
%     
%     snimka_masked=immultiply(snimka,maska);
%     %     figure()
%     imshow(snimka_masked);
%     
%     nazov_suboru=sprintf('/test_export/test%d.png',por);
%     imwrite(cast(snimka,"uint16"),[pwd nazov_suboru],'Alpha',cast(maska,"double"))
%     fprintf('Snimka cislo %d z %d uspesne ulozena!\n',por,pocet);
%     close;
% end