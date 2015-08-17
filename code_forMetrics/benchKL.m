function benchKL()
InputFixationMap = './tmp/fixationMap/';
InputSaliencyMap = './tmp/SaliencyMaps/';
OutputResults = './tmp/results/KL/';
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
        DatasetsTxt = fopen(strcat(OutputResults, 'KL-', DatasetsName, '.txt'), 'w');
        fprintf(DatasetsTxt, '%s\t%s\n', 'Model', 'KL');
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
            KLscore = cell(1, imgNum);
            for curImgNum = 3:(imgNum+2)
                [pathstrFixationMap, nameFixationMap, extFixationMap] = fileparts(strcat(InputFixationMap, idsFixationMap(curImgNum, 1).name));
                [pathstrSaliencyMap, nameSaliencyMap, extSaliencyMap] = fileparts(strcat(InputSaliencyMap, subidsSaliencyMap(curAlgNum, 1).name, '/', subsubidsSaliencyMap(curImgNum, 1).name));
                if strcmp(nameFixationMap, nameSaliencyMap)
                    curSaliencyMap = imread(strcat(InputSaliencyMap, subidsSaliencyMap(curAlgNum, 1).name, '/', subsubidsSaliencyMap(curImgNum, 1).name));
                    curKLscore = calcKLDivscore(fixLocs, curSaliencyMap);
                    KLscore{curImgNum-2} = curKLscore;
                else
                    error('The name of FixationMap and SaliencyMap must be the same');
                end
            end
            KLscore = mean(cell2mat(KLscore), 2);
            saveKLscore = strcat('KL', '_', subidsSaliencyMap(curAlgNum).name);
            eval([saveKLscore, '=', 'KLscore']);
            
            save(outFileName, saveKLscore);
            fprintf(DatasetsTxt, '%f\n', KLscore);
        end
        break;
    end
end