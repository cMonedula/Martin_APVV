function [single] = makeModelSingle(sourcePath,sourceContent,resultName)
%MAKEMODELSINGLE Summary of this function goes here
%   Detailed explanation goes here

single=dicomreadVolume([sourcePath+'\'+sourceContent],'MakeIsotropic',true);
single=squeeze(single);
niftiwrite(single,string(["niiData\"+resultName+".nii"]));
% single=niftiread(string(["niiData\"+resultName(i)]));
end

