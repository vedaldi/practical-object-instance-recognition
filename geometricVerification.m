function [score, matches] = geometricVerification(score, f1, d1, f2, d2)
% GEOMETRICVERIFICATION

% Author: Andrea Vedaldi

  opt.tolerance1 = 40 ;
  opt.minInliers1 = 4 ;
  opt.tolerance2 = 30 ;
  opt.minInliers2 = 6 ;

  [ok, matches] = ismember(d1,d2) ;
  x1 = f1(1:2,ok) ; x1(end+1,:) = 1 ;
  x2 = f2(1:2,matches(ok)) ;
  x1 = double(x1) ;
  x2 = double(x2) ;

  inliers = cell(1, numel(d1)) ;
  scores = zeros(1, numel(d1)) ;

  for i = find(ok)
    A1 = toAffinity(f1(:,i)) ;
    A2 = toAffinity(f2(:,matches(i))) ;
    A21 = A2 * inv(A1) ;
    x1p = A21(1:2,:) * x1 ;
    dist2 = sum((x2 - x1p).^2,1) ;
    in = find(dist2 < det(A21(1:2,1:2)) * opt.tolerance1^2) ;
    if numel(in) < opt.minInliers1
      inliers{i} = [] ;
      continue ;
    end

    for t = 1:3
      %a1 = [x1(1,in)', ones(numel(in),1)] \ x2(1,in)' ;
      %a2 = [x1(2,in)', ones(numel(in),1)] \ x2(2,in)' ;
      %A21_ = [a1(1) 0 a1(2) ;
      %        0 a2(1) a2(2) ] ;
      A21_ = x1(:,in)' \ x2(:,in)' ;
      A21_ = reshape(A21_,3,2)' ;
      x1p = A21_ * x1 ;
      dist2 = sum((x2 - x1p).^2,1) ;
      in = find(dist2 < det(A21_(1:2,1:2)) * opt.tolerance2^2) ;
      if numel(in) < opt.minInliers1
        inliers{i} = [] ;
        break ;
      end
    end

    inliers{i} = in ;
    scores(i) = numel(in) ;

    if 0
      figure(444) ; clf ;
      vl_plotframe(x1p,'r*','markersize',10) ; hold on ;
      vl_plotframe(x2,'b') ;
      axis equal ;
      line([x1p(1,:) ; x2(1,:)],...
           [x1p(2,:) ; x2(2,:)],'color', [.9 .9 .9]) ;
      line([x1p(1,in) ; x2(1,in)],...
           [x1p(2,in) ; x2(2,in)],'color', 'k','linewidth',2) ;
      vl_plotframe(x1p(:, i==find(ok)),'go') ;
      %vl_plotframe(x2(:, matches(ok)==matches(find(ok))),'gs') ;
      set(gca,'ydir','reverse') ;
      drawnow ;
      keyboard
    end
  end

  [best, index] = max(scores) ;
  if best > opt.minInliers2
    score = best ;
    sel = find(ok) ;
    sel = sel(inliers{index}) ;
    matches_ = matches ;
    matches = zeros(size(matches)) ;
    matches(sel) = matches_(sel) ;
  else
    matches = [] ;
  end

% --------------------------------------------------------------------
function A = toAffinity(f)
% --------------------------------------------------------------------
  switch size(f,1)
    case 3
      T = f(1:2) ;
      s = f(3) ;
      th = 0 ;
      A = [s*[cos(th) -sin(th) ; sin(th) cos(th)], T ; 0 0 1] ;
    case 4
      T = f(1:2) ;
      s = f(3) ;
      th = f(4) ;
      A = [s*[cos(th) -sin(th) ; sin(th) cos(th)], T ; 0 0 1] ;
    case 5
      T = f(1:2) ;
      A = [mapFromS(f(3:5)), T ; 0 0 1] ;
    case 6
      T = f(1:2) ;
      A = [f(3:4), f(5:6), T ; 0 0 1] ;
    otherwise
      assert(false) ;
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
