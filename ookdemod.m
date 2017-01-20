
function [demodata]=ookdemod(data,para,nd)

%****************** variables *************************
% data :input Ich data
% demodata: demodulated data (para-by-nd matrix)
% para   : Number of paralell channels
% nd : Number of data
% *****************************************************

demodata=zeros(para,1*nd);
demodata((1:para),(1:1:1*nd))=data((1:para),(1:nd))>=0;

%******************** end of file ***************************
