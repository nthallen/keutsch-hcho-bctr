
%%
Opts.BinWidth = 1e-9; % 1 ns
Opts.LaserTau = 20e-9;
Opts.T0 = -50e-9;
Opts.T1 = 300e-9;
Opts.FlTau = 70e-9; % Fluorescence lifetime
Opts.DeadTime = 22.5e-9;
Opts.PulseRate = 300000; % Laser pulses per sec
Opts.CntRate = 100000; % Counts per sec
Opts.IntegPer = 1;
%%
T = Opts.T0:Opts.BinWidth:Opts.T1;
Laser = exp(-(T/Opts.LaserTau).^2);
Fl = exp(-T/Opts.FlTau);
Fl(T<0) = 0;
CntShape = max(Laser,Fl);
CntShape = CntShape/sum(CntShape); % normalized distribution
CntShape = CntShape * Opts.CntRate / Opts.PulseRate;
%%
N = ceil(Opts.IntegPer * Opts.PulseRate);
Bins = zeros(size(T));
Pulse = zeros(size(T));
for i=1:N
  dead_pulse = Opts.T0-Opts.DeadTime;
  for j=1:length(T)
    if T(j)-dead_pulse > Opts.DeadTime
      Pulse(j) = SamplePoisson(CntShape(j));
      if Pulse(j) > 0
        Pulse(j) = 1;
        dead_pulse = T(j);
      end
    else
      Pulse(j) = 0;
    end
  end
  Bins = Bins + Pulse;
end
%%
figure; plot(T,Bins,'*',T,N*CntShape);
