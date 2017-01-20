function [out] = multipathIR(Fchip,Er,Distances,Longueur_canal,Figure)

%****************** variables *************************
% Nb_trajets	 : Nombre de trajets, inclu le trajet direct
% Er             : la permittivité relative
% Distances      : Distance de trajectoire directe en [A B C D ...]mm
%                   A= Trajectoire Direct
% Gain           : Gain de chaque trajectoire [GA GB GC GD ....] 
% *****************************************************

switch nargin
    case { 0 , 1 , 2, 3}
        error('lack of input argument');
    case 4
        Figure=1; 
end

 if size(Distances,2) > Longueur_canal
     error('The size vector of distances should be less than the size of channel ');
 end
 

Tc=(1/Fchip)*1000; %Temp chip in pS 
Nb_trajets=size(Distances,2);
c=3*10^8;
E0=8.854*10^(-12);
u0=4*pi*10^(-7);
ur=1;
    if Er==1
        v=c;
    else
        v=sqrt(1/(E0*Er*u0*ur));
    end
    
Elapsed_time=zeros(1,Nb_trajets);

for jj=1:Nb_trajets
    if jj==1 
        Elapsed_time(jj)= round((Distances(jj)*10^(-3)/c)*10^12);
    else
        Elapsed_time(jj)= round((Distances(jj)*10^(-3)/v)*10^12);
    end
    
end
multipath=zeros(1,Longueur_canal);

% Resolvable multipath
cnt=1;
for jj=1:Nb_trajets
    if jj==1
        trajetResolvable(jj) = Elapsed_time(jj);
        d(jj)=Distances(jj);
    else
        if Elapsed_time(jj) > Tc
            cnt=cnt+1;
            trajetResolvable(cnt) = Elapsed_time(jj);
            d(cnt)=Distances(jj);
        end
    end
end

for jj=1:size(trajetResolvable,2)
    
attTD(jj)=(1/sqrt(size(trajetResolvable,2)))/(d(jj)/d(1))   ; % Attenuation
end

for jj=1:size(trajetResolvable,2)
    index = floor(trajetResolvable(jj)/Tc)+1;
    multipath(1,index)=attTD(jj);
end



if Figure==1

    time=[0 100 200 300 400 500 600 700];
    h=figure(1);
    stem(time,multipath)
    %h=gcf;
    grid on; 
    title('Impulse Response');
    xlabel('delay (pS)'); 
    ylabel('Gain');
    set(h,'NumberTitle','off');
    set(h,'Name','Multipath');
end
out=multipath;


%******************** end of file ***************************














































% multipath=[1/sqrt(2) (1/sqrt(2))/2 0 (1/sqrt(2))/3 0 0 0 0];
% time=[0 100 200 300 400 500 600 700];
% figure(1);
% stem(time,multipath)
% h=gcf;
% grid on; 
% title('Impulse Response');
% xlabel('delay (pS)'); 
% ylabel('Gain');
% set(h,'NumberTitle','off');
% set(h,'Name','Multipath Fading ');