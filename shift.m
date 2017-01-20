% Shift.m
% 
% Shift the contents of the register.
%
%

function [outregi] = shift (inregi , shiftr, shiftu)

%*********************************************************

% inregi        : Vector or matrix
% shiftr        : The amount of shift to the right.
% shiftu        : The amount of shift to the top.
% outregi       : Register output

%*********************************************************

[h, v] = size (inregi); % guarda el tamaño de la variable inregi en h y v
outregi = inregi;

%rem(X,Y), hace la division (X/Y) y entrega el valor restante antes de
%pasar a punto flotante

shiftr = rem(shiftr , v);
shiftu = rem(shiftu , h);

if shiftr > 0
    outregi(:,1       :shiftr) = inregi(:,v-shiftr+1:v       );
    outregi(:,1+shiftr:v     ) = inregi(:,1         :v-shiftr);
elseif shiftr < 0
    outregi(:,1         :v+shiftr) = inregi(:,1-shiftr:v      );
    outregi(:,v+shiftr+1:v       ) = inregi(:,1       :-shiftr);
end

inregi = outregi;

if shiftu > 0
    outregi(1         :h-shiftu,:) = inregi(1+shiftu:h,     :);
    outregi(h-shiftu+1:h,       :) = inregi(1       :shiftu,:);
elseif shiftu < 0
    outregi(1       :-shiftu,:) = inregi(h+shiftu+1:h,       :);
    outregi(1-shiftu:h,      :) = inregi(1         :h+shiftu,:);
end