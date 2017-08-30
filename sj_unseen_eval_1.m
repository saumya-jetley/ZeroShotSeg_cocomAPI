%% SJ-version v.1.00 
%AIM: To store image ground-truth and predictions in COCO JSON format
%     All the predicted categories get single label - 81 (unseen cat label)
%% Built on top of the Demo for the CocoApi (see CocoApi.m)
% Place this .m file in the MATLAB-API folder of coco-master
% Predicted shape masks should be embedded in the image canvas
% Predicted mask names: <image-name>_category_inst<3-digit-id>_sc<confidence score>*.png
clear;
close all;
clc;
% Specify the folder name containing the predictions here:
pred_folder_name = 'zeroshot-sbd-yolo-embedding-c20-sp20-20170822T092107';
% Specify the path of the folder
pred_folder_path = '/media/sjvision/DATASETDISK/shape_detection_extra/coco_unseen_experiments/second_round_detections/';
% Run the following code 
%%------------------------------------------------------------------------------
%% Find the unseen category details in sj_unseen_imagesonly mat file
pred_path = strcat(pred_folder_path, pred_folder_name);
%% initialize COCO api (please specify dataType/annType below)
annTypes = { 'instances', 'captions', 'person_keypoints' };
dataType='val2014'; annType=annTypes{1}; % specify dataType/annType
annFile=sprintf('../../annotations/%s_%s.json',annType,dataType);
coco=CocoApi(annFile);
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
all_ims = coco.getImgIds(); % ids for all images
unseen_ims = setxor(all_ims, pascal_catims);
%% Save the images with unseen categories
% for i=1:size(unseen_ims,1)
%     img = coco.loadImgs(unseen_ims(i));
%     I = imread(sprintf('../../%s/%s',dataType,img.file_name));
%     I = imresize(I, [448 448],'bicubic');
%     imwrite(I,sprintf('../../unseen_category_images/%d_%s',unseen_ims(i),img.file_name));
%     fprintf(fid, sprintf('%d_%s\n',unseen_ims(i),img.file_name(1:end-4)));
% end

%% Collate the images and annotations in the standard format
%% Ground-truth
% coco_unseen_gt = coco;
% coco_unseen_gt.data.images=coco.data.images(1);
% coco_unseen_gt.data.annotations=coco.data.annotations(1);
% counter_gtann=1;
% gt_imgId=[]; gt_annId=[]; gt_annImgIds=[]; gt_imgannid_map={};gt_annCatIds=[];
%% Prediction
coco_unseen_dt = coco;
coco_unseen_dt.data.images=coco.data.images(1);
coco_unseen_dt.data.annotations=struct('image_id','1','category_id','1','score','0.01','bbox','filename','id','1','area','1');
counter_dtann=1;
categories = {coco.data.categories(:).name};
dt_imgId=[]; dt_annId=[]; dt_imgannid_map = {}; temp=[]; dt_annImgIds=[]; dt_annCatIds=[];

for i=1:size(unseen_ims,1)
    
    imgId = unseen_ims(i); 
    annIds = coco.getAnnIds('imgIds',imgId); 
    imDetails = coco.loadImgs(imgId);
    temp=[];
%     % Ground truth file - for unseen cat images
%     coco_unseen_gt.data.images(i)= imDetails;
%     coco_unseen_gt.data.annotations(counter_gtann:counter_gtann+size(annIds,2)-1)= coco.loadAnns(annIds);
%     counter_gtann=counter_gtann+size(annIds,2);
%     gt_imgId= [gt_imgId; imgId];
%     gt_annId = [gt_annId; annIds'];
%     gt_annImgIds = [gt_annImgIds; (ones(size(annIds))*imgId)'];
%     gt_imgannid_map{i}=annIds; 
%     gt_annCatIds = [gt_annCatIds;(ones(size(annIds))*1)'];

%     coco_unseen_gt.inds.imgIds=gt_imgId;
%     coco_unseen_gt.inds.annIds=gt_annId;
%     coco_unseen_gt.inds.annImgIds = gt_annImgIds;
%     coco_unseen_gt.inds.imgAnnIdsMap=gt_imgannid_map;
%     coco_unseen_gt.inds.annCatIds = gt_annCatIds;

    
    % Prediction file - for unseen cat images - image_id and bbox and category_id
    coco_unseen_dt.data.images(i)= imDetails;
    dt_imgId = [dt_imgId; imgId];
    dt_imgannid_map{i} = {};
    % Load all the predictions from the folder (under the image name)
    files = dir(strcat(pred_path,'/*',imDetails.file_name(1:end-4),'*'));
    for j=1:size(files,1)
        pred_dts = strsplit(files(j).name,{'_','sc','*'});
        a.image_id = imgId;
        a.category_id = find(strcmp(categories,pred_dts(5))); 
        a.score = str2num(pred_dts{7});
        a.bbox = files(j).name;
        a.id = counter_dtann;
        D_im = imread(strcat(pred_path,'/',a.bbox));D_im =imresize(D_im,[480,640],'nearest');
        dim = D_im>0;a.area = sum(sum(dim));
        
        dt_annId = [dt_annId; a.id]; 
        temp = [temp a.id];
        
        coco_unseen_dt.data.annotations(counter_dtann)=a;
        counter_dtann = counter_dtann+1;
    end
    dt_annImgIds = [dt_annImgIds; (ones(size(temp))*imgId)'];
    dt_annCatIds = [dt_annCatIds; (ones(size(temp))*1)'];
    dt_imgannid_map{i}=temp; 
end
coco_unseen_dt.inds.imgIds=dt_imgId;
coco_unseen_dt.inds.annImgIds = dt_annImgIds;
coco_unseen_dt.inds.annIds = dt_annId;
coco_unseen_dt.inds.imgAnnIdsMap=dt_imgannid_map;
coco_unseen_dt.inds.annCatIds = dt_annCatIds;


save(strcat(pred_folder_path, pred_folder_name, '.mat'),'coco_unseen_dt');
disp('done');