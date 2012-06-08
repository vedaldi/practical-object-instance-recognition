function [h, frames, words, decrs] = getHistogramFromImage(imdb, im, varargin)
% GETHISTOGRAMFROMIMAGE
%   [H, FRAMES, DESCRS] = GETHISTOGRAMFROMIMAGE(IMDB, IM) is the
%   same as calling [FRAMES, WORDS, DESCRS] = GETFEATURES(IM) and then GETHISTOGRAMS.

% Author: Andrea Vedaldi

opts.box = [] ;
opts.maxNumComparisons = 1024 ;
opts = vl_argparse(opts, varargin) ;

% extract the features
[frames,descrs] = getFeatures(im,imdb.featureOpts{:}) ;

% quantize the features
words = vl_kdtreequery(imdb.kdtree, imdb.vocab, descrs, ...
                       'maxNumComparisons', opts.maxNumComparisons) ;

% get the histogram
[h,frames,words] = getHistogram(imdb, frames, words, 'box', opts.box) ;
