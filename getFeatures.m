function [frames, descrs] = getFeatures(im, varargin)
% GETFEATURES  Extract feature frames (keypoints) and descriptors
%   [FRAMES, DESCRS] = GETFEATURES(IM) computes the SIFT features
%   from image IM.
%
%   Options:
%
%   AffineAdaptation:: false
%     Set to TRUE to turn on affine adaptation.
%
%   Orientation:: true
%     Set to FALSE to turn off the detection of the feature
%     orientation.
%
%   Method:: Hessian
%     Set to DoG to use the approximated Laplacian operator score.

% Author: Andrea Vedaldi

opts.method = 'dog' ;
opts.affineAdaptation = false ;
opts.orientation = true ;
opts.peakThreshold = 28 / 256^2 ;
opts = vl_argparse(opts, varargin) ;

if size(im,3) > 1, im = rgb2gray(im) ; end
im = im2single(im) ;

im = imresize(im, [480, NaN]);

[frames, descrs] = vl_covdet(im, ...
                             'EstimateAffineShape', opts.affineAdaptation, ...
                             'EstimateOrientation', opts.orientation, ...
                             'DoubleImage', false, ...
                             'Method', opts.method, ...
                             'PeakThreshold', opts.peakThreshold, ...
                             'Verbose') ;
frames = single(frames) ;
