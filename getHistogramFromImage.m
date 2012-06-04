function [h, frames, descrs] = getHistogramFromImage(imdb, im, varargin)
% GETHISTOGRAMFROMIMAGE
%   [H, FRAMES, DESCRS] = GETHISTOGRAMFROMIMAGE(IMDB, IM) is the
%   same as calling [FRAMES, DESCRS] = GETFEATURES(IM) and then GETHISTOGRAMS

% Author: Andrea Vedaldi

opts.box = [] ;
opts.maxNumComparisons = 500 ;
opts = vl_argparse(opts, varargin) ;

% extract the features
[frames,descrs] = getFeatures(im,imdb.featureOpts{:}) ;

% quantize the features
descrs = vl_kdtreequery(imdb.kdtree, imdb.vocab, descrs, ...
                                        'maxNumComparisons', opts.maxNumComparisons) ;

% get the histogram
[h,frames,decrs] = getHistogram(imdb, frames, descrs, 'box', opts.box) ;
