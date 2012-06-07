function imdb = loadIndex(imdbPath, varargin)
% LOADINDEX  Load index from disk and apply options
%   IMDB = LOADINDEX(IMDBPATH)

% Author: Andrea Vedaldi

opts.sqrtHistograms = false ;
opts.shortListSize = 100 ;
opts = vl_argparse(opts, varargin) ;

imdb = load(imdbPath) ;
imdb.shortListSize = opts.shortListSize ;
imdb.sqrtHistograms = opts.sqrtHistograms ;

% --------------------------------------------------------------------
%                                              Compute inverted index
% --------------------------------------------------------------------

numImages = numel(imdb.images.id) ;
indexes = cell(1, numImages) ;
for i = 1:numImages
  indexes{i} = i * ones(1,numel(imdb.images.words{i})) ;
end

imdb.index = sparse(double([imdb.images.words{:}]), ...
                    [indexes{:}], ...
                    1, ...
                    imdb.numWords, ...
                    numel(imdb.images.id)) ;

% IDF weights
imdb.idf = log(numel(imdb.images.id)) - log(max(sum(imdb.index > 0, 2),1)) ;
imdb.index = spdiags(imdb.idf, 0, imdb.numWords, imdb.numWords) * imdb.index ;

% square root
if imdb.sqrtHistograms, imdb.index = sqrt(imdb.index) ; end

% final l2 normalisation
mass = sqrt(full(sum(imdb.index.*imdb.index, 1)))' ;
n = numel(imdb.images.id) ;
imdb.index = imdb.index * spdiags(1./mass, 0, n, n) ;


info = whos('imdb') ;
fprintf('index: path: %s\n', imdbPath) ;
fprintf('index: total number of features: %.2f M\n', full(sum(sum(imdb.index)))/1e6) ;
fprintf('index: average num features per image: %.1f\n', full(mean(sum(imdb.index)))) ;
fprintf('index: size: %.1f GB\n', info.bytes / 1024^3) ;
fprintf('index: short list size: %d\n',  imdb.shortListSize) ;
fprintf('index: use sqrt: %d\n', imdb.sqrtHistograms) ;
