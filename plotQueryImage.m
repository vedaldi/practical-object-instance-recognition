function plotQueryImage(imbd, res)
% PLOTQUERYIMAGE  Plot the query image from a set of search results
%   PLOTQUERYIMAGE(IMDB, RES) displays the query image for the set
%   of search results RES.

% Author: Andrea Vedaldi

if numel(res.query.image) == 1
  ii = vl_binsearch(imdb.images.id, res.query.image) ;
  im = imread(fullfile(imdb.dir, imdb.images.name{ii})) ;
else
  im = res.query.image ;
end

cla ;
imagesc(im) ; hold on ;
axis image off ;
if ~isempty(res.query.box)
  vl_plotbox(res.query.box, 'linewidth', 2, 'color', 'b') ;
end
title('Query imge') ;
