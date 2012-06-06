% EXERCISE2: affine co-variant detector

% setup MATLAB to use our software
setup ;

% choose which images to use in the evaluation
imgPaths = {'data/graf/img1.png',...
            'data/graf/img2.png',...
            'data/graf/img3.png',...
            'data/graf/img4.png',...
            'data/graf/img5.png',...
            'data/graf/img6.png'} ;

figure(1) ; clf ;

for o = 1:2
  % Get the features for the reference image
  im1 = imread(imgPaths{1}) ;
  [frames1,descrs1] = getFeatures(im1, 'affineAdaptation',o==2) ;

  for t = 2:numel(imgPaths)
    % Get the feature for another image
    im2 = imread(imgPaths{t}) ;
    [frames2,descrs2] = getFeatures(im2, 'affineAdaptation',o==2) ;

    % Get the feature descriptor neighbours
    [nn, dist2] = findNeighbours(descrs1, descrs2, 2) ;

    % Second nearest neighbour pre-filtering
    nnThreshold = 0.8 ;
    ratio2 = dist2(1,:) ./ dist2(2,:) ;
    ok = ratio2 <= nnThreshold^2 ;
    matches_2nn = [find(ok) ; nn(1,ok)] ;

    % Geometric verification
    inliers = geometricVerification(frames1,frames2,matches_2nn,...
                                    'numRefinementIterations', 3) ;
    matches_geom = matches_2nn(:, inliers) ;

    % Count the number of inliers
    numInliers(t,o) = size(matches_geom,2) ;

    % Visulize
    subplot(numel(imgPaths)-1, 2, (t-2)*2 + o) ;
    plotMatches(im1,im2,frames1,frames2,matches_geom) ;
    if o == 1, title('similarity') ;
    else title('affine') ; end
  end
end

% Quantitative evaluation
figure(100) ; clf ;
plot(2:size(numInliers,1),numInliers(2:end,:),'linewidth', 3) ;
axis tight ; grid on ;
legend('similarity co-variant', 'affine co-variant') ;
xlabel('image pair') ;
ylabel('num. verified feature matches') ;
