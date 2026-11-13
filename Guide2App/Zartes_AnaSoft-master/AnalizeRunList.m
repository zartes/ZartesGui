function Results=AnalizeRunList(anaList)
%%%%%
for i=1:numel(anaList)
    Results(i)=AnalizeRun(anaList(i));
end