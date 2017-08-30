%% SJ-version v.1.00 
%AIM: To get MAP scores for zero-shot segmentation
%% Built on top of the Demo for the CocoApi (see CocoApi.m)
% Place this .m file in the MATLAB-API folder of coco-master
clear;
close all;
clc;
% Specify the path to the folder containing gt and pred mat files here:
filepath = '/media/sjvision/DATASETDISK/shape_detection_extra/coco_unseen_experiments/second_round_detections/';
% Specify the name of gt mat file:
gt_name = 'gt_file.mat';
% Specify the name of the pred mat file:
pred_name = 'zeroshot-sbd-yolo-embedding-c20-sp20-20170822T092107.mat';
% Specify the folder containing the actual predicted shape masks
det_path = '/media/sjvision/DATASETDISK/shape_detection_extra/coco_unseen_experiments/second_round_detections/zeroshot-sbd-yolo-embedding-c20-sp20-20170822T092107/'; 
% Run the following code 
%%------------------------------------------------------------------------------
%% select results type for demo (either bbox or segm)
type = {'segm','bbox','keypoints','instance_shape'}; type = type{4}; % specify type here
fprintf('Running demo for *%s* results.\n\n',type);
%% initialize COCO ground truth api
% cocoGt=CocoApi(annFile);
cocoGt = load(strcat(filepath, gt_name));
cocoGt = cocoGt.coco_unseen_gt;

%% initialize COCO detections api
% cocoDt = CocoApi(resFile); %%SJ
cocoDt = load(strcat(filepath,pred_name));
cocoDt = cocoDt.coco_unseen_dt;

%% run COCO evaluation code (see CocoEval.m)
imgIds=sort(cocoGt.getImgIds());
cocoEval=CocoEval(cocoGt,cocoDt,type);
cocoEval.params.imgIds=imgIds;
cocoEval.params.detpath=det_path;
cocoEval.evaluate();
cocoEval.accumulate();
cocoEval.summarize();

%% generate Derek Hoiem style analyis of false positives (slow)
if(0), cocoEval.analyze(); end
