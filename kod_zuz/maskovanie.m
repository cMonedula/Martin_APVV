clear all;

info=dicominfo("C:\Users\akara\Desktop\Martin_APVV\Data_Dano_poslat\P1_control\3D\P1_T1_FLASH_3D\MRIm020.dcm");
snimka=dicomread(info);

figure
imshow(snimka,[]);