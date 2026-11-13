function [b,varargout]=within(range,x)
%%%chequea si x está en range y devuelve los puntos 
%anterior y posterior en caso afirmativo

if x>=min(range) && x<= max(range)
    b=1;
    [~,ind]=sort(abs(range-x));
    varargout{1}=ind(1:2);%%%esto fallaria si x=max(range).
else
    b=0;
    varargout{1}=[];
end