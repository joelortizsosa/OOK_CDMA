
function [out] = despread(data, code1)

switch nargin
case { 0 , 1 }
    error('lack of input argument');
end

[hn,vn] = size(data);
[hc,vc] = size(code1);

vn      = fix(vn/vc);

out    = zeros(hc,vn);


for ii=1:hc
    out(ii,:) = rot90(flipud(rot90(reshape(data(ii,:),vc,vn)))*rot90(code1(ii,:),3));
end

%******************************** end of file ********************************
