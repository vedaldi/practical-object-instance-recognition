function imdb = loadIndex(imdbPath, varargin)
% LOADINDEX  Load index from disk and apply options
%   IMDB = LOADINDEX(IMDBPATH)

opts.sqrtHistograms = false ;
opts.shortListSize = 100 ;
opts = vl_argparse(opts, varargin) ;

imdb = load(imdbPath) ;
info = whos('imdb') ;
fprintf('index: total number of features: %.2f M\n', full(sum(sum(imdb.index)))/1e6) ;
fprintf('index: average num features per image: %.1f\n', full(mean(sum(imdb.index)))) ;
fprintf('index: size: %.1f GB\n', whos.bytes / 1024^3) ;

imdb.shortListSize = opts.shortListSize ;
imdb.sqrtHistograms = opts.sqrtHistograms ;
imdb.idf = log(numel(imdb.images.id)) - log(max(sum(imdb.index > 0, 2),1)) ;
imdb.index = spdiags(imdb.idf, 0, imdb.numWords, imdb.numWords) * imdb.index ;

if imdb.sqrtHistograms, imdb.index = sqrt(imdb.index) ; end
mass = sqrt(full(sum(imdb.index.*imdb.index, 1)))' ;
n = numel(imdb.images.id) ;
imdb.index = imdb.index * spdiags(1./mass, 0, n, n) ;
