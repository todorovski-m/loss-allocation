function [NB, NL, f, t, Zbranch, Ybranch, Ysh, Sd] = data_sep(ds)
%DATA_SEP  Separates data froms structure ds into vectors. Performs conversion in pu.
%
%  [NB, NL, f, t, Zbranch, Ybranch, Ysh, Sd] = data_sep(ds)
%
%  Inputs:
%    ds : Structure with the case data (ex. see 'case5')
%
%  Outputs:
%    NB : Number of buses
%    NL : Number of branches
%     f : Vector with "from bus" indices of branches
%     t : Vector with "to bus" indices of branches
%    Zbranch : Branch serial impedance
%    Ybranch : Branch shunt admittances
%   Ysh : Bus shunt admittances
%    Sd : Load demand
%
%  See also VCPF.
[f, t, Zbranch, Ybranch, Sd, Qc] = ...
    deal(ds.branch(:,1),ds.branch(:,2), ...
         ds.branch(:,3)+1j*ds.branch(:,4),1j*ds.branch(:,5)/1e6, ...
         ds.branch(:,6)+1j*ds.branch(:,7),ds.branch(:,8));
NL = size(ds.branch,1);
NB = max([f; t]);
Zbase = ds.Ubase^2/ds.Sbase;
Sd = [0; Sd]/1000/ds.Sbase;
Ysh = [0; 1j*Qc]/1000/ds.Sbase;
Zbranch = Zbranch / Zbase;     
Ybranch = Ybranch * Zbase;