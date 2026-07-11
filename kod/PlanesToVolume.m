function [Volume, X_grid, Y_grid, Z_grid] = PlanesToVolume(dicom_filenames, use_interpolation, progress_message_handle)
% PlanesToVolume: Zloží DICOM rezy z rôznych rovín do jednej 3D matice
% Vstup:
%   dicom_filenames   - cell array (zoznam) ciest k DICOM súborom
%   voxel_size        - rozlíšenie výsledného 3D priestoru v mm (napr. 1.0)
%   use_interpolation - true/false (zapnutie alebo vypnutie dopočítavania dát)
% Výstup:
%   Volume - 3D matica intenzít
%   X_grid, Y_grid, Z_grid - 3D súradnice pre Volume

arguments
    dicom_filenames
    use_interpolation = false
    progress_message_handle = false
end

    function logMsg(msg)
        if nargin >= 1
            if ~isempty(progress_message_handle) && isvalid(progress_message_handle)
                progress_message_handle.Text = msg;
                drawnow;
            else
                disp(msg); % pri zavolani bez appky sa to vypise do command window
            end
        end
    end

info = dicominfo(dicom_filenames{1});

% Získava reálnu veľkosť pixelov v mm (vráti pole [rozstup_riadkov; rozstup_stĺpcov])
rozmery_pixelov = info.PixelSpacing;

% Pre náš 3D priestor vyberieme najmenší rozmer, aby sme nestratili žiadne detaily
voxel_size = min(rozmery_pixelov);

logMsg(['Automaticky zistená veľkosť voxelu: ', num2str(voxel_size), ' mm']);

num_files = length(dicom_filenames);

% Polia pre uloženie súradníc všetkých pixelov zo všetkých rezov
all_X = []; all_Y = []; all_Z = []; all_I = [];

logMsg('Čítam DICOM súbory a rátam priestorové súradnice...');
for i = 1:num_files
    fname = dicom_filenames{i};
    info = dicominfo(fname);
    img = double(dicomread(fname));

    % Extrakcia metadát o polohe
    pos = info.ImagePositionPatient; % [X; Y; Z] ľavého horného rohu
    ori = info.ImageOrientationPatient; % Smerové vektory riadkov a stĺpcov
    ps  = info.PixelSpacing; % [Riadky_spacing; Stĺpce_spacing]

    row_dir = ori(1:3);
    col_dir = ori(4:6);

    [rows_img, cols_img] = size(img);

    % Vytvorenie mriežky indexov pre daný 2D obrázok
    [C, R] = meshgrid(0:cols_img-1, 0:rows_img-1);

    % Výpočet presnej X, Y, Z polohy PRE KAŽDÝ PIXEL v reze
    X = pos(1) + C .* ps(2) .* row_dir(1) + R .* ps(1) .* col_dir(1);
    Y = pos(2) + C .* ps(2) .* row_dir(2) + R .* ps(1) .* col_dir(2);
    Z = pos(3) + C .* ps(2) .* row_dir(3) + R .* ps(1) .* col_dir(3);

    % Prevod matice na stĺpcové vektory
    all_X = [all_X; X(:)];
    all_Y = [all_Y; Y(:)];
    all_Z = [all_Z; Z(:)];
    all_I = [all_I; img(:)];
end

logMsg('Vytváram 3D mriežku (voxel space)...');
% Určenie rozmerov (Bounding box) celého priestoru
min_X = min(all_X); max_X = max(all_X);
min_Y = min(all_Y); max_Y = max(all_Y);
min_Z = min(all_Z); max_Z = max(all_Z);

% Vytvorenie pravidelnej 3D mriežky podľa zvoleného rozlíšenia
x_vec = min_X : voxel_size : max_X;
y_vec = min_Y : voxel_size : max_Y;
z_vec = min_Z : voxel_size : max_Z;
[X_grid, Y_grid, Z_grid] = meshgrid(x_vec, y_vec, z_vec);

% Predalokovanie 3D mriežky NaN hodnotami
[rows, cols, depths] = size(X_grid);
Volume = NaN(rows, cols, depths);

if use_interpolation
    logMsg('Pripravujem interpolovaný model (scatteredInterpolant)...');
    F = scatteredInterpolant(all_X, all_Y, all_Z, all_I, 'linear', 'none');

    logMsg('Dopočítavam súvislý 3D objem (vektorizovane)...');
    % Vyhodnotí úplne všetko naraz bez parfor
    Volume = F(X_grid, Y_grid, Z_grid);

else
    logMsg('Mapujem reálne dáta do 3D objemu...');
    % Výpočet indexov s orezaním na hranice rozmerov matice
    idx_X = round((all_X - min_X) / voxel_size) + 1;
    idx_Y = round((all_Y - min_Y) / voxel_size) + 1;
    idx_Z = round((all_Z - min_Z) / voxel_size) + 1;

    % Poistka proti "Out of range subscript"
    idx_X = max(1, min(idx_X, cols));
    idx_Y = max(1, min(idx_Y, rows));
    idx_Z = max(1, min(idx_Z, depths));

    % Konverzia na lineárny index a zápis reálnych dát
    lin_idx = sub2ind([rows, cols, depths], idx_Y, idx_X, idx_Z);
    Volume(lin_idx) = all_I;
end

Volume = rescale(Volume, 0, 1);

logMsg('Hotovo!');
end