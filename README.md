VIZUALIZÁCIA MRI DÁT - ANATOMICKÉ DÁTA A RELAXOMETRICKÉ MAPY

očakávané vstupy:
priečinky s .dcm snímkami umiestnené do priečinku "sourceData" - pozor, v momentálnej verzii neodporúčam vrstviť podpriečinky, pravdepodobne by to nefungovalo

vstupné priečinky by mali byť pomenované nejak deskriptívne a tak aby vzájomne korešpondovali, skript totiž hľadá kľúčové slová a zisťuje o aký rez ide z názvu priečinka (nie, DICOM metadáta na to použiť nejde)

O PREDSPRACOVANÍ A PODOBNÝCH ADVENTÚRACH

Trojrozmerné skeny (napríklad SWI) má na starosti funkcia spatialMatrixInterp so vstupnými argumentmi axial, coronal, sagital (myslím že celkom self-explanatory, skript je nastavený tak aby zarovnával ostatné pohľady k axiálnemu), cor_address, sag_address (adresy kam sa po registrácii ukladá) a needsRegistration (poväčšine debug boolean, pokiaľ je jeho hodnota false tak sa preskakuje registrácia). Interpoláciu samotnú ovplyvňuje premenná res (zatiaľ rovno vo funkcii) ktorá nastavuje jej rozlíšenie. Výstupom je interpVolume, čo je aritmetický priemer všetkých troch rozmerov.

ŠPECIÁLNE MYSTICKÉ TIPY PRE POUŽÍVATEĽOV
1) pri tvorbe interpolovaného modelu z viacerých sád snímok nezabudnite na meno. vážne, inak neručím za vaše súbory