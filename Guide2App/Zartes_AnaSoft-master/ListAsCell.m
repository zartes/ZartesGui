function files=ListAsCell(string)
%%%Lista ficehros con un string y los convierte a Cell.
f=ls(string);
[i,j]=size(f);
files=mat2cell(f,ones(1,i),j);