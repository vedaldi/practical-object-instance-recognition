function evaluate()
% EVALUATE

% prepare index
switch 13
  case 1, imdbPath = 'data/oxbuild_imdb_100k_disc.mat' ;
  case 2, imdbPath = 'data/oxbuild_imdb_100k_odisc.mat' ;
  case 3, imdbPath = 'data/oxbuild_imdb_100k_ellipse.mat' ;
  case 4, imdbPath = 'data/oxbuild_imdb_100k_oellipse.mat' ;
  case 11, imdbPath = 'data/oxbuild_imdb_100k_disc_hessian2.mat' ;
  case 12, imdbPath = 'data/oxbuild_imdb_100k_odisc_hessian.mat' ;
  case 13, imdbPath = 'data/oxbuild_imdb_100k_ellipse_hessian2.mat' ;
  case 14, imdbPath = 'data/oxbuild_imdb_100k_oellipse_hessian.mat' ;
end
imdb = loadIndex(imdbPath, 'sqrtHistograms', false, 'shortListSize', 200) ;

% run evaluation
load('data/oxbuild_query.mat', 'query') ;
diary([imdbPath(1:end-4) '.txt']) ;
diary on ;
fprintf('imdb:\n') ;
disp(imdb) ;
results = doEvaluation(imdb, query) ;
diary off ;

% --------------------------------------------------------------------
function results = doEvaluation(imdb, query)
% --------------------------------------------------------------------

results = cell(1,numel(query)) ;
for i = 1:numel(query)
  k = find(imdb.images.id == query(i).imageId) ;
  assert(~isempty(k)) ;

  % database labels for evaluation in retrieval (make sure we
  % ignore the query image too)
  y = - ones(1, numel(imdb.images.id)) ;
  y(query(i).good) = 1 ;
  y(query(i).ok) = 1 ;
  y(query(i).junk) = 0 ;
  y(k) = 0 ; % ooops ?

  results{i} = search(imdb, imdb.images.id(k), ...
                      'box', query(i).box, ...
                      'verbose', false) ;

  [rc,pr,info] = vl_pr(y, results{i}.index_scores) ;
  results{i}.index_rc = rc ;
  results{i}.index_pr = pr ;
  results{i}.index_ap = info.ap ;

  [rc,pr,info] = vl_pr(y, results{i}.geom_scores) ;
  results{i}.geom_rc = rc ;
  results{i}.geom_pr = pr ;
  results{i}.geom_ap = info.ap ;

  fprintf('query %03d: %-20s mAP:%5.2f   mAP+geom:%5.2f\n', i, ...
          query(i).name, results{i}.index_ap, results{i}.geom_ap) ;

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

results = cat(2, results{:}) ;

fprintf('features: time %.2g\n', ...
        mean([results.features_time])) ;
fprintf('index: mAP: %g, time: %.2f\n', ...
        mean([results.index_ap])*100, ...
        mean([results.index_time])) ;
fprintf('index+geom: mAP: %g, time: %.2f\n', ...
        mean([results.geom_ap])*100, ...
        mean([results.geom_time])) ;
