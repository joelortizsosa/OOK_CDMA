function [H]=generateHadamardMatrix(codeSize)
N=2;
H=[1 1 ; 1 0];
if bitand(codeSize,codeSize-1)==0
    while(N~=codeSize)
        N=N*2;
        H=repmat(H,[2,2]);
        [m,n]=size(H);   
        
        %Invert the matrix located at the bottom right hand corner
        for i=m/2+1:m,
            for j=n/2+1:n,
                H(i,j)=~H(i,j);
            end
        end
    end
else
    disp('TAILLE DU CODE INVALIDE: La taille du code doit être une puissance de 2');
end
