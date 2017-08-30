# ZeroShotSeg_cocomAPI
COCO Matlab API repurposed to evaluate zero-shot segmentation performance on unseen categories i.e. the 60 COCO categories that are not in common with the 20 categories of the PASCAL dataset.

Includes 3 additions:

- sj_UnseenCat_SaveImages.m
    - Saves coco-images that contain objects all which must belong to categories not in the 20 PascalVOC categories.

- sj_unseen_eval_1.m
    - Stores ground-truth and predictions (for all the images saved above) in COCO JSON format as separate .mat files
%     (All the predicted categories get single label - 81 (unseen cat label))

- sj_unseen_eval_2.m
    - Estimates MAP scores for zero-shot segmentation performance on the images of unseen categories saved in step-1 and predicted using [Straight to shapes](https://arxiv.org/abs/1611.07932) approach implemented as [this](https://github.com/torrvision/straighttoshapes).




