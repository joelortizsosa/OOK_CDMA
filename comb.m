function [out]= comb (data, attn)

v = length (data);
h = length (attn);
out = zeros (h,v);

for ii = 1:h
    out (ii,:) = data + randn(1,v) * attn(ii);
end
