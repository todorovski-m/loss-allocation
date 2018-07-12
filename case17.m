function ds = case17()
% Z. Ghofrani-Jahromi, Z. Mahmoodzadeh and M. Ehsan, "Distribution Loss
% Allocation for Radial Systems Including DGs," in IEEE Transactions on Power
% Delivery, vol. 29, no. 1, pp. 72-80, Feb. 2014.
% doi: 10.1109/TPWRD.2013.2277717
ds.Uslack = 1;
ds.Ubase = 20; % Base voltage, line-to-line (kV)
ds.Sbase = 1; % Base power (MVA)
ds.branch = [
%  From  To     R(pu)     X(pu)  B(pu)   P(kW) Q(kvar)  Qc(kvar)
      1   2    0.0025    0.0026   0.03       0     0        0
      2   5    0.0007    0.0007   0.02     140    80        0
      2   3    0.0008    0.0008   0.02      89    50        0
      3   4    0.0007    0.0007   0        111    63        0
      5   9    0.0021    0.0022   0.02      89    50        0
      5   6    0.002     0.0021   0.02       0     0        0
      6  10    0.0001    0.0001   0          0     0        0
      6   7    0.0009    0.0009   0.01     141    80        0
      7   8    0.0017    0.0017   0.01     338   192        0
     10  11    0.0006    0.0006   0        152    86        0
     10  12    0.0018    0.0018   0        266   151        0
     12  13    0.0003    0.0003   0         10     5        0
     12  14    0.0011    0.0011   0          0     0        0
     14  15    0.0011    0.0011   0        205   116        0
     14  17    0.0007    0.0007   0        241   137        0
     15  16    0.0001    0.0001   0         72    41        0
];
Zbase = ds.Ubase^2/ds.Sbase;
ds.branch(:,3:4) = ds.branch(:,3:4) * Zbase;
ds.branch(:,5) = ds.branch(:,5) / Zbase * 1e6;
ds.gen = [
%   Bus  P(kW)  Q(kvar) U(pu) Type (1-PQ, 2-PU)
    15    300    145.29  1.00    1
    16    200     96.86  1.00    1
    17    260    125.92  1.00    1
     ];