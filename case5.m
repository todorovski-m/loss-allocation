function ds = case5()
ds.Uslack = 1;
ds.Ubase = 10; % Base voltage, line-to-line (kV)
ds.Sbase = 1; % Base power (MVA)
ds.branch = [
%  From  To   R(Ohms)   X(Ohms)  B(uS)   P(kW) Q(kvar)  Qc(kvar)
      1   2      2.05       1.8      0     900     300         0
      2   3      2.05       1.8      0    1500     450         0
      3   4      2.05       1.8      0    4800    1100         0
      3   5      2.05       1.8      0     300     120         0
      ];
ds.gen = [
%   Bus  P(kW)   Q(kvar) U(pu) Type (1-PQ, 2-PU)
      2    200        20     1   1
      3   1000       500     1   1
      4   5000      1200     1   1
      5    500       -10     1   1
      ];