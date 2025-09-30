VIZUALIZÁCIA MRI DÁT - ANATOMICKÉ DÁTA A RELAXOMETRICKÉ MAPY

očakávané vstupy:
priečinky s .dcm snímkami umiestnené do priečinku "sourceData" - pozor, v momentálnej verzii neodporúčam vrstviť podpriečinky, pravdepodobne by to nefungovalo

vstupné priečinky by mali byť pomenované nejak deskriptívne a tak aby vzájomne korešpondovali, skript totiž hľadá kľúčové slová a zisťuje o aký rez ide z názvu priečinka (nie, DICOM metadáta na to použiť nejde)

ŠPECIÁLNE MYSTICKÉ TIPY PRE POUŽÍVATEĽOV
1) pri tvorbe interpolovaného modelu z viacerých sád snímok nezabudnite na meno. pre istotu
2) pri nastavovani koregistrácie máp s modelmi odporúčam na prehliadanie snímok použiť nejaký externý nástroj, ktorý je schopný ich zoskupiť a poskytnúť dáta o ich následnosti (napríklad Weasis)