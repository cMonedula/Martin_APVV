function [axial,coronal,cor_address,sagittal,sag_address] = makeModelMultiple(sourcePath,sourceContent,resultName,useSkips)
%MAKEMODELMULTIPLE Summary of this function goes here
%   Detailed explanation goes here

for i=1:length(sourceContent)
    if contains(sourceContent(i),"axial",'IgnoreCase',true)
        if useSkips.tf==true
            axialFilesDir=dir(sourcePath+'\'+sourceContent(i));
            axialFilesDir(1:2)=[];
            if useSkips.isCoreg==true
                index=useSkips.start.Ax:useSkips.step.Ax:useSkips.stop.Ax;
            elseif isempty(useSkips.stop)==true
                index=useSkips.start:useSkips.step:length(axialFilesDir);
            else
                index=useSkips.start:useSkips.step:useSkips.stop;
            end
            axialFiles=strings(1,length(index));
            for j=1:length(index)
                axialFiles(j)=sourcePath+'\'+sourceContent(i)+'\'+axialFilesDir(index(j)).name;
            end
            axial=dicomreadVolume(axialFiles,'MakeIsotropic',true);
            axial=squeeze(axial);
            axial=imresize3(axial,[256 256 120]);
        else
            axial=dicomreadVolume([sourcePath+'\'+sourceContent(i)],'MakeIsotropic',true);
            axial=squeeze(axial);
        end
        axial=normalizeData(axial);
        niftiwrite(axial,string(["niiData\"+resultName(i)+".nii"]));
        % axial=niftiread(string(["niiData\"+resultName(i)]));
    elseif contains(sourceContent(i),"coronal",'IgnoreCase',true)
        if useSkips.tf==true
            coronalFilesDir=dir(sourcePath+'\'+sourceContent(i));
            coronalFilesDir(1:2)=[];
            if useSkips.isCoreg==true
                index=useSkips.start.Co:useSkips.step.Co:useSkips.stop.Co;
            elseif isempty(useSkips.stop)==true
                index=useSkips.start:useSkips.step:length(coronalFilesDir);
            else
                index=useSkips.start:useSkips.step:useSkips.stop;
            end
            coronalFiles=strings(1,length(index));
            for j=1:length(index)
                coronalFiles(j)=sourcePath+'\'+sourceContent(i)+'\'+coronalFilesDir(index(j)).name;
            end
            coronal=dicomreadVolume(coronalFiles,'MakeIsotropic',false);
        else
            coronal=dicomreadVolume([sourcePath+'\'+sourceContent(i)],'MakeIsotropic',false);
        end
        coronal=imrotate3(imresize3(squeeze(coronal),[256 256 120]),90,[1 0 0]);
%         coronal=flip(coronal,3);
        coronal=normalizeData(coronal);
        niftiwrite(coronal,string(["niiData\"+resultName(i)+".nii"]));
        cor_address=string(["niiData\"+resultName(i)+".nii"]);
        % coronal=niftiread(string(["niiData\"+resultName(i)]));
    elseif contains(sourceContent(i),"sagittal",'IgnoreCase',true)||contains(sourceContent(i),"sagital",'IgnoreCase',true)
        if useSkips.tf==true
            sagittalFilesDir=dir(sourcePath+'\'+sourceContent(i));
            sagittalFilesDir(1:2)=[];
            if useSkips.isCoreg==true
                index=useSkips.start.Sa:useSkips.step.Sa:useSkips.stop.Sa;
            elseif isempty(useSkips.stop)==true
                index=useSkips.start:useSkips.step:length(sagittalFilesDir);
            else
                index=useSkips.start:useSkips.step:useSkips.stop;
            end
            sagittalFiles=strings(1,length(index));
            for j=1:length(index)
                sagittalFiles(j)=sourcePath+'\'+sourceContent(i)+'\'+sagittalFilesDir(index(j)).name;
            end
            sagittal=dicomreadVolume(sagittalFiles,'MakeIsotropic',false);
        else
            sagittal=dicomreadVolume([sourcePath+'\'+sourceContent(i)],'MakeIsotropic',false);
        end
        sagittal=imresize3(squeeze(sagittal),[256 256 120]);
        sagittal=imrotate3(sagittal,90,[-1 0 0]);
        sagittal=imrotate3(sagittal,180,[0 1 0]);
        sagittal=imrotate3(sagittal,270,[0 0 1]);
%         sagittal=flip(sagittal,1);
        sagittal=normalizeData(sagittal);
%         sagittal=flip(sagittal,3);
        niftiwrite(sagittal,string(["niiData\"+resultName(i)+".nii"]));
        sag_address=string(["niiData\"+resultName(i)+".nii"]);
        % sagittal=niftiread(string(["niiData\"+resultName(i)]));
    else
        fprintf("Bolo najdene zobrazenie, nebolo mozne urcit o ake rezy ide! Skontrolujte nazvy priecinkov a spustite spracovanie znovu.\nStlacte akukolvek klavesu pre pokracovanie.\n");
        pause;
        break;
    end
end
end

