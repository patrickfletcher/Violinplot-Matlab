function bp = miniboxplot(data, cats, varargin)
%miniboxplot compact box plots of some data and categories
%   MINIBOXPLOT(DATA) plots a violin of a double vector DATA
%
%   MINIBOXPLOT(DATAMATRIX) plots violins for each column in
%   DATAMATRIX.
%
%   MINIBOXPLOT(TABLE), MINIBOXPLOT(STRUCT), MINIBOXPLOT(DATASET)
%   plots violins for each column in TABLE, each field in STRUCT, and
%   each variable in DATASET. The violins are labeled according to
%   the table/dataset variable name or the struct field name.
%
%   MINIBOXPLOT(DATAMATRIX, CATEGORYNAMES) plots violins for each
%   column in DATAMATRIX and labels them according to the names in the
%   cell-of-strings CATEGORYNAMES.
%
%   MINIBOXPLOT(DATA, CATEGORIES) where double vector DATA and vector
%   CATEGORIES are of equal length; plots violins for each category in
%   DATA.
%
%   violins = MINIBOXPLOT(...) returns an object array of
%   <a href="matlab:help('MiniBox')">MiniBox</a> objects.
%
%   MINIBOXPLOT(..., 'PARAM1', val1, 'PARAM2', val2, ...)
%   specifies optional name/value pairs for all violins:
%     'Width'        Width of the violin in axis space.
%                    Defaults to 0.3
%     'BoxColor'     Color of the box, whiskers, and the outlines of
%                    the median point and the notch indicators.
%                    Defaults to [0.5 0.5 0.5]
%     'MedianColor'  Fill color of the median and notch indicators.
%                    Defaults to [1 1 1]
%     'ShowOutliers' Whether to show outlier data points.
%                    Defaults to true
%     'ShowNotches'  Whether to show notch indicators.
%                    Defaults to false

% Copyright (c) 
% This code is released under the terms of the BSD 3-clause license

    hascategories = exist('cats','var') && not(isempty(cats));

    % tabular data
    if isa(data, 'dataset') || isstruct(data) || istable(data)
        if isa(data, 'dataset')
            colnames = data.Properties.VarNames;
        elseif istable(data)
            colnames = data.Properties.VariableNames;
        elseif isstruct(data)
            colnames = fieldnames(data);
        end
        catnames = {};
        for n=1:length(colnames)
            if isnumeric(data.(colnames{n}))
                catnames = [catnames colnames{n}];
            end
        end
        for n=1:length(catnames)
            thisData = data.(catnames{n});
            bp(n) = MiniBox(thisData, n, varargin{:});
        end
        set(gca, 'xtick', 1:length(catnames), 'xticklabels', catnames);

    % 1D data, one category for each data point
    elseif hascategories && numel(data) == numel(cats)
        cats = categorical(cats);
        catnames = categories(cats);
        for n=1:length(catnames)
            thisCat = catnames{n};
            thisData = data(cats == thisCat);
            bp(n) = MiniBox(thisData, n, varargin{:});
        end
        set(gca, 'xtick', 1:length(catnames), 'xticklabels', catnames);

    % 1D data, no categories
    elseif not(hascategories) && isvector(data)
        bp = MiniBox(data, 1, varargin{:});
        set(gca, 'xtick', 1);

    % 2D data with or without categories
    elseif ismatrix(data)
        for n=1:size(data, 2)
            thisData = data(:, n);
            bp(n) = MiniBox(thisData, n, varargin{:});
        end
        set(gca, 'xtick', 1:size(data, 2));
        if hascategories && length(cats) == size(data, 2)
            set(gca, 'xticklabels', cats);
        end

    end

end
