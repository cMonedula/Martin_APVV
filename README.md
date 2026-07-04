# VIZUALIZÁCIA MRI DÁT
Verzia 1.1, pretože 1.0 bola absolútny bolehlav na používanie. Táto verzia prináša kompletne prekopaný systém tvorby modelu bez nutnosti koregistrácie (namiesto toho využíva pozičné dáta uložené priamo v metadátach DICOM súborov) inšpirovaný skriptom MRI Slice Viewer od R. Ouwerkerka[^1] a jednoduchšie grafické rozhranie.

## Prerekvizity
- MATLAB (pri vývoji bola použitá verzia R2026a, ale AppDesigner zaručuje spätnú kompatibilitu približne po verziu R2021b)
  - Image Processing Toolbox
  - Medical Imaging Toolbox
  - Parallel Computing Toolbox (voliteľné, využíva sa pri zrýchlení interpolačných výpočtov)

## Rýchly štart
Táto verzia skriptu by mala byť priateľskejšia na používanie než verzia 1.0. Spravte si lokálny klon repozitáru; otvorte si súbor `userInterface.mlapp` a spustite ho. Pokiaľ skript nenájde podpriečinky `sourceData` a `savedData`, vytvorí si ich, ale bude sa sťažovať na to, že sú prázdne.

Po naplnení priečinku `sourceData` môžete prejsť k tvorbe modelu. TBA

## Vzorová štruktúra priečinku
- kod
  - guiResources
  - *sourceData*
    - priečinok obsahujúci DICOM snímky
      - 01.dcm, 02.dcm, 03.dcm... (na pomenovaní nezáleží, jediná podmienka je, že snímky musia mať kompletné pozičné metedáta)
  - *savedData*
    - meno.nii (uložené dáta pomenované používateľom)

[^1]: Ronald Ouwerkerk (2026). MRI slice viewer (https://www.mathworks.com/matlabcentral/fileexchange/27869-mri-slice-viewer), MATLAB Central File Exchange. Retrieved July 4, 2026. 
