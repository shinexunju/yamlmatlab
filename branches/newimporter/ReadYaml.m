%==========================================================================
% Reads YAML file, converts YAML sequences to MATLAB cell columns and YAML
% mappings to MATLAB structs
%==========================================================================
function result = ReadYaml(filename)
    [pth,~,~,~] = fileparts(mfilename('fullpath'));
    javaaddpath([pth '\external\snakeyaml-1.8.jar']);
    import('org.yaml.snakeyaml.Yaml');
    yaml = Yaml();
    data = yaml.load(fileread(filename));
    result = scan(data);
end

%--------------------------------------------------------------------------
% Determine node type and call appropriate conversion routine. 
%
function result = scan(r)
    if isa(r, 'char')
        result = scan_string(r);
    elseif isa(r, 'double')
        result = scan_numeric(r);
    elseif isa(r, 'java.util.Date')
        result = scan_datetime(r);
    elseif isa(r, 'java.util.List')
        result = scan_list(r);
    elseif isa(r, 'java.util.Map')
        result = scan_map(r);
    else
        error(['Unknown data type: ' class(r)]);
    end;
end

%--------------------------------------------------------------------------
% Transforms Java String to MATLAB char
%
function result = scan_string(r)
    result = char(r);
end

%--------------------------------------------------------------------------
% Transforms Java double to MATLAB double
%
function result = scan_numeric(r)
    result = double(r);
end

%--------------------------------------------------------------------------
% Transforms Java Date class to MATLAB DateTime class
%
function result = scan_datetime(r)
    result = DateTime(r);
end

%--------------------------------------------------------------------------
% Transforms Java List to MATLAB cell column running scan(...) recursively
% for all ListS items.
%
function result = scan_list(r)
    result = cell(r.size(),1);
    it = r.iterator();
    ii = 1;
    while it.hasNext()
        i = it.next();
        result{ii} = scan(i);
        ii = ii + 1;
    end;
end

%--------------------------------------------------------------------------
% Transforms Java Map to MATLAB struct running scan(...) recursively for
% content of every Map field.
%
function result = scan_map(r)
    it = r.keySet().iterator();
    while it.hasNext()
        i = java.lang.String(it.next());
        result.(char(i)) = scan(r.get(i));
    end;
end

%==========================================================================

