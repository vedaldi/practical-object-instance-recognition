% PART IV: Large scale image retrieval

% Load the database if not already in memory
if ~exist('imdb', 'var')
  imdb = loadIndex('data/oxbuild_lite_imdb_100k_ellipse_hessian.mat', ...
                   'sqrtHistograms', true) ;
end

% Search for an image downloaded from the Internet in the database
urls = {'http://tourist-tracks.com/wp-content/uploads/2009/12/Oxfordweb.jpg'} ;
res = search(imdb, urls{1}, 'box', []) ;

% Display the results
figure(1) ; clf ; set(gcf,'name', 'Part IV: query image') ;
plotQueryImage(imdb, res) ;

figure(2) ; clf ; set(gcf,'name', 'Part IV: search results') ;
plotRetrievedImages(imdb, res) ;
