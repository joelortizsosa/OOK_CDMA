% Program 2
% ook-CDMA.m
%
% Simulation program to realize Code Division Multiple Access (CDMA) using
% Coherent-OOK modulation system
%
% Programmed by Joel Ortiz Sosa,
% [H. Harada and R. Prasda, Simulation and Software Radio for Mobile Communications, Artech House, 2002]

clear;
t=tic;
ebn0=20; % Eb/N0
fprintf('Max Eb/No simulation: %d dB\n',ebn0)
graficoxy = zeros(2,ebn0);
fprintf('Running ook_CDMA...\n')

%******************** Preparation part **********************
sr=256000.0; % Symbol rate
ml=1;        % bits par symbol
br=sr.*ml;   % Bit rate (=symbol rate in this case)
nd = 1000;   % Number of symbols that simulates in each loop
Multipath_Sim = 1;    % 1: Multipath + AWGN Simulation; 0: AWGN simulation
rake=1;

%******************** Impulse Reponse of Multipath **********
%Gain= [1 1./4 1./8 1./10]; % Gain de Chaque impulse de Multipath
%distance=[5 5 11.18 32.19]; % Distance entre le P1 et P2 defini par chaque tajectoire
%multipath=multipathIR(Fchip,Fporteuse,distance,Gain);
multipath=[1 1 0 1 0 0 0 0];
figure(1);
stem(multipath)
h=gcf;
grid on; 
title('Impulse Response');
xlabel('delay (pS)'); 
ylabel('Gain');
set(h,'NumberTitle','off');
set(h,'Name','Multipath Fading ');
%************************** Filter initialization **************************
% irfn   = 21;                                                        % number of filter taps
% IPOINT =  4;                                                        % number of oversample
% alfs   =  0.5;                                                      % roll off factor
% [xh]   = hrollfcoef(irfn,IPOINT,sr,alfs,1);                         % T FILTER FUNCTION
% [xh2]  = hrollfcoef(irfn,IPOINT,sr,alfs,0);                         % R FILTER FUNCTION

for ebn0=0:ebn0

    %******************** START CALCULATION *********************
    nloop=1000;  % Number of sim11.ulation loops
    noe = 0;    % Number of error data
    nod = 0;    % Number of transmitted data
    
    %********************** Spreading code initialization **********************

    user  = 1;             % number of users
    seq   = 4;             % 1:M-sequence  2:Gold  3:Orthogonal Gold 4:Hadamar codes
    size_hadamar=8;        % 8: max 7 user 16: max 15 users 
    if seq~=4
    stage = 3;             % number of stages   
    ptap1 = [1 3];         % position of taps for 1st
    ptap2 = [2 3];         % position of taps for 2nd
    regi1 = [1 0 1];       % initial value of register for 1st
    regi2 = [0 1 1];       % initial value of register for 2nd
    end
    
    
    %******************** Generation of the spreading code *********************
    switch seq
    case 1                                       % M-sequence
        code = mseq(stage,ptap1,regi1,user);
    case 2                                       % Gold sequence
        m1   = mseq(stage,ptap1,regi1);
        m2   = mseq(stage,ptap2,regi2);
        code = goldseq(m1,m2,user);
    case 3                                       % Orthogonal Gold sequence
        m1   = mseq(stage,ptap1,regi1);
        m2   = mseq(stage,ptap2,regi2);
        code = [goldseq(m1,m2,user),zeros(user,1)];
    case 4
        code = generateHadamardMatrix(size_hadamar);
        code = code(7,:);
    end
    
    Gcode=1/sqrt(size_hadamar);
    code = code * 2 - 1;
    code = code.*Gcode; 
    clen = length(code);
    G=1/(3^(1/3)); % Normalization du canal
    for k=1:size(multipath,2) % Codes uutilisé dans chaque doigt du RAKE
        if multipath(k)~=0
        codeRake(k,:)=delay(code,clen,k-1);
        attRake(k)=multipath(k);
        end
    end
    
        for iii=1:nloop

        %***************** Data generation ********************************  
            data=rand(user,nd*ml)>0.5;  % rand: built in function
        %***************** OOK Modulation *********************************  
            data1=data.*2-1;
            data2 = spread(data1,code); 
            %data2=data2>0;
           
            %Si N vers 1, on fait le suréchantionnage et le filtrage en ce partie.            

            if user == 1                                                 
                data3 = data2;
            else
                data3 = sum(data2);
            end   
            %si 1 vers N , il faut faire le suréchantionnage après.
            %[dataOS,qch2] = compoversamp2(data2,data2,IPOINT); 
            % suréchantionnage , sur la réponse impulsionnelle de canal et la data 
            % convolution 1) Data suréchantionné avec la réponse de filtre
            % [dataOS,qch3] = compconv2(dataOS,dataOS,xh);                     
            
            
        %****************** Attenuation Calculation *********************** 
            spow=(1/(1*(nd)))*sum( rot90(data2.^2) );
            attn=spow*sr/br*10.^(-ebn0/10);
            attn=sqrt(attn);
        %********************** Fading channel ****************************
            
            if Multipath_Sim == 1
                multi=(conv(multipath,double(data3))).*G;
            else
                multi=data3;
            end
        %************ Add White Gaussian Noise (AWGN) *********************
           data4=comb(multi,attn); 
        %******************** OOK Demodulation ****************************
            % [data5,qch7] = compconv2(data4,data4,xh2);                                    
            % sampl = irfn * IPOINT + 1;
            % data6  = data5(:,sampl:IPOINT:IPOINT*nd*clen+sampl-1);  
             
            if rake == 1   
                for k=1:size(multipath,2)
                    if multipath(k)~= 0 
                        dataRake(k,:)=despread(data4(:,1:nd*clen),codeRake(k,:).*G);
                    end
                end
                data5=sum(dataRake);                
            else
                data5=despread(data4(:,1:nd*clen),code);             
            end    
            
            demodata=ookdemod(data5,user,nd);
        %******************** Bit Error Rate (BER) ************************
            noe2=sum(sum(abs(data-demodata)));
            nod2=user*nd*log2(ml*2);
            noe=noe+noe2;
            nod=nod+nod2;
        end % for iii=1:nloop    
    ber = noe / nod;
    graficoxy(1,ebn0+1)=noe/nod;
    graficoxy(2,ebn0+1)=ebn0;
end


figure(3);
h=gcf;   % % current figure handle
%clf(h); % Clear current figure window
grid on; hold on;
%set(gca,'yscale','log','xlim',[graficoxy(2), graficoxy(end)],'ylim',[0 1]);
set(gca,'yscale','log','xlim',[graficoxy(2), 20],'ylim',[0 1]);
xlabel('Eb/No (dB)'); 
ylabel('BER'); 
set(h,'NumberTitle','off');
set(h,'Name','BER Results');
set(h, 'renderer', 'zbuffer');  title('Coherent-OOK BER PLOTS');
if Multipath_Sim == 1
    semilogy(graficoxy(2,:),graficoxy(1,:),'k-*')
else
    semilogy(graficoxy(2,:),graficoxy(1,:),'k*')
end
mainComputationtime=toc(t)
fprintf('fin\n')

% Coherent-OOK AWGN-theory
EbN0_dB = 0:0.1:13;
EbN0 = 10.^(EbN0_dB/10);
BER = qfunc(sqrt(EbN0));
semilogy(EbN0_dB,BER,'b')


if Multipath_Sim == 1
    legend('OOK multipath simulated','OOK AWGN Theory')
else
    legend('OOK AWGN simulated','OOK AWGN Theory')
end
