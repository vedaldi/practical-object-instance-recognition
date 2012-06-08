function [h,frames,words] = getHistogram(imdb, frames, words, varargin)
% GETHISTOGRAM
%   H = GETHISTOGRAM(IMDB, FRAMES, WORDS) computes a visual word
%   histogram from the specified featrures. IMDB is the image database
%   structure, which includes the visual word dictionary as well as
%   the KDTree for fast projection. FRAMES are the feature frames
%   (keypoints) and WORDS the quantized feature descriptors. H is a
%   vector with a dimension equal to the size of the visual words
%   vocabualry contained in IMDB.
%
%   Options:
%
%   Box:: []
%     Set to [xmin;ymin;xmax;ymax] to specify a bounding box in the image.

% Author: Andrea Vedaldi

opts.box = [] ;
opts = vl_argparse(opts, varargin) ;

if ~isempty(opts.box)
  ok = frames(1,:) >= opts.box(1) & ...
       frames(1,:) <= opts.box(3) & ...
       frames(2,:) >= opts.box(2) & ...
       frames(2,:) <= opts.box(4) ;
  frames = frames(:, ok) ;
  words = words(ok) ;
end

h = sparse(double(words), 1, 1, imdb.numWords, 1) ;
h = imdb.idf .* h ;
if imdb.sqrtHistograms, h = sqrt(h) ; end
h = h / sqrt(sum(h.*h)) ;
