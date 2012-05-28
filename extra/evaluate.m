% EVALUATE

imdb = load('data/oxbuild_imdb.mat') ;
load('data/oxbuild_query.mat', 'query') ;

shortlistSize = 100 ;

for i = 1:numel(query)
  k = find(imdb.images.id == query(i).imageId) ;
  assert(~isempty(k)) ;

  % database labels for evaluation in retrieval (make sure we
  % ignore the query too)
  y = - ones(1, numel(imdb.images.id)) ;
  y(query(i).good) = 1 ;
  y(query(i).ok) = 1 ;
  y(query(i).junk) = 0 ;
  y(k) = 0 ;

  h = getHistogram(imdb, imdb.images.frames{k}, imdb.images.descrs{k}, query(i).box) ;

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
  for j = perm
    scores(j) = geometricVerification(scores(j), ...
                                      imdb.images.frames{k}, imdb.images.descrs{k}, ...
                                      imdb.images.frames{perm(j)}, imdb.images.descrs{perm(j)}) ;
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

  if 1
    figure(1) ; clf ; hold on ;
    imagesc(imread(fullfile(imdb.dir, imdb.images.name{k}))) ;
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

    figure(3) ; clf ; hold on ;
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

fprintf('index: mAP: %g, time: %.2f\n', ...
        mean([results.index_ap])*100, ...
        mean([results.index_time])) ;
fprintf('index+geom: mAP: %g, time: %.2f\n', ...
        mean([results.geom_ap])*100, ...
        mean([results.geom_time])) ;
