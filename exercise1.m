% PART I: basic features

% setup MATLAB to use our software
setup ;

% --------------------------------------------------------------------
%                                    Stage I.A: SIFT features detection
% --------------------------------------------------------------------

% Load the two images
im1 = imread('data/oxbuild_images/all_souls_000002.jpg') ;
im2 = imread('data/oxbuild_images/all_souls_000015.jpg') ;

% Compute SIFT features for each
[frames1, descrs1] = getFeatures(im1, 'peakThreshold', 0.001) ;
[frames2, descrs2] = getFeatures(im2, 'peakThreshold', 0.001) ;

figure(1) ;
subplot(1,2,1) ; imagesc(im1) ; axis equal off ; hold on ;
vl_plotframe(frames1, 'linewidth', 2) ;

subplot(1,2,2) ; imagesc(im2) ; axis equal off ; hold on ;
vl_plotframe(frames2, 'linewidth', 2) ;

% Rotate the second image
im3 = imrotate(im2,35,'bilinear') ;
[frames3, descrs3] = getFeatures(im3, 'peakThreshold', 0.001) ;

figure(2) ;
subplot(1,2,1) ; imagesc(im2) ; axis equal off ; hold on ;
vl_plotframe(frames2, 'linewidth', 2) ;

subplot(1,2,2) ; imagesc(im3) ; axis equal off ; hold on ;
vl_plotframe(frames3, 'linewidth', 2) ;

% --------------------------------------------------------------------
%     Stage I.B: SIFT features descriptors and matching between images
% --------------------------------------------------------------------

% Visualize SIFT descriptors (only a few)
figure(3) ; clf ; imagesc(im1) ; axis equal off ;
vl_plotsiftdescriptor(descrs1(:,1:50:end), ...
                      frames1(:,1:50:end)) ;

% Find for each desriptor in im1 the closest descriptor in im2
nn = findNeighbours(descrs1, descrs2) ;

% Construct a matrix of matches. Each column stores two index of
% matching features in im1 and im2
matches = [1:size(descrs1,2) ; nn(1,:)] ;

% Display the matches
figure(4) ; clf ;
plotMatches(im1,im2,frames1,frames2,matches) ;
title('Nearest neighbour matches') ;

% --------------------------------------------------------------------
%  Stage I.C: Better matching (i) Lowe's second nearest neighbour test
% --------------------------------------------------------------------

% Find the top two neighbours as well as their distances
[nn, dist2] = findNeighbours(descrs1, descrs2, 2) ;

% Accept neighbours if their second best match is sufficiently far off
nnThreshold = 0.8 ;
ratio2 = dist2(1,:) ./ dist2(2,:) ;
ok = ratio2 <= nnThreshold^2 ;

% Construct a list of filtered matches
matches_2nn = [find(ok) ; nn(1, ok)] ;

% Display the matches
figure(5) ; clf ;
plotMatches(im1,im2,frames1,frames2,matches_2nn) ;
title('Matches filtered by the second nearest neighbour test') ;

% --------------------------------------------------------------------
%             Stage I.D: Better matching (ii) geometric transformation
% --------------------------------------------------------------------

inliers = geometricVerification(frames1, frames2, matches_2nn) ;
matches_geo = matches_2nn(:, inliers) ;

% Display the matches
figure(6) ; clf ;
plotMatches(im1,im2,frames1,frames2,matches_geo) ;
title('Matches filtered by geometric verification') ;
