function imdb = loadIndex(imdbPath, varargin)
% LOADINDEX  Load index from disk and apply options
%   IMDB = LOADINDEX(IMDBPATH) loads the image database IMDBPATH
%   and constructs the inverted index on the fly.

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

info = whos('imdb') ;
fprintf('loadIndex: path: %s\n', imdbPath) ;
fprintf('loadIndex: total number of features: %.2f M\n', full(sum(sum(imdb.index))) / 1e6) ;
fprintf('loadIndex: number of indexed images: %.2f k\n', numel(imdb.images.id) / 1e3) ;
fprintf('loadIndex: average num features per image: %.2f k\n', full(mean(sum(imdb.index))) / 1e3) ;
fprintf('loadIndex: size in memory: %.1f MB\n', info.bytes / 1024^2) ;
fprintf('loadIndex: short list size: %d\n',  imdb.shortListSize) ;
fprintf('loadIndex: use sqrt: %d\n', imdb.sqrtHistograms) ;

% IDF weights
imdb.idf = log(numel(imdb.images.id)) - log(max(sum(imdb.index > 0, 2),1)) ;
imdb.index = spdiags(imdb.idf, 0, imdb.numWords, imdb.numWords) * imdb.index ;

% square root
if imdb.sqrtHistograms, imdb.index = sqrt(imdb.index) ; end

% final l2 normalisation
mass = sqrt(full(sum(imdb.index.*imdb.index, 1)))' ;
n = numel(imdb.images.id) ;
imdb.index = imdb.index * spdiags(1./mass, 0, n, n) ;
