function [out] = Spread(data, code1)

% ****************************************************************
%   data   : ch data sequence
%   out    : ch output data sequence
%   code1    : spread code sequence
% ****************************************************************

switch nargin
case { 0 , 1 }
    error('lack of input argument');
end

[hn,vn] = size(data);
[hc,vc] = size(code1);

if hn > hc
    error('lack of spread code sequences');
end

out = zeros(hn,vn*vc);

for ii=1:hn
    out(ii,:) = reshape((code1(ii,:))'*data(ii,:),1,vn*vc);
end

%******************************** end of file ********************************