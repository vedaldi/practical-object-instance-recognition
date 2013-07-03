% PART IV: Large scale image retrieval

% setup MATLAB to use our software
setup ;

% Load the database if not already in memory, or if the one
% is from exercise3.
if ~exist('imdb', 'var') || ~isfield(imdb.images,'wikiName')
  imdb = loadIndex('data/art_imdb_100k_ellipse_hessian.mat', ...
                   'sqrtHistograms', true) ;
  imdb.dir = '' ; % art images are not shipped with practical
end

% Search the database for a match to a given image. Note that URL
% can be a path to a file or a URL pointing to an image in the
% Internet.

url1 = 'data/queries/mistery-painting-01.jpg' ;
url2 = 'data/queries/mistery-painting-09.jpg' ;
url3 = 'data/queries/mistery-painting-11.jpg' ;
res = search(imdb, url3, 'box', []) ;

% Display the results
figure(1) ; clf ; set(gcf,'name', 'Part IV: query image') ;
plotQueryImage(imdb, res) ;

imdb.dir = 'data/impressionists/paintings/';

figure(2) ; clf ; set(gcf,'name', 'Part IV: search results') ;
plotRetrievedImages(imdb, res, 'num', 16) ;
