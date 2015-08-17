function benchAUC_Borji()
InputFixationMap = './tmp/fixationMap/';
InputSaliencyMap = './tmp/SaliencyMaps/';
OutputResults = './tmp/results/AUC_Borji/';
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
        series=regexp(OutputResults, '/');
        DatasetsName=OutputResults((series(end-1)+1):(series(end)-1));
        DatasetsTxt = fopen(strcat(OutputResults, 'AUC_Borji-', DatasetsName, '.txt'), 'w');
        fprintf(DatasetsTxt, '%s\t%s\n', 'Model', 'AUC_Borji');
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
            AUC_Borji_score = cell(1, imgNum);
            for curImgNum = 3:(imgNum+2)
                [pathstrFixationMap, nameFixationMap, extFixationMap] = fileparts(strcat(InputFixationMap, idsFixationMap(curImgNum, 1).name));
                [pathstrSaliencyMap, nameSaliencyMap, extSaliencyMap] = fileparts(strcat(InputSaliencyMap, subidsSaliencyMap(curAlgNum, 1).name, '/', subsubidsSaliencyMap(curImgNum, 1).name));
                if strcmp(nameFixationMap, nameSaliencyMap)
                    curSaliencyMap = double(imread(strcat(InputSaliencyMap, subidsSaliencyMap(curAlgNum, 1).name, '/', subsubidsSaliencyMap(curImgNum, 1).name)));
                    curAUC_Borji_score = AUC_Borji(curSaliencyMap, fixLocs);
                    AUC_Borji_score{curImgNum-2} = curAUC_Borji_score;
                else
                    error('The name of FixationMap and SaliencyMap must be the same');
                end
            end
            AUC_Borji_score = mean(cell2mat(AUC_Borji_score), 2);
            saveAUC_Borji_score = strcat('AUC_Borji', '_', subidsSaliencyMap(curAlgNum).name);
            eval([saveAUC_Borji_score, '=', 'AUC_Borji_score']);
            
            save(outFileName, saveAUC_Borji_score);
            fprintf(DatasetsTxt, '%f\n', AUC_Borji_score);
        end
        break;
    end
end