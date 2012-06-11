% PART IV: Large scale image retrieval

% setup MATLAB to use our software
setup ;

% Load the database if not already in memory
if ~exist('imdb', 'var')
  imdb = loadIndex('data/art_imdb_100k_disc_hessian.mat', ...
                   'sqrtHistograms', true) ;
end

imdb.dir = '' ;

% Search for an image downloaded from the Internet in the database
url1 = 'https://docs.google.com/document/pubimage?id=1Ek4gU_c6Q4CQdzKLK71ZKEHK7a30wBIx9W4-Q7OnWsY&image_id=1nykH4w2VTyRdkVe7-EGhxvkT7EdSSa8' ;
url2 = 'https://docs.google.com/document/pubimage?id=1Ek4gU_c6Q4CQdzKLK71ZKEHK7a30wBIx9W4-Q7OnWsY&image_id=11-aYHsmyxh6g0_DbVaOpQgoZsMAtWzw' ;
url3 = 'https://docs.google.com/document/pubimage?id=1Ek4gU_c6Q4CQdzKLK71ZKEHK7a30wBIx9W4-Q7OnWsY&image_id=1b3Q-NDcwA4TFNil7G672sT2yNqLiwtI' ;

res = search(imdb, url1, 'box', []) ;

% Display the results
figure(1) ; clf ; set(gcf,'name', 'Part IV: query image') ;
plotQueryImage(imdb, res) ;

figure(2) ; clf ; set(gcf,'name', 'Part IV: search results') ;
plotRetrievedImages(imdb, res, 'num', 9) ;
