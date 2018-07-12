function [U, Sslack, Sg, Sf, St, iter] = vcpf(Uslack,NB,NL,f,Zbranch,Ybranch,Yd,Sd,gen_bus,Sg,Ug,gen_type,epsilon,iter_max)
%CALC_V_PQ_SUM  Solves the power flow using the power summation method.
%
%   [U, Sslack, Sg, Sf, St, iter] = vcpf(Uslack,NB,NL,f,Zbranch,Ybranch,Yd,Sd,gen_bus,Sg,Ug,gen_type,epsilon,iter_max)
%
%   Solves for bus voltages, generator reactive power, branch active and
%   reactive power flows and slack bus active and reactive power. The input
%   data consist of slack bus voltage, number of buses and branches,
%   vector "from bus" indices, branch impedance and shunt admittance,
%   vector of bus shunt admittances and load demand, as well as vectors
%   with indicies of PV buses with their active powers and specified voltages.
%   It is assumed that the branches are ordered using the principle of
%   oriented ordering: indicies of sending nodes are smaller then the indicies
%   of the receiving nodes. The branch index is equal to the index of their
%   receiving node. Branch addmittances are added in Yd and treated as constant
%   admittance bus loads.
%   The applied method is Voltage correction power flow (VCPF) taken from:
%   D. Rajicic, R. Ackovski and R. Taleski, "Voltage correction power flow,"
%   IEEE Transactions on Power Delivery, vol. 9, no. 2, pp. 1056-1062, Apr 1994.
%   https://doi.org/10.1109/61.296308
%
%   See also DIST_PF.


% initialize variables
U = Uslack * ones(NB,1);
Uold = U;
iter = 0;
finish = 0;
% Add artificial branch at the top of branches, so that the number of each
% branch equals the number of the receiving node
      f = [0; f];
Zbranch = [0; Zbranch];
NL = NL + 1;
% Split generators into PQ type and PV type
gen_pq = find(gen_type == 1);
gen_pv = find(gen_type == 2);
pv = gen_bus(gen_pv);
Ug = Ug(gen_pv);
% For generators of type PQ add negative of their complex power to bus load
Sd(gen_bus(gen_pq)) = Sd(gen_bus(gen_pq)) - Sg(gen_pq);
% For generators of type PV add negative of their real power to bus load
Sd(gen_bus(gen_pv)) = Sd(gen_bus(gen_pv)) - real(Sg(gen_pv));
% Make impedance matrix for all PV buses
Zpv = make_zpv(pv,NB,NL,f,Zbranch);
if size(Zpv,1) > 0
  Bpv = (imag(Zpv))^-1;
end
% Voltage Correction Power Flow
npv = length(pv);
Qpv = zeros(npv,1);
while finish == 0 && iter < iter_max
    iter = iter + 1;
    % Initial branch flows, equal to receiving node load (incl. shunts)
    S = Sd + conj(Yd).*abs(U).^2;
    St = S;
    Sf = St;
    % Backward sweep
    for k = NL:-1:2
        i = f(k);
        Sf(k) = St(k) + Zbranch(k) * abs(St(k)/U(k))^2;
        St(i) = St(i) + Sf(k);
    end
    % Forward sweep
    for k = 2:NL
        i = f(k);
        U(k) = U(i) - Zbranch(k) * conj(Sf(k)/U(i));
    end
    % Check convergence
    DU = abs(U - Uold);
    if max(DU) > epsilon
        Uold = U;
        if ~isempty(pv)
            % Calculate reactive power correction for PV generators
            DE = (Ug./abs(U(pv))-1).*real(U(pv)); % Rajicic (VCPF)
            DD = Bpv * DE;
            DC = DD .* imag(U(pv))./real(U(pv));
            % Make voltage correction
            V_corr = make_vcorr(DC+1j*DD,pv,NB,NL,f,Zbranch);
            U = U + V_corr;
            DQ = DD .* abs(U(pv)).^2 ./ real(U(pv));
            % Update reactive power for PV generators
            Qpv = Qpv + DQ;
            Sd(pv) = Sd(pv) - 1j*DQ;
        end
    else
        finish = 1;
    end
end
% Save generators reactive powers and branch flows
if ~isempty(gen_pv)
    Sg(gen_pv) = real(Sg(gen_pv)) + 1j*Qpv;
end
Sslack = St(1);
Sf = Sf(2:end);
St = St(2:end);
f = f(2:end);
% Account for branch shunt power flows
Sf = Sf + conj(Ybranch) .* abs(U(f)).^2 / 2;
St = St - conj(Ybranch) .* abs(U(2:end)).^2 / 2;