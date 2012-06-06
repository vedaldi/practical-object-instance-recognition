function plotmatches(im1,im2,f1,f2,matches)
% PLOTMATCHES  Plot matching features between imags
%   PLOTMATCHES(IM1, IM2, F1, F2, MATCHES) displays images IM1 and IM2
%   overlaying the feature frames F1 and F2 as well as line connecting
%   them based on the matrix of feature matches MATCHES. Each column
%   of MATCHES define a match as a pair ofindexes of matching features
%   in F1 and F2.

% Author: Andrea Vedaldi

dh1 = max(size(im2,1)-size(im1,1),0) ;
dh2 = max(size(im1,1)-size(im2,1),0) ;

o = size(im1,2) ;
if size(matches,1) == 1
  i1 = find(matches) ;
  i2 = matches(i1) ;
else
  i1 = matches(1,:) ;
  i2 = matches(2,:) ;
end

hold on ;
f2p = f2 ;
f2p(1,:) = f2p(1,:) + o ;

cla ; set(gca,'ydir', 'reverse') ;
imagesc([padarray(im1,dh1,'post') padarray(im2,dh2,'post')]) ;
axis image off ;
vl_plotframe(f1(:,i1)) ;
vl_plotframe(f2p(:,i2)) ;
line([f1(1,i1);f2p(1,i2)], [f1(2,i1);f2p(2,i2)]) ;
title(sprintf('number of matches: %d', size(matches,2))) ;
