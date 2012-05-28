function [score, matches] = geometricVerification(score, f1, d1, f2, d2)
% GEOMETRICVERIFICATION

opt.tolerance1 = 30 ;
opt.minInliers1 = 6 ;
opt.tolerance2 = 20 ;
opt.minInliers2 = 6 ;

[ok, matches] = ismember(d1,d2) ;
x1 = f1(1:2,ok) ; x1(end+1,:) = 1 ;
x2 = f2(1:2,matches(ok)) ;

inliers = cell(1, numel(d1)) ;
scores = zeros(1, numel(d1)) ;

for i = find(ok)
  A1 = toAffinity(f1(:,i)) ;
  A2 = toAffinity(f2(:,matches(i))) ;
  A21 = A2 * inv(A1) ;
  x1p = A21(1:2,:) * x1 ;
  dist2 = sum((x2 - x1p).^2,1) ;
  in = find(dist2 < opt.tolerance1^2) ;
  if numel(in) < opt.minInliers1
    inliers{i} = [] ;
    continue ;
  end

  for t=1:3
    a1 = [x1(1,in)', ones(numel(in),1)] \ x2(1,in)' ;
    a2 = [x1(2,in)', ones(numel(in),1)] \ x2(2,in)' ;
    A21_ = [a1(1) 0 a1(2) ;
            0 a2(1) a2(2) ] ;
    x1p = A21_(1:2,:) * x1 ;
    dist2 = sum((x2 - x1p).^2,1) ;
    in = find(dist2 < opt.tolerance2^2) ;
  end

  inliers{i} = in ;
  scores(i) = numel(in) ;

  if 0
    figure(444) ; clf ;
    vl_plotframe(x1p,'r*','markersize',30) ; hold on ;
    vl_plotframe(x2,'b') ;
    axis equal ;
    %line([x1p(1,:) ; x2(1,:)],...
    %     [x1p(2,:) ; x2(2,:)],'color', 'k') ;
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

function A = toAffinity(f)
%
  switch size(f,1)
    case 3
      T = f(1:2) ;
      s = f(3) ;
      th = 0 ;
      A = [s*[cos(th) -sin(th) ; sin(th) cos(th)], T ; 0 0 1] ;
    case 4
      T = f(1:2) ;
      s = f(3) ;
      th = 0;% f(4) ;
      A = [s*[cos(th) -sin(th) ; sin(th) cos(th)], T ; 0 0 1] ;
    case 5
    case 6
    otherwise
      assert(false) ;
  end

