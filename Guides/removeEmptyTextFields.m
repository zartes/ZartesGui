function s = removeEmptyTextFields( s )
% prevents the following error when Text field is empty, like after
% xml_struct = xml2struct( xml_file );
% struct2xml( xml_struct, xml_file );
% % Error using xmlwrite (line 82)
% % Java exception occurred:
% % java.lang.NullPointerException
% %
% % at com.mathworks.xml.XMLUtils.serializeXML(XMLUtils.java:192)
% %
% % at com.mathworks.xml.XMLUtils.serializeXML(XMLUtils.java:49)
% %
% %
% % Error in struct2xml (line 77)
% % xmlwrite(file,docNode);
switch class( s )
    case 'cell'
        s = cellfun( ...
            @removeEmptyTextFields,	s, ...
            'UniformOutput', false );
    case 'struct'
        if isfield( s, 'Text' )
            if isempty( s.Text )
                s	= rmfield( s, 'Text' );
            end%if%isempty
        end%if%isfield
        if isempty( s ) ||	...
                isequal( s, struct() )
            return;
        end%if%isempty
        s = structfun( ...
            @removeEmptyTextFields,	s, ...
            'UniformOutput', false );
    otherwise
        % do nothing
end%switch%case%class(s)
end%function%removeEmptyTextFields