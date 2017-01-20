%Autocorr.m
%
%Autocorrelation function of a sequence
%
function [out] = autocorr(indata , tn )

%**********************************************************
%  indata  :   input  sequence
%  tn      :   number of period
%  out     :   autocorrelation data

%**********************************************************

if nargin < 2 % if the number of elements is less than 2 then
   tn = 1; % valeur par defaut
end

ln = length (indata); % mésurer la quantité des données sur la variable
out = zeros(1, ln*tn); % array of zeros de 1 by (ln*tn)

for ii = 0:ln*tn - 1
    out (ii+1) = sum (indata.*shift(indata,ii,0));
end

%********************* end of file************************