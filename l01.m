% CT-Daten laden
V = niftiread('ThoracicCT.dcm.nii.gz');

% Bilddaten korrekt permutieren (Achsentausch für richtige Orientierung)
prop = sliceViewer(permute(V, [2,1,3]));

% Abdomen-Slice auswählen (z. B. ca. Slice 50 mit sichtbarer Leber)
% Manuell im sliceViewer mit Schieberegler

% Leber-HU-Fenster definieren (typisch: 30–70 HU)
minHU = -76;
maxHU =-75;

% Fensterung explizit setzen 
prop.DisplayRange(1) = minHU;
prop.DisplayRange(2) = maxHU;

% Radiologische Darstellung (C/W)
C = (minHU + maxHU)/2;
W =( maxHU - minHU);

fprintf('min = %d, max = %d --> C = %.1f, W = %.1f\n', minHU, maxHU, C, W);

