% GetMI.m--
% Developed in Matlab 9.14.0.2206163 (R2023a) on PCWIN64
% Copyright Sheffield Teaching Hospitals NHS Foundation Trust 13-08-2024.
% Lloyd Clayburn (lloyd.clayburn@nhs.net), 
%-------------------------------------------------------------------------

function [MI] = GetMI(i, folders, scanner, invert, binarise)

    X=dicomread(folders(i).name);
    X = imresize(X,3);
    if invert == 1
        X=255-X;
    end
    if binarise==1
        if size(X,3)==3 % check that image is rgb
            X=rgb2gray(X);
        end
        X=imbinarize(X);
    end
    if strcmp(scanner, 'Voluson E8')
        roi=[2731.27045795964	135.625746618147	254.174854943445	61.3525511932452];
    elseif strcmp(scanner, 'LOGIQE9')
        roi=[3602.50090915119	8.40282503022706	226.142377788038	93.6180811273060];
    elseif strcmp(scanner, 'HERA W10 Elite')
        roi=[3192.73046357616	10	233.269536423839	100.500000000001];
    elseif strcmp(scanner, 'iU22')
        roi =[2731.66115562271	12.4986035279142	250	91.9635794592020];
    end
    
    % if strcmp(scanner, 'x') % not optimal for all!
    %     ocrResults = ocr(X,roi, LayoutAnalysis="line");
    % else
        ocrResults = ocr(X,roi);
    % end
    
    str=ocrResults.Text;
    % % find 'MI' in text
    if strcmp(scanner, 'Voluson E8') || strcmp(scanner, 'LOGIQE9') || strcmp(scanner, 'HERA W10 Elite') || strcmp(scanner, 'iU22')
        idx=0;
        if isempty(str)
            str='Error';
        else
            for c=1:length(str)-1
                if str(c:c+1)=='MI'
                    idx=c;
                end
            end
            if idx>0
                str=str(idx+3:idx+5);
            else
                str='Error';
            end
        end
    end
    
    % only accept numbers
    % if isempty(str2num(str))
    %     str='Error';
    % end

    if ~strcmp(str,'Error') % if str is not already Error
        % str=num2str(str2num(str)); % workaround to get rid of some weird extra characters
        idx=strfind(ocrResults.Text,str); % find identified text within ocrResults.Text
        % Replace text with 'Error' if confidence for any character within identified text <0.95
        % ocrResults.Text(idx:idx+length(str)-1)
        for i=idx:idx+length(str)-1
            if ocrResults.CharacterConfidences(i)<0.95
                % ocrResults.CharacterConfidences(i)
                str='Error';
            end
        end
    end

    MI=str;
end