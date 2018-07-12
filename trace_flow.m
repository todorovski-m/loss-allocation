function J = trace_flow(Id,f,t,If,gen_bus,Ig)
%TRACE_FLOW  Calculates load current components supplied by each generator.
%
%   J = trace_flow(Id,f,t,If,gen_bus,Ig)
%
%   Inputs:
%        Id : Bus load current
%         f : Vector with "from bus" indices of branches
%         t : Vector with "to bus" indices of branches
%        If : Vector with branch current at the "from bus" end
%   gen_bus : Vector with generator buses
%        Ig : Generator currents
%
%   Output:
%         J : Matrix with load current components supplied by each generator.
%             J(i,j) is a portion of load current at bus "i" supplied by
%             the generator "j"
%
%  See also LOSS_ALLOCATION.


%% basic system data
NL = length(f); % number of lines
NB = NL + 1; % number of buses
NG = length(Ig); % number of generators
Ig = sparse(gen_bus,ones(NG,1),Ig,NB,1); % convert Ig to full length vector with NB elements
%% convert negative generation to load
i = find(Ig < 0);
Id(i) = Id(i) - Ig(i); % add generator current to load current
Ig(i) = 0; % switch off the generator
%% make bus-branch incidence matrix (connection matrix)
C = sparse(1:NL,f,ones(NL,1),NL,NB) - sparse(1:NL,t,ones(NL,1),NL,NB);
%% calculate local load supply by a generator at the same bus
i = find(Id(gen_bus));
gen_load = gen_bus(i); % buses with both generator and load
J1 = zeros(NB); % matrix of load current componets supply by the local generator
for i = 1:length(gen_load)
    j = gen_load(i); % bus j
    if Ig(j) >= Id(j)
        % whole load is supplied by the local generator, the generator
        % current is reduced by Id(j) -- the remaining generator current
        % goes to other loads
        J1(j,j) = Id(j);
        Ig(j) = Ig(j) - Id(j);
        Id(j) = 0;
    else
        % whole generator current is consumed localy, the load current is
        % reduced by Ig(j) -- the remaining load is supplied by other
        % generators
        J1(j,j) = Ig(j);
        Id(j) = Id(j) - Ig(j);
        Ig(j) = 0;
    end
end
%% calculate sum of current inflows
I = Ig;
for i = 1:NB
    Ib = -C(:,i) .* If; % flows in branches connected to bus i
    k = Ib > 0; % find positive flows, i.e. inflows to bus i
    I(i) = I(i) + sum(Ib(k)); % sum the current inflows
end
%% make flow distribution matrix
A = eye(NB);
for i = 1:NB
    Ib = -C(:,i) .* If; % flows in branches connected to bus i
    k = Ib > 0; % find positive flows, i.e. inflows to bus i
    Ctemp = C; Ctemp(:,i) = 0; % remove connections to bus i in Ctemp
    [~,j] = find(Ctemp(k,:)); % find from which buses the inflows are coming
    A(i,j) = -Ib(k)./I(j);
end
%% calculate components of load currents
% current components are a sum of components calculated using the flow
% distribution matrix and componets supplied localy (calculated earlier as
% J1)
J = diag(Id./I)*A^-1*diag(Ig) + J1;
