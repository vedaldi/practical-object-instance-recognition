% EVALUATE

imdb = load('data/oxbuild_imdb.mat') ;
load('data/oxbuild_query.mat', 'query') ;

shortlistSize = 100 ;

for i = 1:numel(query)
  fprintf('query %03d: %s\n', i, query(i).name) ;
  k = find(imdb.images.id == query(i).imageId) ;
  k = 1 ;
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
  scores = h' * imdb.index ;

  % inverted index evaluation
  [rc,pr,info] = vl_pr(y, scores) ;
  results(i).index_rc = rc ;
  results(i).index_pr = pr ;
  results(i).index_ap = info.ap ;

  % rescores shortlist based on geometric verification
  [~, perm] = sort(scores, 'descend') ;
  for j = perm
    scores(j) = geometicVerification(scores(j), ...
                                     imdb.images.frames{k}, imdb.images.descrs{k}, ...
                                     imdb.images.frames{perm(j)}, imdb.images.descrs{perm(j)}) ;
  end

  % rescoring evaluation
  [rc,pr,info] = vl_pr(y, scores) ;
  results(i).geom_rc = rc ;
  results(i).geom_pr = pr ;
  results(i).geom_ap = info.ap ;
end

fprintf('index map: %g\n', mean([results.index_ap])*100) ;
fprintf('geom map: %g\n', mean([results.geom_ap])*100) ;
