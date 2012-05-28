function [h, t] = plotroi(roi, varargin)
% PLOTROI  Plot region of interest (a box)
%   PLOTROI(ROI) plots a box specified by the 4-dimensional vector
%   ROI = [XMIN YMIN XMAX YMAX]'. If ROI is a matrix, a ROI for
%   each column is plotted.
%
%   H = PLOTROI(ROI) returns an handle to the line drawing
%   representing the ROIs.
%
%   PLOTROI(ROI, 'LABEL', LABEL) annotates the ROI with text LABEL. If
%   ROI contains multiple ROIs, then LABEL can be a cell array, with
%   one entry for each ROI. In this case [H, T] = PLOTROI(...)
%   returns the handles to the textual labels in the array T.
%
%   PLOTROI(ROI, ...) passes any extra argument to the underlying
%   plotting function. The first optional argument can be a line
%   specification string such as the one used by PLOT().
%
%   See also:: PLOTFRAME().
%
%   Author:: Andrea Vedaldi

% AUTORIGHTS
% Copyright (C) 2008-09 Andrea Vedaldi
%
% This file is part of the VGG MKL Class and VGG MKL Det code packages,
% available in the terms of the GNU General Public License version 2.

% searches for 'label' command and removes it from the argument list
labels = {} ;
i = 1 ;
while i <= length(varargin)
  arg = varargin{i} ;
  if ischar(arg) & strcmp(lower(arg), 'label')
    labels = varargin{i+1} ;
    varargin(i:i+1) = [] ;
    continue ;
  end
  i = i + 1 ;
end
if ischar(labels)
  labels = {labels} ;
end

lineprop = {} ;
if length(varargin) > 0
  lineprop = vl_linespec2prop(varargin{1}) ;
  lineprop = {lineprop{:}, varargin{2:end}} ;
end

N = size(roi,2) ;
if N == 0, h = [] ; return ; end

M = size(roi,1) ;
if M == 2
  %roi = [zeros(2,size(roi,2)) ; roi] ;
  roi = [-roi/2 ; roi/2] ;
end

M = size(roi,1) ;
if M ~= 4 && M ~= 8
  error('ROI must be a 2xN or 4xN or 8xN matrix') ;
end

xv = ones(1,N*6) * NaN ;
yv = ones(1,N*6) * NaN ;

for i=1:N
  o = 6 * (i - 1)  ;
  if M == 4
    xv(o + 1) = roi(1,i) ;
    xv(o + 2) = roi(1,i) ;
    xv(o + 3) = roi(3,i) ;
    xv(o + 4) = roi(3,i) ;
    xv(o + 5) = roi(1,i) ;

    yv(o + 1) = roi(2,i) ;
    yv(o + 2) = roi(4,i) ;
    yv(o + 3) = roi(4,i) ;
    yv(o + 4) = roi(2,i) ;
    yv(o + 5) = roi(2,i) ;
  else
    xv(o + 1) = roi(1,i) ;
    xv(o + 2) = roi(3,i) ;
    xv(o + 3) = roi(5,i) ;
    xv(o + 4) = roi(7,i) ;
    xv(o + 5) = roi(1,i) ;

    yv(o + 1) = roi(2,i) ;
    yv(o + 2) = roi(4,i) ;
    yv(o + 3) = roi(6,i) ;
    yv(o + 4) = roi(8,i) ;
    yv(o + 5) = roi(2,i) ;
  end
end

h = line(xv,yv,lineprop{:}) ;

if ~isempty(labels)
  ish = ishold ;
  hold on ;
  cl = get(h, 'color') ;
  t = zeros(1,length(labels)) ;
  for r=1:length(labels)
    t(r) = text(roi(1,r), roi(2,r), labels{r}, ...
                'background', cl, ...
                'verticalalignment', 'top') ;
  end
  if ~ish, hold off ; end
end
