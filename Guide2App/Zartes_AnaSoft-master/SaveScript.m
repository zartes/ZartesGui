list=who('ZTES*')
for i=1:length(list)
    cmd=strcat('save(''',list{i},''',''',list{i},''')')
    evalin('base',cmd)
end