figure; ax = [nsubplot(2,1,1), nsubplot(2,1,2)];
plot(ax(1),NSk,'.'); plot(ax(2),Cts(:,74),'.-'); shg
set(ax(2),'YAxisLocation','right');
set(ax(1),'XTickLabel',[]);
%
ylabel(ax(1),'N_{skip}');
ylabel(ax(2),'Cts(450-650 ns)');
%
title(ax(1),'More outliers when NSk > 0');
%%
V = NSk > 0;
hold(ax(2), 'on');
plot(ax(2),find(V),Cts(V,74),'*r');
hold(ax(2), 'off');
%%
% Simulation data from Vivado post-place-route-timing
%   Demonstrates 3-clock pipeline delay and off-by-one problem
%   when traversing different bin sizes. 
% 100802855 ns: 171: 0 0 0 0 0 0 0 8 0 8 0 5 0 8 0 12 0 4 0 9 0 4 0 3 0 7 0 3 0 4 0 2 0 4 0 2 0 4 0 6 0 2 0 3 0 6 0 5 0 2 0 1 0 3 0 3 0 3 0 3 0 2 0 3 0 1 0 3 0 7 0 4 0 5 0 2 0 4 0 1 0 3 0 2 0 3 0 0 0 2 0 3 0 12 0 9 0 17 0 12 0 11 0 8 0 8 0 13 0 14 0 5 0 6 0 4 0 7 0 8 0 4 0 6 0 11 0 2 0 6 0 7 0 1 0 4 0 4 0 7 0 4 0 3 0 6 0 1 0 2 0 3 0 1 0 2 0 2 0 6 0 1 0 1 0 0 0 3 0 1 0
% 201602685 ns: 171: 0 0 0 0 0 0 0 10 0 10 0 8 0 11 0 7 0 1 0 5 0 10 0 3 0 3 0 8 0 5 0 6 0 3 0 2 0 6 0 4 0 4 0 3 0 4 0 6 0 1 0 2 0 3 0 7 0 2 0 2 0 4 0 3 0 8 0 3 0 4 0 3 0 0 0 5 0 1 0 1 0 3 0 2 0 2 0 3 0 3 0 1 0 20 0 14 0 12 0 14 0 10 0 10 0 11 0 14 0 10 0 10 0 10 0 7 0 6 0 5 0 8 0 2 0 8 0 5 0 4 0 4 0 4 0 6 0 5 0 3 0 3 0 4 0 5 0 3 0 4 0 2 0 4 0 2 0 3 0 2 0 4 0 3 0 3 0 2 0 1 0
% 302402725 ns: 171: 0 0 0 0 0 0 0 8 0 13 0 12 0 11 0 5 0 3 0 5 0 4 0 5 0 5 0 4 0 7 0 5 0 3 0 10 0 1 0 7 0 7 0 2 0 4 0 6 0 2 0 2 0 3 0 3 0 1 0 2 0 3 0 7 0 2 0 0 0 2 0 4 0 3 0 1 0 2 0 5 0 7 0 0 0 2 0 2 0 0 0 3 0 10 0 16 0 17 0 16 0 9 0 13 0 12 0 7 0 7 0 9 0 11 0 9 0 13 0 6 0 12 0 10 0 7 0 4 0 6 0 6 0 3 0 10 0 6 0 3 0 4 0 1 0 2 0 4 0 4 0 4 0 2 0 0 0 7 0 4 0 3 0 2 0 1 0 2 0 2 0
% 403202765 ns: 171: 0 0 0 0 0 0 0 15 0 16 0 9 0 12 0 9 0 3 0 5 0 4 0 5 0 6 0 2 0 3 0 2 0 5 0 1 0 1 0 3 0 2 0 5 0 3 0 2 0 4 0 2 0 5 0 3 0 1 0 4 0 3 0 4 0 8 0 5 0 1 0 6 0 2 0 2 0 2 0 1 0 0 0 3 0 5 0 3 0 1 0 7 0 13 0 14 0 12 0 11 0 10 0 16 0 11 0 8 0 5 0 6 0 11 0 14 0 9 0 10 0 8 0 10 0 6 0 7 0 2 0 5 0 3 0 2 0 5 0 7 0 3 0 5 0 0 0 3 0 5 0 2 0 3 0 2 0 5 0 4 0 2 0 6 0 0 0 1 0 3 0
% 504002805 ns: 171: 0 0 0 0 0 0 0 11 0 9 0 5 0 6 0 6 0 3 0 6 0 3 0 1 0 3 0 1 0 4 0 2 0 2 0 0 0 1 0 4 0 1 0 5 0 1 0 2 0 3 0 2 0 2 0 4 0 3 0 3 0 4 0 2 0 5 0 3 0 2 0 4 0 5 0 3 0 4 0 2 0 3 0 2 0 4 0 1 0 2 0 2 0 16 0 17 0 3 0 18 0 17 0 11 0 11 0 8 0 6 0 11 0 5 0 8 0 7 0 7 0 7 0 5 0 4 0 7 0 6 0 4 0 4 0 6 0 7 0 5 0 6 0 4 0 0 0 0 0 5 0 2 0 2 0 4 0 5 0 1 0 4 0 1 0 7 0 2 0 1 0
% 604802845 ns: 171: 0 0 0 0 0 0 0 10 0 11 0 7 0 12 0 7 0 6 0 4 0 5 0 1 0 6 0 3 0 1 0 3 0 7 0 4 0 2 0 3 0 5 0 6 0 5 0 3 0 3 0 7 0 6 0 4 0 5 0 4 0 1 0 3 0 3 0 7 0 1 0 2 0 2 0 4 0 7 0 2 0 2 0 10 0 3 0 0 0 6 0 1 0 18 0 18 0 12 0 10 0 11 0 11 0 21 0 5 0 13 0 12 0 8 0 5 0 6 0 8 0 6 0 6 0 5 0 12 0 4 0 6 0 6 0 3 0 7 0 3 0 2 0 2 0 6 0 1 0 0 0 6 0 1 0 1 0 3 0 4 0 3 0 1 0 6 0 2 0 1 0
% 705602885 ns: 171: 0 0 0 0 0 0 0 10 0 14 0 7 0 12 0 9 0 2 0 1 0 1 0 2 0 3 0 5 0 5 0 4 0 1 0 2 0 1 0 2 0 1 0 3 0 7 0 5 0 3 0 3 0 4 0 3 0 2 0 5 0 4 0 0 0 5 0 3 0 3 0 2 0 4 0 3 0 4 0 4 0 0 0 2 0 3 0 4 0 2 0 2 0 19 0 16 0 17 0 6 0 9 0 9 0 12 0 10 0 11 0 9 0 6 0 15 0 8 0 13 0 9 0 10 0 6 0 4 0 10 0 1 0 9 0 3 0 3 0 7 0 8 0 5 0 3 0 4 0 3 0 2 0 5 0 3 0 4 0 6 0 3 0 3 0 0 0 2 0 1 0
% 806402715 ns: 171: 0 0 0 0 0 0 0 11 0 16 0 9 0 4 0 6 0 4 0 2 0 2 0 2 0 6 0 6 0 2 0 2 0 4 0 5 0 5 0 5 0 5 0 3 0 5 0 8 0 6 0 6 0 1 0 4 0 3 0 11 0 1 0 3 0 5 0 9 0 4 0 3 0 5 0 7 0 4 0 0 0 1 0 2 0 5 0 6 0 1 0 2 0 9 0 10 0 16 0 11 0 4 0 9 0 6 0 10 0 15 0 3 0 9 0 8 0 3 0 9 0 9 0 7 0 5 0 10 0 5 0 5 0 9 0 4 0 6 0 4 0 4 0 7 0 6 0 2 0 4 0 4 0 3 0 2 0 2 0 1 0 4 0 3 0 6 0 2 0 1 0
% 907202755 ns: 171: 0 0 0 0 0 0 0 9 0 11 0 4 0 10 0 8 0 5 0 6 0 6 0 4 0 3 0 4 0 5 0 3 0 2 0 3 0 4 0 0 0 2 0 5 0 3 0 4 0 4 0 1 0 4 0 4 0 6 0 3 0 3 0 2 0 2 0 3 0 3 0 5 0 5 0 2 0 3 0 5 0 5 0 1 0 1 0 3 0 6 0 5 0 20 0 12 0 14 0 11 0 16 0 14 0 9 0 8 0 12 0 4 0 10 0 10 0 11 0 6 0 5 0 8 0 2 0 10 0 4 0 8 0 2 0 4 0 4 0 4 0 7 0 4 0 1 0 4 0 5 0 7 0 2 0 2 0 3 0 3 0 0 0 4 0 1 0 5 0 4 0
% 1008002795 ns: 171: 0 0 0 0 0 0 0 11 0 6 0 7 0 12 0 5 0 2 0 3 0 3 0 3 0 4 0 8 0 2 0 2 0 3 0 2 0 2 0 3 0 7 0 4 0 7 0 3 0 4 0 6 0 3 0 1 0 5 0 2 0 0 0 3 0 1 0 1 0 5 0 3 0 1 0 3 0 2 0 2 0 0 0 3 0 2 0 4 0 6 0 6 0 20 0 15 0 13 0 20 0 7 0 14 0 5 0 9 0 9 0 10 0 8 0 7 0 11 0 10 0 10 0 8 0 8 0 4 0 8 0 3 0 3 0 3 0 4 0 4 0 5 0 4 0 4 0 5 0 5 0 7 0 3 0 7 0 4 0 1 0 4 0 3 0 1 0 1 0 2 0
SimCts = [0 0 0 0 0 0 0 8 0 8 0 5 0 8 0 12 0 4 0 9 0 4 0 3 0 7 0 3 0 ...
  4 0 2 0 4 0 2 0 4 0 6 0 2 0 3 0 6 0 5 0 2 0 1 0 3 0 3 0 3 0 3 0 2 0 ...
  3 0 1 0 3 0 7 0 4 0 5 0 2 0 4 0 1 0 3 0 2 0 3 0 0 0 2 0 3 0 12 0 9 ...
  0 17 0 12 0 11 0 8 0 8 0 13 0 14 0 5 0 6 0 4 0 7 0 8 0 4 0 6 0 11 0 ...
  2 0 6 0 7 0 1 0 4 0 4 0 7 0 4 0 3 0 6 0 1 0 2 0 3 0 1 0 2 0 2 0 6 0 ...
  1 0 1 0 0 0 3 0 1 0 ];
SimCts = [0 0 0 0 0 0 0 10 0 10 0 8 0 11 0 7 0 1 0 5 0 10 0 3 0 3 0 8 0 5 0 6 0 3 0 2 0 6 0 4 0 4 0 3 0 4 0 6 0 1 0 2 0 3 0 7 0 2 0 2 0 4 0 3 0 8 0 3 0 4 0 3 0 0 0 5 0 1 0 1 0 3 0 2 0 2 0 3 0 3 0 1 0 20 0 14 0 12 0 14 0 10 0 10 0 11 0 14 0 10 0 10 0 10 0 7 0 6 0 5 0 8 0 2 0 8 0 5 0 4 0 4 0 4 0 6 0 5 0 3 0 3 0 4 0 5 0 3 0 4 0 2 0 4 0 2 0 3 0 2 0 4 0 3 0 3 0 2 0 1 0];
% This one is after patches of 1/23/17. Appears to fix the problem.
SimCts = [0 0 0 0 0 0 0 8 0 8 0 5 0 8 0 12 0 4 0 9 0 4 0 3 0 7 0 3 0 4 0 2 0 4 0 2 0 4 0 6 0 2 0 3 0 6 0 5 0 2 0 1 0 3 0 3 0 3 0 3 0 2 0 3 0 1 0 3 0 7 0 4 0 5 0 2 0 4 0 1 0 3 0 2 0 3 0 0 0 2 0 14 0 8 0 16 0 14 0 9 0 10 0 9 0 11 0 14 0 5 0 8 0 4 0 6 0 7 0 4 0 6 0 10 0 4 0 5 0 8 0 1 0 4 0 3 0 8 0 3 0 4 0 7 0 0 0 2 0 3 0 1 0 2 0 3 0 6 0 1 0 1 0 0 0 3 0 1 0 0 0 ];
SimCts2 = [0 0 0 0 0 0 0 8 0 8 0 5 0 8 0 12 0 4 0 9 0 4 0 3 0 7 0 3 0 4 0 2 0 4 0 2 0 4 0 6 0 2 0 3 0 6 0 5 0 2 0 1 0 3 0 3 0 3 0 3 0 2 0 3 0 1 0 3 0 7 0 4 0 5 0 2 0 4 0 1 0 3 0 2 0 3 0 0 0 2 0 14 0 8 0 16 0 14 0 9 0 10 0 9 0 11 0 14 0 5 0 8 0 4 0 6 0 7 0 4 0 6 0 10 0 4 0 5 0 8 0 1 0 4 0 3 0 8 0 3 0 4 0 7 0 0 0 2 0 3 0 1 0 2 0 3 0 6 0 1 0 1 0 0 0 3 0 1 0 0 0 ];
 
SimCh1 = SimCts(2:2:end);
SimCh2 = SimCts(3:2:end);
figure; plot(1:85,SimCh1,'.', 1:85,SimCh2,'*');