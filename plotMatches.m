function plotMatches(im1,im2,f1,f2,matches,varargin)
% PLOTMATCHES  Plot matching features between images
%   PLOTMATCHES(IM1, IM2, F1, F2, MATCHES) displays the images IM1 and
%   IM2 overlaying the feature frames F1 and F2 as well as lines
%   connecting them as specified by MATCHES. Each column of MATCHES
%   paris the frame F1(:, MATCHES(1,i)) to the frame F2(:,
%   MATCHES(2,i)).
%
%   Options:
%
%   plotallFrames:: false
%     Set to true in order to plot all the frames, regardles of
%     whether there exist a match involving them.

% Author: Andrea Vedaldi

opts.plotAllFrames = false ;
opts = vl_argparse(opts, varargin) ;

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
if opts.plotAllFrames
  vl_plotframe(f1,'linewidth',2) ;
  vl_plotframe(f2p,'linewidth',2) ;
else
  vl_plotframe(f1(:,i1),'linewidth',2) ;
  vl_plotframe(f2p(:,i2),'linewidth',2) ;
end
line([f1(1,i1);f2p(1,i2)], [f1(2,i1);f2p(2,i2)]) ;
title(sprintf('number of matches: %d', size(matches,2))) ;
