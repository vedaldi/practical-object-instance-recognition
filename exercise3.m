% PART III: Towards large-scale retrieval

% --------------------------------------------------------------------
% Stage III.A:
% --------------------------------------------------------------------

% Load a visual word vocabulary
load('data/oxbuild_imdb_100k_disc_hessian.mat', 'vocab', 'kdtree') ;

% Load the two images
im1 = imread('data/oxbuild_images/all_souls_000002.jpg') ;
im2 = imread('data/oxbuild_images/all_souls_000015.jpg') ;

% Compute SIFT features for each
[frames1, descrs1] = getFeatures(im1, 'peakThreshold', 0.001, 'orientation', false) ;
[frames2, descrs2] = getFeatures(im2, 'peakThreshold', 0.001, 'orientation', false) ;

% Quantise the descritpors
words1 = vl_kdtreequery(kdtree, vocab, descrs1, 'maxNumComparisons', 1024) ;
words2 = vl_kdtreequery(kdtree, vocab, descrs2, 'maxNumComparisons', 1024) ;

% Get the matches based on the raw descriptors
tic ;
[nn, dist2] = findNeighbours(descrs1, descrs2, 2) ;
nnThreshold = 0.8 ;
ratio2 = dist2(1,:) ./ dist2(2,:) ;
ok = ratio2 <= nnThreshold^2 ;
matches_raw = [find(ok) ; nn(1,ok)] ;
time_raw = toc ;

% Get the matches based on the quantized descriptors
tic ;
[ok, matches] = ismember(words1, words2) ;
matches_word = [find(ok) ; matches(ok)] ;
time_word = toc;

% Count inliers
inliers_raw = geometricVerification(frames1,frames2,matches_raw,'numRefinementIterations', 3) ;
inliers_word = geometricVerification(frames1,frames2,matches_word,'numRefinementIterations', 3) ;

figure(1) ; clf ;
subplot(2,1,1) ; plotmatches(im1,im2,frames1,frames2,matches_raw(:,inliers_raw)) ;
title(sprintf('Verified matches on raw descritpors (%d, time %.3g s)',numel(inliers_raw),time_raw)) ;

subplot(2,1,2) ; plotmatches(im1,im2,frames1,frames2,matches_word(:,inliers_word)) ;
title(sprintf('Verified matches on visual words (%d, time %.3g s)',numel(inliers_word),time_word)) ;

% --------------------------------------------------------------------
% Stage III.B:
% --------------------------------------------------------------------
