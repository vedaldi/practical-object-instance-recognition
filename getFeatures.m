function [frames, descrs] = getFeatures(im, varargin)
% GETFEATURES  Extract feature frames (keypoints) and descriptors
%   [FRAMES, DESCRS] = GETFEATURES(IM)
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

opts.method = 'hessian' ;
opts.affineAdaptation = false ;
opts.orientation = true ;
opts = vl_argparse(opts, varargin) ;

if size(im,3) > 1, im = rgb2gray(im) ; end
im = im2single(im) ;

switch lower(opts.method)
  case 'dog'
    [frames, descrs] = vl_covdet(im, ...
                                 'AffineAdaptation', opts.affineAdaptation, ...
                                 'Orientation', opts.rientation, ...
                                 'FirstOctave',0, ...
                                 'FloatDescriptors', ...
                                 'Method', 'DoG', ...
                                 'Verbose') ;
  case 'hessian'
    [frames, descrs] = vl_covdet(im, ...
                                 'AffineAdaptation', opts.affineAdaptation, ...
                                 'Orientation', opts.orientation, ...
                                 'FirstOctave',0, ...
                                 'FloatDescriptors', ...
                                 'Method', 'Hessian', ...
                                 'Verbose', ...
                                 'PeakThreshold', 0.001) ;
end
