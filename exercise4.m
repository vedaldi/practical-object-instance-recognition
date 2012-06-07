% PART IV: Large scale image retrieval

% Load the database
imdb = loadIndex('data/oxbuild_imdb_100k_ellipse_hessian.mat', ...
                 'sqrtHistograms', true) ;

% Search for an image downloaded from the internet in the database
urls = {'http://tourist-tracks.com/wp-content/uploads/2009/12/Oxfordweb.jpg'} ;

res = search(imdb, urls{1}, 'box', []) ;

% Display the results
plotRetrievedImages(imdb, res) ;
