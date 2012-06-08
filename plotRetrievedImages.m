function plotRetrievedImages(imdb, res, varargin)
% PLOTRETRIEVEDIMAGES  Displays search results
%   PLOTRETRIEVEDIMAGES(IMDB, SCORES) displays the images in the
%   database IMDB that have largest SCORES. SCORES is a row vector of
%   size equal to the number of images in IMDB.

% Author: Andrea Vedaldi

opts.num = 16 ;
opts.labels = [] ;
opts = vl_argparse(opts, varargin) ;

if isstruct(res)
  scores = res.geom.scores ;
else
  scores = res ;
end

[scores, perm] = sort(scores, 'descend') ;
if isempty(opts.labels), opts.labels = zeros(1,numel(scores)) ; end

clf ;

for rank = 1:opts.num
  vl_tightsubplot(opts.num, rank) ;
  ii = perm(rank) ;
  im0 = imread(fullfile(imdb.dir, imdb.images.name{ii})) ;
  data.h(rank) = imagesc(im0) ; axis image off ; hold on ;
  switch opts.labels(ii)
    case 0, cl = 'y' ;
    case 1, cl = 'g' ;
    case -1, cl = 'r' ;
  end
  text(0,0,sprintf('%d: score:%.3g', rank, full(scores(rank))), ...
       'background', cl, ...
       'verticalalignment', 'top') ;

  set(data.h(rank), 'ButtonDownFcn', @zoomIn) ;
end

% for interactive plots
data.imdb = imdb ;
data.perm = perm ;
data.scores = scores ;
data.labels = opts.labels ;
data.res = res ;
guidata(gcf, data) ;

% --------------------------------------------------------------------
function zoomIn(h, event, data)
% --------------------------------------------------------------------
data = guidata(h) ;
rank = find(h == data.h) ;

if ~isstruct(data.res), return ; end

% get query image
if numel(data.res.query.image) == 1
  ii = vl_binsearch(data.imdb.images.id, data.res.query.image) ;
  im1 = imread(fullfile(data.imdb.dir, data.imdb.images.name{ii})) ;
else
  im1 = data.res.query.image ;
end

% get retrieved image
ii = data.perm(rank) ;
im2 = imread(fullfile(data.imdb.dir, data.imdb.images.name{ii})) ;

% plot matches
figure(100) ; clf ;
plotMatches(im1,im2,...
            data.res.features.frames, ...
            data.imdb.images.frames{ii}, ...
            data.res.geom.matches{ii}) ;
