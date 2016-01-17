function preprocess_paintings()
% PREPROCESS_PAINTINGS

setup ;

dataDir = 'data' ;
listPath = 'extra/paintings.txt' ;
imdb = setupWikipediaPaintings(dataDir, listPath) ;
for t = 1
  switch t
    case 1
      suffix = '100k_disc_dog' ;
      numWords = 100e3 ;
      featureOpts = {'method', 'dog', 'affineAdaptation', false, 'orientation', false} ;
    case 2
      suffix = '100k_odisc_dog' ;
      numWords = 100e3 ;
      featureOpts = {'method', 'dog', 'affineAdaptation', false, 'orientation', true} ;
    case 3
      suffix = '100k_ellipse_hessian' ;
      numWords = 100e3 ;
      featureOpts = {'method', 'hessian', 'affineAdaptation', true, 'orientation', false} ;
    case 4
      suffix = '100k_oellipse_dog' ;
      numWords = 100e3 ;
      featureOpts = {'method', 'dog', 'affineAdaptation', true, 'orientation', true} ;
  end
  makeIndex(imdb, dataDir, suffix, numWords, featureOpts) ;
end

% --------------------------------------------------------------------
function [comment, descUrl, imgUrl] = getWikipediaImage(imgTitle)
% --------------------------------------------------------------------

url = ['https://en.wikipedia.org/w/api.php?' ...
  'action=query&prop=imageinfo&format=xml&iiprop=url' ...
  '|parsedcomment&iilimit=1&titles=' urlencode(imgTitle)] ;

content = urlread(url);

comment = [] ;
imgUrl = [] ;
descUrl = [] ;

m = regexp(content, 'parsedcomment="(?<x>[^"]*)"', 'names') ;
if numel(m) > 0
  comment = m.x ;
end

m = regexp(content, ' url="(?<x>[^"]*)"', 'names') ;
if numel(m) > 0
  imgUrl = m.x ;
end

m = regexp(content, 'descriptionurl="(?<x>[^"]*)"', 'names') ;
if numel(m) > 0
  descUrl = m.x ;
end

% --------------------------------------------------------------------
function imdb = setupWikipediaPaintings(dataDir, listPath)
% --------------------------------------------------------------------

mkdir(fullfile(dataDir, 'paintings')) ;
imdbPath = fullfile(dataDir, 'paintings_imdb.mat') ;
f=fopen(listPath,'r','n','UTF-8');
data = textscan(f, '%s%s', 'delimiter', '\t') ;
images = data{1} ;
titles = data{2} ;
fclose(f) ;

imdb.dir = fullfile(dataDir, 'paintings') ;
imdb.images.id = [] ;
imdb.images.name = {} ;
imdb.images.wikiName = {} ;
imdb.images.downloadUrl = {} ;
imdb.images.infoUrl = {} ;

for i=1:numel(images)
  imagePath = fullfile(imdb.dir, images{i}) ;
  matPath = [imagePath '.mat'] ;
  if ~exist(matPath)
    fprintf('Getting info for %s\n', titles{i}) ;
    [comment, descUrl, imgUrl] = getWikipediaImage(titles{i}) ;
    save(matPath, 'comment', 'descUrl', 'imgUrl') ;
  else
    load(matPath, 'comment', 'descUrl', 'imgUrl') ;
  end
  if isempty(imgUrl)
    warning('Could not find %s', titles{i}) ;
    continue ;
  end
  if ~exist(imagePath)
    fprintf('Getting image data for %s\n', titles{i}) ;
    im = imread(imgUrl) ;
    if size(im,1) > 1024
      im = imresize(im, [1024 NaN]) ;
    elseif size(im,2) > 1024
      im = imresize(im, [NaN 1024]) ;
    end
    imwrite(im, imagePath, 'quality', 95) ;
  end
  imdb.images.id(end+1) = numel(imdb.images.id)+1 ;
  imdb.images.name{end+1} = images{i} ;
  imdb.images.wikiName{end+1} = titles{i} ;
  imdb.images.downloadUrl{end+1} = imgUrl ;
  imdb.images.infoUrl{end+1} = descUrl ;
end

save(imdbPath, '-STRUCT', 'imdb') ;

% --------------------------------------------------------------------
function makeIndex(imdb, dataDir, suffix, numWords, featureOpts)
% --------------------------------------------------------------------
imdbPath = fullfile(dataDir, ['paintings_imdb_' suffix '.mat']) ;
if exist(imdbPath, 'file'), return ; end
imdb.featureOpts = featureOpts ;
imdb.numWords = numWords ;

% ------------------------------------------------------------------
%                                      Compute the visual vocabulary
% ------------------------------------------------------------------
descrs = cell(1,numel(imdb.images.name)) ;
numWordsPerImage = ceil(imdb.numWords * 10 / numel(imdb.images.name)) ;
parfor i = 1:numel(imdb.images.name)
  fprintf('get features from %i, %s\n', i, imdb.images.name{i}) ;
  
  [~, descrs{i}] = getFeatures(imread(...
    fullfile(imdb.dir, imdb.images.name{i})), imdb.featureOpts{:});
  randn('state',i) ;
  descrs{i} = vl_colsubset(descrs{i}, numWordsPerImage) ;
end

descrs = cat(2,descrs{:}) ;
[imdb.vocab, imdb.kdtree] = annkmeans(descrs, imdb.numWords, ...
  'numTrees', 4, ...
  'maxNumComparisons', 1024, ...
  'maxNumIterations', 30, ...
  'tolerance', 1e-3, ...
  'verbose', true, ...
  'seed', 2) ;

% --------------------------------------------------------------------
%                                                 Compute the features
% --------------------------------------------------------------------
clear frames words ;
parfor i = 1:numel(imdb.images.name)
  fprintf('get features from %i, %s\n', i, imdb.images.name{i}) ;
  [frames{i},descrs] = getFeatures(imread(...
    fullfile(imdb.dir, imdb.images.name{i})), imdb.featureOpts{:}) ;
  words{i} = vl_kdtreequery(imdb.kdtree, imdb.vocab, descrs, ...
    'maxNumComparisons', 1024) ;
end

imdb.images.frames = frames ;
imdb.images.words = words ;
save(imdbPath, '-STRUCT', 'imdb') ;

