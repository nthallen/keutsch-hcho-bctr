function n = SamplePoisson(mu)
  % n = SamplePoisson(mu)
  % Returns a random integer from the Poisson distribution with
  % mean mu.
  
  % P(x,mu) = ((mu^x)/x!) * exp(-mu)
  % so P(0,mu) = exp(-mu) and
  % P(n+1,mu) = P(n,mu)*mu/(n+1)
  Psample = rand;
  P = exp(-mu);
  Psum = P;
  n = 0;
  while Psample > Psum && n < 100*mu
    n = n+1;
    P = P * mu/n;
    Psum = Psum + P;
  end
end
