clear all; close all;

pocet=length(dir('..\Data_Dano_poslat\P1_control\3D\P1_T1_FLASH_3D\*.dcm'));

info=dicominfo("..\Data_Dano_poslat\P1_control\3D\P1_T1_FLASH_3D\MRIm001.dcm");
snimka=dicomread(info);

figure
imshow(snimka,[]);

maska_elipsa=drawellipse('SemiAxes',[98.2730073590999 101.126692004371],...
        'Center',[135.695774647887 142.185915492958],'RotationAngle',9.79775988274304,'Color',[0.0588235294117647 1 1],...
        'LineWidth',1);

maska=createMask(maska_elipsa);
close;

%% toto ich maskne, exportuje a normalizuje (TBA)
for por=1:pocet
    info=dicominfo(["..\Data_Dano_poslat\P1_control\3D\P1_T1_FLASH_3D\MRIm"+sprintf("%03d",por)+".dcm"]);
    snimka=dicomread(info);

%     figure
%     imshow(snimka,[]);

%     maska_elipsa=drawellipse('SemiAxes',[98.2730073590999 101.126692004371],...
%         'Center',[135.695774647887 142.185915492958],'RotationAngle',9.79775988274304,'Color',[0.0588235294117647 1 1],...
%         'LineWidth',1);

%     maska=createMask(maska_elipsa);
%     imshow(maska)

    snimka_masked=immultiply(snimka,maska);
%     figure()
    imshow(snimka_masked);
    
    nazov_suboru=sprintf('/test_export/test%d.png',por);
    imwrite(cast(snimka,"uint16"),[pwd nazov_suboru],'Alpha',cast(maska,"double"))
    fprintf('Snimka cislo %d z %d uspesne ulozena!\n',por,pocet);
    close;
end