# **What is BOLD5000 v2.0?**

BOLD5000 is a human functional MRI (fMRI) study that includes almost 5,000 distinct images depicting real-world scenes, incorporating images from the Scene UNderstanding (SUN), Common Objects in Context (COCO), and ImageNet datasets. The scale and diversity of these image datasets, combined with a slow event-related fMRI design, enables fine-grained exploration into the neural representation of a wide range of visual features, categories, and semantics. See our Nature Scientific Data paper: [https://www.nature.com/articles/s41597-019-0052-3](https://www.nature.com/articles/s41597-019-0052-3)

**[BOLD5000 v2.0](https://kilthub.cmu.edu/account/home#/collections/5324846) is a complete re-release of functional data from BOLD5000, with optimized procedures for GLM estimation of brain-wide percent signal change in response to the experimental stimuli, yielding significant increases in the reliability of BOLD signal estimates compared to the initial data release.**

**Moving forward, we will continue to update BOLD5000 v2.0 with additional data versions, files for defining functional ROIs, and other relevant additions. If you would like to be notified, please sign up for our listserv [here](https://docs.google.com/forms/d/e/1FAIpQLScdxRc7eKOpZv5Yc6sfzWP5gi0egkDtNSPedVqpvtx_3yw4pg/viewform).**


# **New methods for improved data quality:**

Data included in BOLD5000 v2.0 integrate three techniques designed to improve the accuracy of trial-wise GLM beta estimates:

1.  First, for each voxel, a custom hemodynamic response function (HRF) is identified from a library of candidate functions.
    
2.  Second, the selected HRFs are used in a cross-validated GLM in order to derive a set of optimized noise regressors from voxels unrelated to the experimental paradigm (“[GLMdenoise](https://www.frontiersin.org/articles/10.3389/fnins.2013.00247/full)”; Kay et al., 2013).

3. Third, to mitigate the effects of signal overlap, beta estimates are regularized on a voxel-by-voxel basis using ridge regression (“[Fracridge](https://arxiv.org/pdf/2005.03220v1.pdf)” Kay & Rokem, 2020).

See the “GLM Analysis” section of the newly-available [Natural Scenes Dataset preprint](https://www.biorxiv.org/content/10.1101/2021.02.22.432340v1) for further details on these methods. Code for these approaches will be released in the near future – **if you would like to be notified, please sign up for our listserv [here](https://docs.google.com/forms/d/e/1FAIpQLScdxRc7eKOpZv5Yc6sfzWP5gi0egkDtNSPedVqpvtx_3yw4pg/viewform).**

## **Summary of new data versions:**

The initial release of BOLD5000 v2.0 contains a total of five complete new versions of the functional data, four containing GLM beta estimates of voxel-wise percent signal change in response to experimental stimuli, and one containing whole-brain data preprocessed in an identical manner as the data from specific functional ROIs (e.g. PPA, OPA, LOC, RSC) that were included in the initial BOLD5000 v1.0 release (time-series of residuals from an SPM GLM used to regress out nuisance variables following initial fmriPREP preprocessing; see “fMRI Data Analysis" section of the [BOLD5000 paper](https://www.nature.com/articles/s41597-019-0052-3) for further details).

| Data version descriptor                  | GLM betas vs. residual time-series | HRF opt?       | GLMdenoise? | Ridge regression? | File save format             | Naming scheme                                           |
|------------------------------------------|------------------------------------|----------------|-------------|-------------------|------------------------------|---------------------------------------------------------|
| TYPEA-ASSUMEHRF                          | betas                              | 🚫  (canonical) | 🚫           | 🚫                 | One .nii.gz file per session | CSIX_GLMbetas-TYPEA-ASSUMEHRF_ses-XX.nii.gz            |
| TYBEB-FITHRF                             | betas                              | ✅              | 🚫           | 🚫                 | One .nii.gz file per session | CSIX_GLMbetas-TYBEB-FITHRF_ses-XX.nii.gz               |
| TYPEC-FITHRF-GLMDENOISE                  | betas                              | ✅              | ✅           | 🚫                 | One .nii.gz file per session | CSIX_GLMbetas-TYPEC-FITHRF-GLMDENOISE_ses-XX.nii.gz    |
| TYPED-FITHRF-GLMDENOISE-RR (recommended) | betas                              | ✅              | ✅           | ✅                 | One .nii.gz file per session | CSIX_GLMbetas-TYPED-FITHRF-GLMDENOISE-RR_ses-XX.nii.gz |
| SPM-RESIDUAL *                           | time series of residuals           | 🚫              | 🚫           | 🚫                 | One .nii.gz file per session | CSIX_SPMResids_allsess_TRX.nii.gz                       |

\*  SPM-RESIDUAL version refers to whole-brain data preprocessed in an identical manner to the ROI data described in the [BOLD5000 paper](https://www.nature.com/articles/s41597-019-0052-3), via fmriPrep and SPM.
