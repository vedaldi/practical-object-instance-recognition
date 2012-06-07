function plotRetrievedImages(imdb, res, varargin)
% PLOTRETRIEVEDIMAGES
%   PLOTRETRIEVEDIMAGES(IMDB, SCORES)

opts.num = 16 ;
opts.labels = [] ;
opts = vl_argparse(opts, varargin) ;

if isstruct(res)
  scores = res.geom.scores ;
end

[scores, perm] = sort(scores, 'descend') ;
if isempty(opts.labels), opts.labels = zeros(1,numel(scores)) ; end

for rank = 1:opts.num
  vl_tightsubplot(opts.num, rank) ;
  ii = perm(rank) ;
  im0 = imread(fullfile(imdb.dir, imdb.images.name{ii})) ;
  imshow(im0) ; axis image off ; hold on ;
  switch opts.labels(ii)
    case 0, cl = 'y' ;
    case 1, cl = 'g' ;
    case -1, cl = 'r' ;
  end
  text(0,0,sprintf('%d: score:%.3g', rank, full(scores(ii))), ...
       'background', cl, ...
       'verticalalignment', 'top') ;
end
