% PART II: Affine co-variant detectors

% setup MATLAB to use our software
setup ;

% choose which images to use in the evaluation
imgPaths = {'data/graf/img1.png',...
            'data/graf/img2.png',...
            'data/graf/img3.png',...
            'data/graf/img4.png',...
            'data/graf/img5.png',...
            'data/graf/img6.png'} ;

figure(100) ; clf ; set(gcf, 'name', 'Part II: Affine co-variant detectors - summary') ;

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
    [inliers, H] = geometricVerification(frames1,frames2,matches_2nn,...
                                         'numRefinementIterations', 6) ;
    matches_geom = matches_2nn(:, inliers) ;

    % Count the number of inliers
    numInliers(t,o) = size(matches_geom,2) ;

    % Visualize
    n = (t-2)*2 + o ;
    h = subplot(numel(imgPaths)-1, 2, n, 'parent', 100) ;
    axes(h) ;
    plotMatches(im1,im2,frames1,frames2,matches_geom) ;
    switch o
      case 1, type = 'similarity' ;
      case 2, type = 'affinity' ;
    end
    title(sprintf('From 1 to %d with %s: num: %d', t, type, numInliers(t,o))) ;

    figure(n) ; clf ;
    set(gcf, 'name', sprintf('Part II:  Affine co-variant detectors - from 1 to %d with %s', t,type)) ;
    plotMatches(im1,im2,frames1,frames2,matches_geom,'homography',H) ;
    %c = copyobj(h, gcf) ; set(c, 'position', [0 0 1 1]) ;
    drawnow ;
  end
end

% Quantitative evaluation
figure(101) ; clf ;
set(gcf, 'name', sprintf('Part II: Affine co-variant detectors - quantitative comparison')) ;
plot(2:size(numInliers,1),numInliers(2:end,:),'linewidth', 3) ;
axis tight ; grid on ;
legend('similarity co-variant', 'affine co-variant') ;
xlabel('image pair') ;
ylabel('num. verified feature matches') ;
