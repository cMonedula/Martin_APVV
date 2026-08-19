# VIZUALIZÁCIA MRI DÁT
Verzia 1.1, pretože 1.0 bola absolútny bolehlav na používanie. Táto verzia prináša kompletne prekopaný systém tvorby modelu bez nutnosti koregistrácie (namiesto toho využíva pozičné dáta uložené priamo v metadátach DICOM súborov) inšpirovaný skriptom MRI Slice Viewer od R. Ouwerkerka[^1] a jednoduchšie grafické rozhranie.

## Prerekvizity
- MATLAB (pri vývoji bola použitá verzia R2026a, ale AppDesigner zaručuje spätnú kompatibilitu približne po verziu R2021b [^2])
  - Image Processing Toolbox
  - Medical Imaging Toolbox
  - ~~Parallel Computing Toolbox~~

## Briefing (extrémne rýchly)
- lokálny klon repozitáru → spustiť `userInterface.mlapp` cez AppDesigner → naplniť priečinok `sourceData` (viď vzorová štruktúra) → navoliť sady dát → vytvoriť model → uložiť model → hotovo! môžete skladať!
- navoliť uložené modely → zobraziť → hotovo! môžete skúmať preložené modely!

## Ako začať
Spravte si lokálny klon repozitáru; otvorte súbor `userInterface.mlapp` a spustite ho cez rozhranie App Designer (Run / F5). Pokiaľ skript nenájde podpriečinky `sourceData` a `savedData`, vytvorí si ich, ale pri absencii podpriečinkov v `sourceData` (viď [Vzorová štruktúra priečinku](#vzorov%C3%A1-%C5%A1trukt%C3%BAra-prie%C4%8Dinku)) sa bude sťažovať na to, že sú prázdne.

Po naplnení priečinku `sourceData` môžete prejsť k tvorbe modelu. TBA

## Vzorová štruktúra priečinku
- kod
  - guiResources
  - *sourceData*
    - priečinok obsahujúci DICOM snímky
      - 01.dcm, 02.dcm, 03.dcm... (na pomenovaní nezáleží, jediná podmienka je, že snímky musia mať kompletné pozičné metedáta)
  - *savedData*
    - meno.mat (uložené dáta pomenované používateľom)

## Moja otázka v tejto dokumentácii nie je zodpovedaná
- [otvorte issue priamo tu v repozitári](https://github.com/cMonedula/Martin_APVV/issues)
- kontaktujte ma

[^1]: Ronald Ouwerkerk (2026). MRI slice viewer (https://www.mathworks.com/matlabcentral/fileexchange/27869-mri-slice-viewer), MATLAB Central File Exchange. Retrieved July 4, 2026. 
[^2]: Compatibility Between Different Releases of App Designer (https://www.mathworks.com/help/matlab/creating_guis/compatibility-between-different-releases-of-app-designer.html), MATLAB Help Center. Retrieved July 6, 2026.
