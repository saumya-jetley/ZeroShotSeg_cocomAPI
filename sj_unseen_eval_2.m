%% Demo demonstrating the algorithm result formats for COCO

%% select results type for demo (either bbox or segm)
type = {'segm','bbox','keypoints'}; type = type{2}; % specify type here
fprintf('Running demo for *%s* results.\n\n',type);
filepath = '/media/sjvision/DATASETDISK/shape_detection/datasets/coco/annotations/unseen_cat/';
%% initialize COCO ground truth api
% cocoGt=CocoApi(annFile);
cocoGt = load(strcat(filepath,'gt_file.mat'));
cocoGt = cocoGt.coco_unseen_gt;

%% initialize COCO detections api
% cocoDt = CocoApi(resFile); %%SJ
cocoDt = load(strcat(filepath,'dt_file_0.05.mat'));
cocoDt = cocoDt.coco_unseen_dt;

%% run COCO evaluation code (see CocoEval.m)
imgIds=sort(cocoGt.getImgIds());
cocoEval=CocoEval(cocoGt,cocoDt,type);
cocoEval.params.imgIds=imgIds;
cocoEval.evaluate();
cocoEval.accumulate();
cocoEval.summarize();

%% generate Derek Hoiem style analyis of false positives (slow)
if(0), cocoEval.analyze(); end
