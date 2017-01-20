% Program 2
% OOK_CDMA_RAKE_MRC.m
%
% Simulation program to realize Code Division Multiple Access (CDMA) using
% Coherent-OOK modulation system
%
% Programmed by Joel Ortiz Sosa,
% [H. Harada and R. Prasda, Simulation and Software Radio for Mobile Communications, Artech House, 2002]

%clear;
clearvars -except h1 h2
t=tic;
ebn0=25; % Eb/N0
fprintf('Max Eb/No simulation: %d dB\n',ebn0)
graficoxy = zeros(2,ebn0);
fprintf('Running ook_CDMA...\n')

%******************** Preparation part **********************

sr=256000.0;          % Symbol rate
ml=1;                 % bits par symbol
br=sr.*ml;            % Bit rate (=symbol rate in this case)
nd = 1000;            % Number of symbols that simulates in each loop
Multipath_Sim = 1;    % 1: Multipath + AWGN Simulation; 0: AWGN simulation
rake=1;               % 1: RAKE activated 0: RAKE desactivated

%******************** Impulse Reponse of Multipath **********
distance=[5 5 11.18 32.19]; % Distance entre le P1 et P2 defini par chaque tajectoire
Fchip=10;                   % Frequence Chip in GHz 
Er=11.9;
longCh=8;
multipath=multipathIR(Fchip,Er,distance,longCh,1);

for ebn0=0:ebn0

    %******************** START CALCULATION *********************
    nloop=1000;  % Number of sim11.ulation loops
    noe = 0;    % Number of error data
    nod = 0;    % Number of transmitted data
    
    %********************** Spreading code initialization **********************

    user  = 3;             % number of users
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
        %code = code(3:6,:);
        %code = [code(3,:);code(4,:);code(5,:);code(7,:);code(8,:)];
        %code = [code(7,:)];
        code = [code(3,:);code(4,:);code(5,:)];
        %code = [code(3,:);code(4,:);code(5,:);code(6,:)];
    end
    code = code * 2 - 1;
    clen = length(code);
 
        for iii=1:nloop

        %***************** Data generation ********************************  
            data=rand(user,nd*ml)>0.5;  % rand: built in function
        %***************** OOK Modulation *********************************  
            data1=data.*2-1;
            data2 = Spread(data1,code); 
            data2=data2>0;            

            if user == 1                                                 
                data3 = data2;
            else
                data3 = sum(data2);
                
            end                       
            
        %****************** Attenuation Calculation *********************** 
            spow=((1/(2*(nd)))*sum((data2.^2),2 ))';
            attn=spow*sr/br*10.^(-ebn0/10);
            attn=sqrt(attn);
        %********************** Fading channel ****************************
            
            if Multipath_Sim == 1
                multi=(conv(multipath,double(data3)));
            else
                multi=data3;
            end
        %************ Add White Gaussian Noise (AWGN) *********************
           data4=comb(multi,attn); 
        %******************** OOK Demodulation ****************************         
        
            if rake == 1                  
                data5= Rake_Receiver(data4, code, multipath);      
            else
                data5=Despread(data4(:,1:nd*clen),code);             
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


h1=figure(2);
%h=gcf;   % % current figure handle
%clf(h); % Clear current figure window
grid on; hold on;
%set(gca,'yscale','log','xlim',[graficoxy(2), graficoxy(end)],'ylim',

set(gca,'yscale','log','xlim',[graficoxy(2), 30],'ylim',[0 1]);
xlabel('Eb/No (dB)'); 
ylabel('BER'); 
set(h1,'NumberTitle','off');
set(h1,'Name','BER Results');
set(h1, 'renderer', 'zbuffer');  title('Coherent-OOK BER PLOTS');
if Multipath_Sim == 1
    semilogy(graficoxy(2,:),graficoxy(1,:),'r--o')
else
    semilogy(graficoxy(2,:),graficoxy(1,:),'k*')
end
mainComputationtime=toc(t)
fprintf('fin\n')

if (exist ('h2','var'))~=1
% Coherent-OOK AWGN-theory
EbN0_dB = 0:0.1:13;
EbN0 = 10.^(EbN0_dB/10);
BER = qfunc(sqrt(EbN0));
h2=semilogy(EbN0_dB,BER,'b');
%hold off
end

if Multipath_Sim == 1
    legend('OOK multipath simulated','OOK AWGN Theory')
else
    legend('OOK AWGN simulated','OOK AWGN Theory')
end