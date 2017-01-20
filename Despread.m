function [out] = Despread(data, code1)

switch nargin
case { 0 , 1 }
    error('lack of input argument');
end

[hn,vn] = size(data);
[hc,vc] = size(code1);

vn      = fix(vn/vc);

out    = zeros(hc,vn);

code1=repmat(code1,1,vn);

for ii=1:hc
    out(ii,:) =sum(reshape(data(ii,:).*code1(ii,:), vc, vn ));
end

%******************************** end of file ********************************













