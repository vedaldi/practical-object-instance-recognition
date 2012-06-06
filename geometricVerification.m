function inliers = geometricVerification(f1, f2, matches, varargin)
% GEOMETRICVERIFICATION  Verify feature matches based on geomeyry
%   OK = GEOMETRICVERIFICATION(F1, F2, MATCHES) check for geomeric
%   consistency the matches MATCHES between feature frames F1 and F2
%   (see PLOTMATCHES() for the format). INLIERS is a list of indexes
%   of matches that are inliers to the geometric model.

% Author: Andrea Vedaldi

  opts.tolerance1 = 20 ;
  opts.tolerance2 = 20 ;
  opts.minInliers = 4 ;
  opts.numRefinementIterations = 1 ;
  opts = vl_argparse(opts, varargin) ;

  numMatches = size(matches,2) ;
  inliers = cell(1, numMatches) ;

  x1 = double(f1(1:2, matches(1,:))) ;
  x2 = double(f2(1:2, matches(2,:))) ;
  x1hom = x1 ;
  x1hom(end+1,:) = 1 ;

  for m = 1:numMatches
    for t = 1:opts.numRefinementIterations
      if t == 1
        A1 = toAffinity(f1(:,matches(1,m))) ;
        A2 = toAffinity(f2(:,matches(2,m))) ;
        A21 = A2 * inv(A1) ;
        tol = opts.tolerance1 ;
      else
        A21 = x1hom(:,inliers{m})' \ x2(:,inliers{m})' ;
        A21 = reshape(A21,3,2)' ;
        tol = opts.tolerance2 ;
      end

      x1p = A21(1:2,:) * x1hom ;
      dist2 = sum((x2 - x1p).^2,1) ;
      inliers{m} = find(dist2 < det(A21(1:2,1:2)) * tol^2) ;
      if numel(inliers{m}) < opts.minInliers, break ; end
    end
  end
  scores = cellfun(@numel, inliers) ;
  [~, best] = max(scores) ;
  inliers = inliers{best} ;
end

% --------------------------------------------------------------------
function A = toAffinity(f)
% --------------------------------------------------------------------
  switch size(f,1)
    case 3 % discs
      T = f(1:2) ;
      s = f(3) ;
      th = 0 ;
      A = [s*[cos(th) -sin(th) ; sin(th) cos(th)], T ; 0 0 1] ;
    case 4 % oriented discs
      T = f(1:2) ;
      s = f(3) ;
      th = f(4) ;
      A = [s*[cos(th) -sin(th) ; sin(th) cos(th)], T ; 0 0 1] ;
    case 5 % ellipses
      T = f(1:2) ;
      A = [mapFromS(f(3:5)), T ; 0 0 1] ;
    case 6 % oriented ellipses
      T = f(1:2) ;
      A = [f(3:4), f(5:6), T ; 0 0 1] ;
    otherwise
      assert(false) ;
  end
end

% --------------------------------------------------------------------
function A = mapFromS(S)
% --------------------------------------------------------------------
% Returns the (stacking of the) 2x2 matrix A that maps the unit circle
% into the ellipses satisfying the equation x' inv(S) x = 1. Here S
% is a stacked covariance matrix, with elements S11, S12 and S22.

  tmp = sqrt(S(3,:)) + eps ;
  A(1,1) = sqrt(S(1,:).*S(3,:) - S(2,:).^2) ./ tmp ;
  A(2,1) = zeros(1,length(tmp));
  A(1,2) = S(2,:) ./ tmp ;
  A(2,2) = tmp ;
end