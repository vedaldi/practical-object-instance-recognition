% EVALUATE

imdb = load('data/oxbuild_imdb.mat') ;
load('data/oxbuild_query.mat', 'query') ;

shortlistSize = 100 ;
scores = zeros(1,numel(query)) ;
matches = cell(1,numel(query)) ;

for i = 1:numel(query)
  k = find(imdb.images.id == query(i).imageId) ;
  assert(~isempty(k)) ;

  % database labels for evaluation in retrieval (make sure we
  % ignore the query image too)
  y = - ones(1, numel(imdb.images.id)) ;
  y(query(i).good) = 1 ;
  y(query(i).ok) = 1 ;
  y(query(i).junk) = 0 ;
  y(k) = 0 ;

  results(i).features_time = tic ;
  h = getHistogram(imdb, imdb.images.frames{k}, imdb.images.descrs{k}, query(i).box) ;
  results(i).features_time = toc(results(i).features_time) ;

  % get inverted index scores ;
  results(i).index_time = tic ;
  scores = h' * imdb.index ;
  results(i).index_time = toc(results(i).index_time) ;

  % inverted index evaluation
  [rc,pr,info] = vl_pr(y, scores) ;
  results(i).index_rc = rc ;
  results(i).index_pr = pr ;
  results(i).index_ap = info.ap ;

  % rescores shortlist based on geometric verification
  [~, perm] = sort(scores, 'descend') ;
  results(i).geom_time = tic ;
  for j = vl_colsubset(perm(3:end), shortlistSize, 'beginning') ;
    [scores(j), matches{j}] = ...
        geometricVerification(scores(j), ...
                              imdb.images.frames{k}, imdb.images.descrs{k}, ...
                              imdb.images.frames{j}, imdb.images.descrs{j}) ;

    if 0
      figure(3) ; clf ;
      im0 = imread(fullfile(imdb.dir, imdb.images.name{k})) ;
      im = imread(fullfile(imdb.dir, imdb.images.name{j})) ;
      plotmatches(im0,im, ...
                  imdb.images.frames{k}, ...
                  imdb.images.frames{j}, ...
                  matches{j}) ;
    end
  end
  results(i).geom_time = toc(results(i).geom_time) ;
  [~, perm] = sort(scores, 'descend') ;

  % rescoring evaluation
  [rc,pr,info] = vl_pr(y, scores) ;
  results(i).geom_rc = rc ;
  results(i).geom_pr = pr ;
  results(i).geom_ap = info.ap ;

  fprintf('query %03d: %-20s mAP:%5.2f   mAP+geom:%5.2f\n', i, ...
          query(i).name, results(i).index_ap, results(i).geom_ap) ;

  if 0
    figure(1) ; clf ;
    im0 = imread(fullfile(imdb.dir, imdb.images.name{k})) ;
    imagesc(im0) ; hold on ;
    plotbox(query(i).box, 'linewidth', 5) ;
    axis image off ;

    figure(2) ; clf ;
    for j = 1:4*4
      vl_tightsubplot(4*4, j) ;
      im = imread(fullfile(imdb.dir, imdb.images.name{perm(j)})) ;
      imagesc(im) ;
      axis image off ; hold on ;
      switch y(perm(j))
        case 1, sty = {'color', 'g'} ;
        case 0, sty = {'color', 'y'} ;
        case -1, sty = {'color', 'r'} ;
      end
      plotbox([1,1,size(im,2),size(im,1)]','linewidth',10,sty{:}) ;
      text(0,0,sprintf('%g', full(scores(perm(j)))), ...
           'background', 'w', ...
           'verticalalignment', 'top') ;
    end
  end

  if 0
    figure(3) ; clf ; j = 2 ;
    im = imread(fullfile(imdb.dir, imdb.images.name{perm(j)})) ;
    plotmatches(im0,im, ...
                imdb.images.frames{k}, ...
                imdb.images.frames{perm(j)}, ...
                matches{perm(j)}) ;
  end

  if 0
    figure(10) ; clf ; hold on ;
    plot(results(i).index_rc, results(i).index_pr, 'color', 'b', 'linewidth', 3) ;
    plot(results(i).geom_rc, results(i).geom_pr, 'color', 'g', 'linewidth', 2) ;
    grid on ; axis equal ;
    title(sprintf('%s', query(i).name), 'interpreter', 'none') ;
    legend(sprintf('index: %.2f',results(i).index_ap*100), ...
           sprintf('index+geom: %.2f',results(i).geom_ap*100)) ;
    xlim([0 1]) ;ylim([0 1]);
    drawnow ;
  end
end

fprintf('features: time %.2g\n', ...
        mean([results.features_time])) ;
fprintf('index: mAP: %g, time: %.2f\n', ...
        mean([results.index_ap])*100, ...
        mean([results.index_time])) ;
fprintf('index+geom: mAP: %g, time: %.2f\n', ...
        mean([results.geom_ap])*100, ...
        mean([results.geom_time])) ;
