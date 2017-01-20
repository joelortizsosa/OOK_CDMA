
function [out] = Rake_Receiver(data, code1,IR_Channel)

switch nargin
case { 0 , 1 , 2 }
    error('lack of input argument');
end

[hn,vn] = size(data);
[hc,vc] = size(code1);

vn      = fix(vn/vc);

out     = zeros(hc,vn);

sizeCh  = size(IR_Channel,2);

nbTrajets = sum((IR_Channel>0));

for ii=1:hc
    for k=1:sizeCh
       finger(k,:)=Despread(data(ii,k:end-(sizeCh-k)),code1(ii,:)).*IR_Channel(k); 
    end
    out(ii,:) = sum(finger,1)/(vc*nbTrajets);
end

%******************************** end of file ********************************













