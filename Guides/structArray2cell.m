function s = structArray2cell( s )
% to avoid num2cell(s) in exterior function
switch class( s )
    case 'cell'
        s = cellfun( ...
            @structArray2cell, s, ...
            'UniformOutput', false );
    case 'struct'
        if isempty( s ) ||	...
                isequal( s, struct() )
            return;
        elseif	isscalar( s )
            s = structfun( ...
                @structArray2cell, s, ...
                'UniformOutput', false );
        else%if	~isscalar( s )
            s = structArray2cell( num2cell( s ) );
        end%ifs
    otherwise
        % do nothing
end%switch%case%class(s)
end%function%structArray2cell