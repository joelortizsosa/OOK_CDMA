% Program 1
% ook.m
%
% Simulation program to realize Coherent-OOK transmission system
%
% Programmed by Joel Ortiz Sosa,
% [H. Harada and R. Prasda, Simulation and Software Radio for Mobile Communications, Artech House, 2002]


clear;
t=tic;
ebn0=25 % Eb/N0 simulation de 0 -15
graficoxy = zeros(2,ebn0);

%******************** Preparation part **********************
sr=256000.0;         % Symbol rate
ml=1;                % bits par symbol
br=sr.*ml;           % Bit rate (=symbol rate in this case)
nd = 10000;           % Number of symbols that simulates in each loop
Multipath_Sim = 1;    % 1: Multipath + AWGN Simulation; 0: AWGN simulation

%******************** Impulse Reponse of Multipath **********

Gain= [1 1./4 1./8 1./10]; % Gain de Chaque impulse de Multipath
distance=[5 5 11.18 32.19]; % Distance entre le P1 et P2 defini par chaque tajectoire
multipath=multipathIR(11.9,distance,Gain);
figure(1);
stem(multipath)
h=gcf; 
grid on; 
title('Impulse Response');
xlabel('delay (pS)'); 
ylabel('Gain');
set(h,'NumberTitle','off');
set(h,'Name','Multipath Fading ');
for ebn0=0:ebn0

        %******************** START CALCULATION *********************
        nloop=100;  % Number of simulation loops
        noe = 0;    % Number of error data
        nod = 0;    % Number of transmitted data
        
        for iii=1:nloop

        %***************** Data generation ********************************  

            data=rand(1,nd)>0.5;  % rand: built in function
        %***************** OOK Modulation *********************************  
        % We use one signal entre -1 et 1
        % So in OOK 1=A*sin(wo*t) et -1=0
        % in BPSK 1=A*sin(wo*t + 0)  -1 = A*sin(wo*t + pi)
            data1=data.*2-1;
        %****************** Attenuation Calculation ***********************
        % npow: noise power
        % spow: Signal Power
        % in OOK the spow=spow
        % in BPSK spow=spow/2
            spow=sum(data1.*data1)/nd;
            npow=spow*sr/br*10.^(-ebn0/10);
            attn=sqrt(npow);
        %********************** Fading channel ****************************
            if Multipath_Sim == 1
                multi=conv(multipath,data1);
            else
                multi=data1;
            end
        %************ Add White Gaussian Noise (AWGN) *********************
            data2=multi;
            inoise=randn(1,length(data2)).*attn;  % randn: built in function
            data4=data2+inoise;    
        %******************** OOK Demodulation ****************************
     
            demodata=data4 > 0;
        %******************** Bit Error Rate (BER) ************************
         if Multipath_Sim == 1
            noe2=sum(abs(data-demodata(1,1:size(data,2))));  % sum: built in function
         else
            noe2=sum(abs(data-demodata));  % sum: built in function
         end
            nod2=length(data);  % length: built in function
            noe=noe+noe2;
            nod=nod+nod2;
        end % for iii=1:nloop    
    ber = noe / nod;
    graficoxy(1,ebn0+1)=noe/nod;
    graficoxy(2,ebn0+1)=ebn0;
end
figure(2);
h=gcf;   % % current figure handle
%clf(h); % Clear current figure window
grid on; hold on;
set(gca,'yscale','log','xlim',[graficoxy(2), graficoxy(end)],'ylim',[0 1]);
xlabel('Eb/No (dB)'); 
ylabel('BER'); 
set(h,'NumberTitle','off');
set(h,'Name','BER Results');
set(h, 'renderer', 'zbuffer');  title('Coherent-OOK BER PLOTS');
semilogy(graficoxy(2,:),graficoxy(1,:),'r*')
mainComputationtime=toc(t)
fprintf('fin\n')

% Coherent-OOK AWGN-theory
EbN0_dB = 0:0.1:13;
EbN0 = 10.^(EbN0_dB/10);
BER = qfunc(sqrt(EbN0));
semilogy(EbN0_dB,BER,'b')

% BPSK AWGN-theory
EbN0_dB = 0:0.1:10;
EbN0 = 10.^(EbN0_dB/10);
BER = qfunc(sqrt(2*EbN0));
semilogy(EbN0_dB,BER,'k')

legend('OOK simulated','OOK AWGN Theory', 'BPSK AWGN Theory')
