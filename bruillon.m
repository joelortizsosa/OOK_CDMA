close all;
data = randi([0 1],1000,1);
hMod = comm.BPSKModulator;
modData = step(hMod, data);
figure(1);
stem(modData)
txSig = 0.1*modData;
figure(2)
stem((txSig))


rxSig = step(hAGC,real(txSig));
figure(3)
stem((rxSig))
h = scatterplot(txSig(200:end),1,0,'*');
figure(4)
hold on
scatterplot(rxSig(200:end),1,0,'or',h);
legend('Input of AGC', 'Output of AGC')
