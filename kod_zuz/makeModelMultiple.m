function [axial,coronal,cor_address,sagittal,sag_address] = makeModelMultiple(sourcePath,sourceContent,resultName)
%MAKEMODELMULTIPLE Summary of this function goes here
%   Detailed explanation goes here
for i=1:length(sourceContent)
    if contains(lower(sourceContent(i)),'axial')
                axial=dicomreadVolume([sourcePath+'\'+sourceContent(i)],'MakeIsotropic',true);
                axial=squeeze(axial);
                axial=normalizeData(axial);
                niftiwrite(axial,string(["niiData\"+resultName(i)+".nii"]));
                % axial=niftiread(string(["niiData\"+resultName(i)]));
            elseif contains(lower(sourceContent(i)),'coronal')
                coronal=dicomreadVolume([sourcePath+'\'+sourceContent(i)],'MakeIsotropic',false);
                coronal=imrotate3(imresize3(squeeze(coronal),[256 256 120]),90,[1 0 0]);
                coronal=normalizeData(coronal);
                niftiwrite(coronal,string(["niiData\"+resultName(i)+".nii"]));
                cor_address=string(["niiData\"+resultName(i)+".nii"]);
                % coronal=niftiread(string(["niiData\"+resultName(i)]));
            elseif contains(lower(sourceContent(i)),'sagittal')||contains(lower(sourceContent(i)),'sagital')
                sagittal=dicomreadVolume([sourcePath+'\'+sourceContent(i)],'MakeIsotropic',false);
                sagittal=imresize3(squeeze(sagittal),[256 256 120]);
                sagittal=imrotate3(sagittal,90,[-1 0 0]);
                sagittal=imrotate3(sagittal,180,[0 1 0]);
                sagittal=imrotate3(sagittal,270,[0 0 1]);
                sagittal=flip(sagittal,1);
                sagittal=normalizeData(sagittal);
                % sagittal=flip(sagittal,2);
                niftiwrite(sagittal,string(["niiData\"+resultName(i)+".nii"]));
                sag_address=string(["niiData\"+resultName(i)+".nii"]);
                % sagittal=niftiread(string(["niiData\"+resultName(i)]));
            else
                fprintf("Bolo najdene SWI zobrazenie, nebolo mozne urcit o aky rez ide! Skontrolujte nazov priecinka a spustite spracovanie znovu.\nStlacte akukolvek klavesu pre pokracovanie.\n");
                pause;
                break;
   end
end
end

