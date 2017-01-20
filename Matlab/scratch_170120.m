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
