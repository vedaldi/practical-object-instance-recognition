function plotRetrievedImages(imdb, res, varargin)
% PLOTRETRIEVEDIMAGES  Displays search results
%   PLOTRETRIEVEDIMAGES(IMDB, SCORES) displays the images in the
%   database IMDB that have largest SCORES. SCORES is a row vector of
%   size equal to the number of images in IMDB.

% Author: Andrea Vedaldi and Mireca Cimpoi

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

clf('reset') ;

for rank = 1:opts.num
  vl_tightsubplot(opts.num, rank) ;
  ii = perm(rank) ;
  im0 = getImage(imdb, ii, true) ;
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
function im = getImage(imdb, ii, thumb)
% --------------------------------------------------------------------
imPath = fullfile(imdb.dir, imdb.images.name{ii}) ;
im = [] ;

if exist(imPath, 'file'), im = imread(imPath) ; end

if isempty(im) && isfield(imdb.images, 'wikiName')
  name = imdb.images.wikiName{ii} ;
  [~,~,url,thumbUrl] = getWikiImageUrl(name) ;
  if thumb
    fprintf('Downloading thumbnail ''%s'' (%s)\n', thumbUrl, name) ;
    if ~isempty(thumbUrl), im = imread(thumbUrl) ; end
  else
    fprintf('Downloading image ''%s'' (%s)\n', url, name) ;
    im = imread(url) ;
    if ~thumb
      width = size(im,1) ;
      height = size(im,2) ;
      scale = min([1, 1024/width, 1024/height]) ;
      im = imresize(im, scale) ;
    end
  end
end

if isempty(im)
  im = checkerboard(10,10) ;
  warning('Could not retrieve image ''%s''', imdb.images.name{ii}) ;
end

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
im2 = getImage(data.imdb, ii, false) ;

% plot matches
figure(100) ; clf('reset') ;
plotMatches(im1,im2,...
            data.res.features.frames, ...
            data.imdb.images.frames{ii}, ...
            data.res.geom.matches{ii}, ...
            'homography', data.res.geom.H{ii}) ;

% if we have a wikipedia page, try opening the URL too
if isfield(data.imdb.images, 'wikiName')
  name = data.imdb.images.wikiName{ii} ;
  urls = getWikiPageContainingImage(name) ;
  for i=1:numel(urls)
    fprintf('Found wikipedia page: %s\n', urls{i}) ;
  end
  if length(urls) > 0
    fprintf('Opening first page %s\n', urls{1}) ;
    web('url',urls{1}) ;
  else
    warning('Could not find an Wikipedia page containing %s', name) ;
  end
  return ;
end

% --------------------------------------------------------------------
function [comment, descUrl, imgUrl, thumbUrl] = getWikiImageUrl(imgTitle)
% --------------------------------------------------------------------

% thumb size
x='iiurlwidth=240' ;
query = sprintf(['https://en.wikipedia.org/w/api.php?'...
                 'action=query&prop=imageinfo&format=xml&iiprop=url|'...
                 'parsedcomment&%siilimit=1&titles=%s'], ...
                x,urlencode(imgTitle)) ;
content = urlread(query);

m = regexp(content, 'parsedcomment="(?<x>[^"]*)"', 'names') ;
comment = m.x ;

m = regexp(content, ' url="(?<x>[^"]*)"', 'names') ;
imgUrl = m.x ;

m = regexp(content, 'thumburl="(?<x>[^"]*)"', 'names') ;
thumbUrl = m.x ;

m = regexp(content, 'descriptionurl="(?<x>[^"]*)"', 'names') ;
descUrl = m.x ;

% -------------------------------------------------------------------
function urlList = getWikiPageContainingImage(wikiTitle)
% -------------------------------------------------------------------
urlList = {};
query = [...
  'https://en.wikipedia.org//w/api.php?' ...
  'action=query&list=imageusage&format=xml&iutitle=' ...
  urlencode(wikiTitle) '&iunamespace=0&iulimit=10'];

content = urlread(query);

[s e] = regexp(content, '<imageusage>.*</imageusage>', 'start', 'end');
iuTagsContent = content(s + 12:e - 13);

% get page urls
[s, e] = regexp(iuTagsContent, 'pageid="[0-9]*"', 'start', 'end');

for ii = 1: length(s)
  urlList{ii} = getWikiUrlFromPageId(iuTagsContent(s(ii) + 8 : e(ii) -1));
end

% -------------------------------------------------------------------
function pageUrl = getWikiUrlFromPageId(pageid)
% -------------------------------------------------------------------
query = ['https://en.wikipedia.org/w/api.php?action=query&prop=info&format=xml&inprop=url&pageids=' pageid];
content = urlread(query);
[s e] = regexp(content, 'fullurl=".*" editurl', 'start', 'end');
pageUrl = content(s + 9 : e - 9);
