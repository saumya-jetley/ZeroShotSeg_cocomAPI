%% Built on top of the Demo for the CocoApi (see CocoApi.m)
%% SJ-version v.1.00
%% Need to filter images containing instances of only unseen categories
%%% Pascal seen categories:
% Person: person
% Vehicle: aeroplane, bicycle, boat, bus, car, motorbike, train
% Animal: bird, cat, cow, dog, horse, sheep
% Indoor: bottle, chair, dining-table, potted-plant, sofa, tv/monitor
%%% COCO categories: 
% Person: person, 
% Vehicle: airplane, bicycle, boat, bus, car, motorcycle, train, -- truck,
% Animal: bird, cat, cow, dog, horse, sheep, -- elephant, bear, zebra, giraffe, 
% PascalIndoor: bottle, chair, dining table, potted plant, couch, tv

% Outdoor: traffic light, fire hydrant, stop sign, parking meter, bench, 
% Accessory: backpack, umbrella, handbag, tie, suitcase,
% Sports: frisbee, skis, snowboard, sports ball, kite, baseball bat, baseball glove, skateboard, surfboard, tennis racket, 
% Kitchen: bottle, wine glass, cup, fork, knife, spoon, bowl, 
% Food: banana, apple, sandwich, orange, broccoli, carrot, hot dog, pizza, donut, cake, 
% Furniture: chair, couch, potted plant, bed, dining table, toilet, 
% Electronic: tv, laptop, mouse, remote, keyboard, cell phone,
% Appliance: microwave, oven, toaster, sink, refrigerator,
% Indoor: book, clock, vase, scissors, teddy bear, hair drier, toothbrush, 
%% Steps in code:
% filter images with any of the 20 pascal categories
% all-filtered_images = images with only unseen categories
% rest is history
clear;
close all;
clc;
fid = fopen('val.txt','w');
%% initialize COCO api (please specify dataType/annType below)
annTypes = { 'instances', 'captions', 'person_keypoints' };
dataType='val2014'; annType=annTypes{1}; % specify dataType/annType
annFile=sprintf('../../annotations/%s_%s.json',annType,dataType);
coco=CocoApi(annFile);

%% display COCO categories and supercategories
if( ~strcmp(annType,'captions') )
  cats = coco.loadCats(coco.getCatIds());
  nms={cats.name}; fprintf('COCO categories: ');
  fprintf('%s, ',nms{:}); fprintf('\n');
  nms=unique({cats.supercategory}); fprintf('COCO supercategories: ');
  fprintf('%s, ',nms{:}); fprintf('\n');
end
%% get all images containing any of the 20 pascal categories
pascal_catnms = {'person','airplane','bicycle','boat','bus','car','motorcycle',...
    'train','bird','cat','cow','dog','horse','sheep','bottle','chair',...
    'dining table','potted plant', 'couch', 'tv'};
pascal_catims = [];
for i=1:size(pascal_catnms,2)
    catIds = coco.getCatIds('catNms',{pascal_catnms{i}});
    imgIds = coco.getImgIds('catIds',catIds);
    pascal_catims = [pascal_catims; imgIds];
end
% unique image names
pascal_catims=unique(pascal_catims);
%% Find images only with unseen categories
all_ims = coco.getImgIds();
unseen_ims = setxor(all_ims, pascal_catims);
%% Save the images with unseen categories
for i=1:size(unseen_ims,1)
    img = coco.loadImgs(unseen_ims(i));
    I = imread(sprintf('../../%s/%s',dataType,img.file_name));
    I = imresize(I, [448 448],'bicubic');
    imwrite(I,sprintf('../../unseen_category_images/%d_%s',unseen_ims(i),img.file_name));
    fprintf(fid, sprintf('%d_%s\n',unseen_ims(i),img.file_name(1:end-4)));
end
