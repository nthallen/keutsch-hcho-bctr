%%
% Column 1 is temperature C
% Column 2 is nominal Resistance in Ohms
D = load('Epcos_B57540.dat');
T = D(:,1);
Rth = D(:,2);
% We pull up to Vref (2.5V), but are limited to converting only +/- Vref/2
Rpu = 1e6;
Vref = 2.5;
Vth = Vref * Rth ./ (Rth+Rpu);
plot(T,Vth); shg;
%%
v = Vth < Vref/2;
Cts = (2^24)*Vth(v)/Vref;
%%
scale = 2^12;
Desc = '100K Epcos B57540 Pulled up by 1M';
gencal2( T(v), Cts/scale, scale, 'TS_T100K', Desc, 'TS_T100K, CELCIUS' );
%%
A = SteinHart_fit(Rth(v), T(v)+273.15);
Tfit = SteinHart(Rth, A);
figure;
plot(Rth, T, Rth, Tfit-273.15);
%%
plot(Rth, T-Tfit+273.15); shg;
%%
plot(T, T-Tfit+273.15); shg
%%
fprintf(1,'A = [\n');
fprintf(1,'  %.14e\n', A);
fprintf(1,'];\n');
