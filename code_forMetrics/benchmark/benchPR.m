%   This script generates PR curves for all salObjAlgs on all salObjSets.
%   Xiaodi Hou <xiaodi.hou@gmail.com>, 2014
%   Please email me if you find bugs or have questions.
clear; clc;
p = genParams();

%%
for curSet = 1:size(p.salObjSets, 1)
	curSetName = p.salObjSets{curSet};
	imgNum = p.salObjSetSize(curSet);
	for curAlgNum = 1:size(p.salObjAlgs, 1)
		curAlgName = p.salObjAlgs{curAlgNum};
		outFileName = sprintf('%s/pr/%s_%s.mat', p.outputDir, curSetName, curAlgName);
% 		if exist(outFileName, 'file')
% 			if p.verbose
% 				fprintf('Skipping existing file: %s\n', outFileName);
% 			end
% 			continue;
% 		end
		tic
		prec = cell(1, imgNum);
		recall = cell(1, imgNum);
		parfor curImgNum = 1:imgNum
			curAlgMap = im2double(imread(sprintf('%s/%s/%s/%d.png', p.algMapDir, curSetName, curAlgName, curImgNum)));
			curGT = im2double(imread(sprintf('%s/masks/%s/%d.png', p.datasetDir, curSetName, curImgNum)));
			
			[curPrec, curRecall] = prCore.prCount(curGT, curAlgMap, p.smoothOption(curAlgNum), p);
			prec{curImgNum} = curPrec;
			recall{curImgNum} = curRecall;
		end
		prec = mean(cell2mat(prec), 2);
		recall = mean(cell2mat(recall), 2);

		curTime = toc;
		if p.verbose
			fprintf('%s on %s done in %.2f seconds!\n', curAlgName, curSetName, curTime);
		end
		
		% save results
		thList = p.thList;
		save(outFileName, 'prec', 'recall', 'thList');
	end
end

