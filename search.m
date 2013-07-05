function res = search(imdb, query, varargin)
% SEARCH  Search the image database
%   RES = SEARCH(IMDB, QUERY) searches the image database IMDB for the
%   query image QUERY returing a list of results RES.

% Author: Andrea Vedaldi

opts.box = [] ;
opts.verbose = true ;
opts.skipGeometricVerification = false ;
opts = vl_argparse(opts, varargin) ;

% --------------------------------------------------------------------
%                                      Fetch an image and bounding box
% --------------------------------------------------------------------

% fetch image
if isnumeric(query)
  if numel(query) == 1
    % imageId
    ii = vl_binsearch(imdb.images.id, query) ;
    res.features.frames = imdb.images.frames{ii} ;
    res.features.words = imdb.images.words{ii} ;
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
  title('Select a query box') ;
  r = imrect ;
  opts.box = r.getPosition ;
  opts.box(3:4) = opts.box(3:4) + opts.box(1:2) ;
end

res.query.image = im ;
res.query.box = opts.box ;

% --------------------------------------------------------------------
%                                                       Image features
% --------------------------------------------------------------------
res.features.time = tic ;
if exist('im', 'var')
  [res.features.histogram, res.features.frames, res.features.words] = ...
      getHistogramFromImage(imdb, res.query.image, 'box', res.query.box) ;
else
  [hes.features.histogram, res.features.frames, res.features.words] = ...
      getHistogram(imdb, res.features.frames, res.features.words, 'box', res.query.box) ;
end
res.features.time = toc(res.features.time) ;

% --------------------------------------------------------------------
%                                                       Inverted index
% --------------------------------------------------------------------
res.index.time = tic ;
res.index.scores = res.features.histogram' * imdb.index ;
res.index.time = toc(res.index.time) ;
[~, perm] = sort(res.index.scores, 'descend') ;

% --------------------------------------------------------------------
%                                               Geometric verification
% --------------------------------------------------------------------
res.geom.time = tic ;
res.geom.scores = res.index.scores ;
res.geom.matches = cell(size(res.geom.scores)) ;
for j = vl_colsubset(perm, imdb.shortListSize, 'beginning') ;
  if opts.skipGeometricVerification, continue ; end
  matches = matchWords(res.features.words, imdb.images.words{j}) ;
  [inliers,H] = geometricVerification(res.features.frames, imdb.images.frames{j}, matches) ;
  res.geom.matches{j} = matches(:, inliers) ;
  res.geom.scores(j) = max(res.geom.scores(j), numel(inliers)) ;
  res.geom.H{j} = H ;
end
res.geom.time = toc(res.geom.time) ;

fprintf('search: feature time: %.3f s\n', res.features.time) ;
fprintf('search: index time: %.3f s\n', res.index.time) ;
fprintf('search: geometric verification time: %.3f s\n', res.geom.time) ;
