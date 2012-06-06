function res = search(imdb, query, varargin)
% SEARCH  Search the image database
%   RES = SEARCH(IMDB, QUERY)
%

% Author: Andrea Vedaldi

opts.box = [] ;
opts.verbose = true ;
opts = vl_argparse(opts, varargin) ;

% fetch image
if isnumeric(query)
  if numel(query) == 1
    % imageId
    ii = vl_binsearch(imdb.images.id, query) ;
    res.frames = imdb.images.frames{ii} ;
    res.descrs = imdb.images.descrs{ii} ;
  else
    im = query ;
  end
elseif isstr(query)
  im = imread(query) ;
else
  error('IM is neither an image, a path name, a URL, or an image id.') ;
end

% ask for box
if isnan(opts.box)
  figure(1) ; clf ;
  imshow(im) ;
  r = imrect ;
  opts.box = r.getPosition ;
  opts.box(3:4) = opts.box(3:4) + opts.box(1:2) ;
end

% --------------------------------------------------------------------
%                                                       Image features
% --------------------------------------------------------------------
res.features_time = tic ;
if exist('im', 'var')
  [h, res.frames, res.descrs] = getHistogramFromImage(imdb, im, 'box', opts.box) ;
else
  [h, res.frames, res.descrs] = getHistogram(imdb, res.frames, res.descrs, 'box', opts.box) ;
end
res.features_time = toc(res.features_time) ;

% --------------------------------------------------------------------
%                                                       Inverted index
% --------------------------------------------------------------------
res.index_time = tic ;
res.index_scores = h' * imdb.index ;
res.index_time = toc(res.index_time) ;
[~, res.index_perm] = sort(res.index_scores, 'descend') ;

% --------------------------------------------------------------------
%                                               Geometric verification
% --------------------------------------------------------------------
res.geom_time = tic ;
res.geom_scores = res.index_scores ;
res.geom_matches = cell(size(res.geom_scores)) ;
for j = vl_colsubset(res.index_perm, imdb.shortListSize, 'beginning') ;
  if 0, continue ; end
  [ok, matches] = ismember(res.descrs, imdb.images.descrs{j}) ;
  matches = [find(ok) ; matches(ok)] ;
  res.geom_matches{j} = geometricVerification(res.frames, imdb.images.frames{j}, matches) ;
  res.geom_scores(j) = max(res.geom_scores(j), size(res.geom_matches{j},2)) ;

  if 0
    figure(3) ; clf ;
    im0 = imread(fullfile(imdb.dir, imdb.images.name{j})) ;
    plotmatches(im,im0, frames, imdb.images.frames{j}, matches{j}) ;
    keyboard
  end
end
[~, res.geom_perm] = sort(res.geom_scores, 'descend') ;
res.geom_time = toc(res.geom_time) ;

% --------------------------------------------------------------------
%                                                        Visualization
% --------------------------------------------------------------------
if opts.verbose
  figure(2) ; clf ;
  for rank = 1:4*4
    ii = res.geom_perm(rank) ;
    vl_tightsubplot(4*4, rank) ;
    im0 = imread(fullfile(imdb.dir, imdb.images.name{ii})) ;
    imshow(im0) ; axis image off ; hold on ;
    text(0,0,sprintf('%g', full(res.geom_scores(ii))), ...
         'background', 'w', ...
         'verticalalignment', 'top') ;
  end

  figure(3) ; clf ;
  if ~exist('im', 'var')
    ii = vl_binsearch(imdb.images.id, query) ;
    im = imread(fullfile(imdb.dir, imdb.images.name{ii})) ;
    rank = 2 ;
  else
    rank = 1 ;
  end
  ii = res.geom_perm(rank) ;
  im0 = imread(fullfile(imdb.dir, imdb.images.name{ii})) ;
  plotmatches(im,im0, ...
              res.frames, ...
              imdb.images.frames{ii}, ...
              res.geom_matches{ii}) ;
  if ~isempty(opts.box), plotbox(opts.box, 'linewidth', 3, 'color', 'b') ; hold on ; end
end