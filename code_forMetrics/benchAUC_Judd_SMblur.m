function benchAUC_Judd_SMblur()
InputFixationMap = './tmp/fixationMap/';
InputSaliencyMap = './tmp/SaliencyMaps/';
OutputResults = './tmp/results/AUC_Judd_SMblur/';
traverse(InputFixationMap, InputSaliencyMap, OutputResults)

function traverse(InputFixationMap, InputSaliencyMap, OutputResults)
idsFixationMap = dir(InputFixationMap);
for i = 1:length(idsFixationMap)
    if idsFixationMap(i, 1).name(1)=='.'
        continue;
    end
    if idsFixationMap(i, 1).isdir==1
        if ~isdir(strcat(OutputResults, idsFixationMap(i, 1).name, '/'))
            mkdir(strcat(OutputResults, idsFixationMap(i, 1).name, '/'));
        end
        traverse(strcat(InputFixationMap, idsFixationMap(i, 1).name, '/'), strcat(InputSaliencyMap, idsFixationMap(i, 1).name, '/'), strcat(OutputResults, idsFixationMap(i, 1).name, '/'));
    else
        subidsSaliencyMap = dir(InputSaliencyMap); 
        for curAlgNum = 3:length(subidsSaliencyMap)
            fprintf(DatasetsTxt, '%s\t', subidsSaliencyMap(curAlgNum, 1).name);
            outFileName = strcat(OutputResults, subidsSaliencyMap(curAlgNum, 1).name, '.mat');
            subsubidsSaliencyMap = dir(strcat(InputSaliencyMap, subidsSaliencyMap(curAlgNum, 1).name, '/'));
            %% compute the number of images in the dataset
            imgNum = 0;
            for curImgNum = 3:length(subsubidsSaliencyMap)
                try
                    eval(['load ', strcat(InputFixationMap, idsFixationMap(curImgNum, 1).name)]);
                    imread(strcat(InputSaliencyMap, subidsSaliencyMap(curAlgNum, 1).name, '/', subsubidsSaliencyMap(curImgNum, 1).name));
                    imgNum = imgNum+1;
                catch err
                    error('The input FixationMap must be .mat format and the SaliencyMap must be image format');
                end
            end
            %%
            sigmaList = 0:0.01:0.08;
            sigmaLen = length(sigmaList);        
            AUC_Judd_SMblur_score = zeros(sigmaLen, imgNum);
            for curImgNum = 3:(imgNum+2)
                [pathstrFixationMap, nameFixationMap, extFixationMap] = fileparts(strcat(InputFixationMap, idsFixationMap(curImgNum, 1).name));
                [pathstrSaliencyMap, nameSaliencyMap, extSaliencyMap] = fileparts(strcat(InputSaliencyMap, subidsSaliencyMap(curAlgNum, 1).name, '/', subsubidsSaliencyMap(curImgNum, 1).name));
                if strcmp(nameFixationMap, nameSaliencyMap)
                    rawSMap = double(imread(strcat(InputSaliencyMap, subidsSaliencyMap(curAlgNum, 1).name, '/', subsubidsSaliencyMap(curImgNum, 1).name)));
                    if ~isempty(strfind(InputFixationMap, 'bruce'))
                        rawSMap = imresize(rawSMap, [511 681], 'bilinear');
                    elseif ~isempty(strfind(InputFixationMap, 'imgsal'))
                        rawSMap = imresize(rawSMap, [480 640], 'bilinear');
                    elseif ~isempty(strfind(InputFixationMap, 'judd'))
                        load juddSize.mat;
                        rawSMap = imresize(rawSMap, sizeData(str2num(nameFixationMap),:), 'bilinear');
                    elseif ~isempty(strfind(InputFixationMap, 'pascal'))
                        load pascalSize.mat;
                        rawSMap = imresize(rawSMap, sizeData(str2num(nameFixationMap),:), 'bilinear');
                    else
                        rawSMap = imresize(rawSMap, [1080 1920], 'bilinear');
                    end
                    kSizeList = norm(size(rawSMap)).*sigmaList;
                    kNum = length(kSizeList);
                    tmpAUC = zeros(kNum, 1);
                    for curK = 1:kNum
                        kSize = kSizeList(curK);
                        if kSize==0
                            smoothSMap = rawSMap;
                        else
                            curH = fspecial('gaussian', round([kSize, kSize]*5), kSize);	% construct blur kernel
                            smoothSMap = imfilter(rawSMap, curH);
                        end
                        tmpAUC(curK) = AUC_Judd(smoothSMap, fixLocs);
                    end
                    AUC_Judd_SMblur_score(:, curImgNum-2) = tmpAUC;
                else
                    error('The name of FixationMap and SaliencyMap must be the same');
                end
            end
            AUC_Judd_SMblur_score = mean(AUC_Judd_SMblur_score, 2);
            saveAUC_Judd_SMblur_score = strcat('AUC_Judd_SMblur', '_', subidsSaliencyMap(curAlgNum).name);
            eval([saveAUC_Judd_SMblur_score, '=', 'AUC_Judd_SMblur_score']);
            
            save(outFileName, saveAUC_Judd_SMblur_score, 'sigmaList');
        end
        break;
    end
end