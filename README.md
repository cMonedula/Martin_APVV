VIZUALIZÁCIA MRI DÁT - ANATOMICKÉ DÁTA A RELAXOMETRICKÉ MAPY

očakávané vstupy:
priečinky s .dcm snímkami umiestnené do priečinku "sourceData" - pozor, v momentálnej verzii neodporúčam vrstviť podpriečinky, pravdepodobne by to nefungovalo
vstupné priečinky by mali byť pomenované nejak deskriptívne a tak aby vzájomne korešpondovali, skript totiž hľadá podobnosť v názvoch a zisťuje o aký rez ide z názvu priečinka (nie, DICOM metadáta na to použiť nejde)

proces filtrovania priečinkov (tieto menovacie konvencie odporúčam dodržať keď pracujete so skriptom cez MATLAB, až bude GUI tak to nebude nutné):
1) hľadá označenie 3D sekvencií "3D" - separuje do premennej 3Dsource
2) hľadá označenie SWI - tu neodporúčam dávať naraz viacero sekvencií, asi to nebude fungovať. do premennej SWIsource sa ukladá v poradí axial, coronal, sagittal