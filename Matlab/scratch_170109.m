%%
N=1000;
dT = zeros(N,1);
R = rand(N,1)*IPmax;
for i=1:N
  dT(i) = binsearch(IPcumsum, R(i));
end
plot(dT,'.'); shg;
title(sprintf('Pulse: %.1f %%', 100*sum(dT>0)/N));
%%
function ind = binsearch(T, R, low, high)
  if nargin < 4
    low = 1;
    high = length(T);
    if R > T(high)
      ind = 0;
      return;
    end
  end
  while high > low
    mid = floor((low+high)/2);
    if R > T(mid)
      low = mid+1;
    else
      high = mid;
    end
  end
  ind = low;
  return;
end
