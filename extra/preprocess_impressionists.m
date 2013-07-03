function preprocess_impressionists()
% PREPROCESS  Build vocabulary and compute histograms
%   PREPROCESS() download an image dataset into 'data/', VLFeat into
%   'vlfeat/', and precompute the histograms for the dataset.

  %setup ;

  % --------------------------------------------------------------------
  %                                                      Setup Oxford 5k
  % --------------------------------------------------------------------
  %prefix = 'data/oxbuild' ;
  %imdb = setupOxford5kBase('data/oxbuild', 'data/oxbuild_images') ;
  addpath('..');
  prefix = 'data/art' ;
  imdb = setupArtBase(prefix, 'data/impressionists') ;
  for t = 3 
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
    setupArt(imdb, prefix, suffix, numWords, featureOpts) ;
  end
end

% --------------------------------------------------------------------
function imdb = setupArtBase(prefix, artDir)
% --------------------------------------------------------------------
  imdbPath = [prefix '_imdb.mat'] ;
  listPath = fullfile(artDir, 'impress_and_post.txt') ;

  f = fopen(listPath, 'r','n','UTF-8') ;
  data = textscan(f, '%s%s%s%s','delimiter', '\t') ;
  fclose(f) ;

  localNames = data{1};
  downloadLinks = data{2};
  infoLinks = data{3};

  imdb.dir = fullfile(artDir,'paintings') ;
  imdb.images.id = 1:numel(localNames) ;
  imdb.images.name = localNames ;
  imdb.images.downloadLinks = downloadLinks;
  imdb.images.infoLinks = infoLinks;
  save(imdbPath, '-STRUCT', 'imdb') ;
end

% --------------------------------------------------------------------
function setupArt(imdb, prefix, suffix, numWords, featureOpts)
% --------------------------------------------------------------------
  imdbPath = [prefix '_imdb_' suffix '.mat'] ;
  %if exist(imdbPath, 'file'), return ; end
  imdb.featureOpts = featureOpts ;
  imdb.numWords = numWords ;

  % ------------------------------------------------------------------
  %                                      Compute the visual vocabulary
  % ------------------------------------------------------------------
  descrs = cell(1,numel(imdb.images.name)) ;
  numWordsPerImage = ceil(imdb.numWords * 10 / numel(imdb.images.name)) ;
  parfor i = 1:numel(imdb.images.name)
    fprintf('get features from %i, %s\n', i, imdb.images.name{i}) ;

    [~, descrs{i}] = getFeatures(imread(fullfile(imdb.dir, imdb.images.name{i}(1:4), ...
        imdb.images.name{i})), imdb.featureOpts{:});
    randn('state',i) ;
    descrs{i} = vl_colsubset(descrs{i}, numWordsPerImage) ;
  end

  descrs = cat(2,descrs{:}) ;

% imdb.vocab = vl_kmeans(descrs, imdb.numWords, 'algorithm', 'elkan', ...
%    'verbose') ;

% imdb.kdtree = vl_kdtreebuild(imdb.vocab);

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
    [frames{i},descrs] = getFeatures(imread(fullfile(imdb.dir, imdb.images.name{i}(1:4), ...
        imdb.images.name{i})), imdb.featureOpts{:}) ;
    words{i} = vl_kdtreequery(imdb.kdtree, imdb.vocab, descrs, ...
                              'maxNumComparisons', 1024) ;
  end

  imdb.images.frames = frames ;
  imdb.images.words = words ;
  save(imdbPath, '-STRUCT', 'imdb') ;
end
