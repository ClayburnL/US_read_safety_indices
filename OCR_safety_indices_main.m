% OCR_safety_indices_main.m--
% Developed in Matlab 9.14.0.2206163 (R2023a) on PCWIN64
% Copyright Sheffield Teaching Hospitals NHS Foundation Trust 13-08-2024.
% Lloyd Clayburn (lloyd.clayburn@nhs.net), 
%-------------------------------------------------------------------------

% Code dir: C:\Users\clayb\OneDrive\Documents\STP\US\Y3\OCR_safety_indices\USQA-main
% Inputs: target folder, outputs: results

% WIP: only looked at a subset of scanners with minimal tweaking so far, and no TIC
% needs more thorough training and test
% needs better distinguishing of TIS and TIB

%% Training data
% cd('C:\Users\clayb\OneDrive\Documents\STP\US\Y3\OCR_safety_indices\Jan training data\GE_2018-00856\01')
cd('C:\Users\clayb\OneDrive\Documents\STP\US\Y3\OCR_safety_indices\LC\Decomp_Files_1'); % lung
% cd('C:\Users\clayb\OneDrive\Documents\STP\US\Y3\OCR_safety_indices\LC\Decomp_Files_2'); % obs
% cd('C:\Users\clayb\OneDrive\Documents\STP\US\Y3\OCR_safety_indices\LC\Decomp_Files_3'); % eye

% initialise
invert=1; % black on white easiest to read, and sometimes text is highlighted (inverted)
binarise=0; % threshold to increase contrast
layout='auto'; % text layout parameter can influence results

folders=dir('*.*');
scannerID=split(folders(1).folder, '\');
scannerID=scannerID{length(scannerID)-1};

scannerModel=dicominfo(folders(3).name).ManufacturerModelName;
date=dicominfo(folders(3).name).StudyDate;

results=cell((length(folders)-2),3); % MI, TIs, TIb

for im=1:(length(folders)-2) % for each image

    % Get MI
    results{im,1}=GetMI(im+2, folders, scannerModel, invert, binarise);
    if(strcmp(results{im,1}, 'Error')) % if error, try again with different parameters
            results{im,1}=GetMI(im+2, folders, scannerModel, invert, 1);
    end
    if(strcmp(results{im,1}, 'Error')) % if error, prompt for manual input
        image_data=dicomread(folders(im+2).name);
        disp('Read MI');
        pause(1)
        figure;imshow(image_data);
        pause(1)
        close(gcf);
        results{im,1}=num2str(input('Please enter MI: \n'));
    end

    % Get TIs
    results{im,2}=GetTIs(im+2, folders, scannerModel, invert, binarise);
    if(strcmp(results{im,2}, 'Error')) % if error, try again with different parameters
        results{im,2}=GetTIs(im+2, folders, scannerModel, invert, 1);
    end
    if(strcmp(results{im,2}, 'Error')) % if error, prompt for manual input
        image_data=dicomread(folders(im+2).name);
        disp('Read TIs');
        pause(1)
        figure;imshow(image_data);
        pause(1)
        close(gcf);
        results{im,2}=num2str(input('Please enter TIs: \n'));
    end

    % Get TIb
    results{im,3}=GetTIb(im+2, folders, scannerModel, invert, binarise);
     if(strcmp(results{im,3}, 'Error')) % if error, try again with different parameters
        results{im,3}=GetTIb(im+2, folders, scannerModel, invert, 1);
    end
    if(strcmp(results{im,3}, 'Error')) % if error, prompt for manual input
        image_data=dicomread(folders(im+2).name);
        disp('Read TIb');
        pause(1)
        figure;imshow(image_data);
        pause(1)
        close(gcf);
        results{im,3}=num2str(input('Please enter TIb: \n'));
    end
end