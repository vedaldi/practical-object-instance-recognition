function h = getHistogram(imdb, frames, descrs, box)
% GETHISTOGRAM
%   H = GETHISTOGRAM(IMDB, FRAMES, DESCRS, BOX)

if nargin > 3
  ok = frames(1,:) >= box(1) & ...
       frames(1,:) <= box(3) & ...
       frames(2,:) >= box(2) & ...
       frames(2,:) <= box(4) ;
  frames = frames(:, ok) ;
  descrs = descrs(ok) ;
end

h = sparse(double(descrs), 1, 1, imdb.numWords, 1) ;
h = imdb.idf .* h ;
h = sqrt(h / max(sum(h),1e-10)) ;
