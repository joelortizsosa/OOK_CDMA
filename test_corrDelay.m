clear corr;
size_hadamar=8;
codes=generateHadamardMatrix(size_hadamar);
codes=codes*2 - 1;
for i=2:size_hadamar
   for ii=1:3
    corr(ii,:,i-1) = sum(codes(i,:).*delay(codes(i,:),size_hadamar,ii));
   end
end