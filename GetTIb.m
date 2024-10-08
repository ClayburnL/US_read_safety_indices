% GetTIb.m--
% Developed in Matlab 9.14.0.2206163 (R2023a) on PCWIN64
% Copyright Sheffield Teaching Hospitals NHS Foundation Trust 13-08-2024.
% Lloyd Clayburn (lloyd.clayburn@nhs.net), 
%-------------------------------------------------------------------------

function [TIb] = GetTIb(i, folders, scanner, invert, binarise)

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
        roi=[2730.52078131398	72.6529083827188	254.174854943445	61.3525511932452]; % TIb
    elseif strcmp(scanner, 'LOGIQE9')
        roi=[3884.50633800060	13.8606872189131	258.338810264466	93.6180811273060];
    elseif strcmp(scanner, 'HERA W10 Elite')
        roi=[2952.05878603867	98.7476810919509	233.269536423839	100.500000000001];
    elseif strcmp(scanner, 'iU22')
        roi =[2464	10	250	100];
    end
    
    % if strcmp(scanner, 'iU22') % not optimal for all!
    %     ocrResults = ocr(X,roi, LayoutAnalysis="line");
    % else
        ocrResults = ocr(X,roi);
    % end
    
    str=ocrResults.Text;
    % str

    % find 'b' from TIb in text
    if strcmp(scanner, 'Voluson E8') || strcmp(scanner, 'LOGIQE9') || strcmp(scanner, 'HERA W10 Elite')
        idx=0;
        if isempty(str)
            str='Error';
        else
            for c=1:length(str)-1
                if str(c)=='b'
                    idx=c;
                end
            end
            if idx>0
                str=str(idx+2:idx+5);
            end
        end
    elseif strcmp(scanner, 'iU22')
        idx=0;
        if isempty(str)
            str='Error';
        else
            for c=1:length(str)-1
                if str(c)=='B'
                    idx=c;
                end
            end
            if idx>0
                if length(str)>idx+2
                    str=str(idx+1:idx+3);
                else
                    str='Error';
                end
            end
        end
    end

    % % only accept numbers
    % if isempty(str2num(str))
    %     str='Error';
    % end

    % disp(str)
    
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

    TIb=str;
end