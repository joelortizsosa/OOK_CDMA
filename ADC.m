function [out] = ADC(data,n)

%****************** variables *************************
% Nb_trajets	 : Nombre de trajets, inclu le trajet direct
% Er             : la permittivité relative
% Distances      : Distance de trajectoire directe en [A B C D ...]mm
%                   A= Trajectoire Direct
% Gain           : Gain de chaque trajectoire [GA GB GC GD ....] 
% ******************************************************
out=zeros(size(data,1),size(data,2));
for i=1:size(data,1)
digital=floor(  (2^(n).*data(i,:))./( max(data(i,:))-min(data(i,:)))  );
out(i,:)= ( digital.*( ( max(data(i,:))-min(data(i,:)))   ) ) ./(2^(n));
end