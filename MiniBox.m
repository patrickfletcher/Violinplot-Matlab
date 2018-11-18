classdef MiniBox < handle
    % MiniBox represents a simple boxplot similar to matlab's boxplot with
    % plotstyle 'compact'

    properties
        BoxPlot     % fill plot of the box between the quartiles
        WhiskerPlot % line plot between the whisker ends
        MedianPlot  % scatter plot of the median (one point)
        NotchPlots  % scatter plots for the notch indicators
        OutlierPoints % scatter plot of points beyond the whiskers
    end

    properties (Dependent=true)
        BoxColor    % color of box, whiskers, and median/notch edges
        BoxWidth    % width of box between the quartiles in axis space (default 10% of Violin plot width, 0.03)
        MedianColor % fill color of median and notches
        ShowOutliers    % whether to show data points beyond the whiskers
        ShowNotches % whether to show notch indicators
    end

    methods
        function obj = MiniBox(data, pos, varargin)
            %MiniBox plots a violin plot of some data at pos
            %   MINIBOX(DATA, POS) plots a violin at x-position POS for
            %   a vector of DATA points.
            %
            %   MINIBOX(..., 'PARAM1', val1, 'PARAM2', val2, ...)
            %   specifies optional name/value pairs:
            %     'Width'        Width of the violin in axis space.
            %                    Defaults to 0.3
            %     'BoxColor'     Color of the box, whiskers, and the
            %                    outlines of the median point and the
            %                    notch indicators. Defaults to
            %                    [0.5 0.5 0.5]
            %     'MedianColor'  Fill color of the median and notch
            %                    indicators. Defaults to [1 1 1]
            %     'ShowOutliers' Whether to show outlier data points.
            %                    Defaults to true
            %     'ShowNotches'  Whether to show notch indicators.
            %                    Defaults to false

            args = obj.checkInputs(data, pos, varargin{:});
            data = data(not(isnan(data)));
            if numel(data) == 1
                obj.MedianPlot = scatter(pos, data, 'filled');
                obj.MedianColor = args.MedianColor;
                obj.MedianPlot.MarkerEdgeColor = args.EdgeColor;
                return
            end

            hold('on');

            % plot the mini-boxplot within the violin
            quartiles = quantile(data, [0.25, 0.5, 0.75]);         
            obj.BoxPlot = ... % plot color will be overwritten later
                fill(pos+[-1,1,1,-1]*args.BoxWidth/2, ...
                     [quartiles(1) quartiles(1) quartiles(3) quartiles(3)], ...
                     [1 1 1]);
                 
            %whiskers
            IQR = quartiles(3) - quartiles(1);
            lowhisker = quartiles(1) - 1.5*IQR;
            lowhisker = max(lowhisker, min(data(data > lowhisker)));
            hiwhisker = quartiles(3) + 1.5*IQR;
            hiwhisker = min(hiwhisker, max(data(data < hiwhisker)));
            if ~isempty(lowhisker) && ~isempty(hiwhisker)
                obj.WhiskerPlot = plot([pos pos], [lowhisker hiwhisker]);
            end
            
            %outlier data points (beyond whiskers)
            outliers=data(data>hiwhisker | data<lowhisker);
            jitterstrength = args.Width;
            jitter = 2*(rand(size(outliers))-0.5);
            obj.OutlierPoints = ...
                scatter(pos + jitter.*jitterstrength, outliers,[],args.BoxColor, 'filled');
            obj.OutlierPoints.Marker='+';
            
            obj.MedianPlot = scatter(pos, quartiles(2), [], [1 1 1], 'filled');

            obj.NotchPlots = ...
                 scatter(pos, quartiles(2)-1.57*IQR/sqrt(length(data)), ...
                         [], [1 1 1], 'filled', '^');
            obj.NotchPlots(2) = ...
                 scatter(pos, quartiles(2)+1.57*IQR/sqrt(length(data)), ...
                         [], [1 1 1], 'filled', 'v');

            obj.BoxColor = args.BoxColor;
            obj.BoxWidth = args.BoxWidth;
            obj.MedianColor = args.MedianColor;
            obj.ShowOutliers = args.ShowOutliers;
            obj.ShowNotches = args.ShowNotches;
        end
        function set.BoxColor(obj, color)
            obj.MedianPlot.MarkerEdgeColor = color;
            if ~isempty(obj.BoxPlot)
                obj.BoxPlot.FaceColor = color;
                obj.BoxPlot.EdgeColor = color;
                obj.OutlierPoints.MarkerEdgeColor=color;
                obj.WhiskerPlot.Color = color;
                obj.NotchPlots(1).MarkerFaceColor = color;
                obj.NotchPlots(2).MarkerFaceColor = color;
            end
        end

        function color = get.BoxColor(obj)
            if ~isempty(obj.BoxPlot)
                color = obj.BoxPlot.FaceColor;
            end
        end

        function set.MedianColor(obj, color)
            obj.MedianPlot.MarkerFaceColor = color;
            if ~isempty(obj.NotchPlots)
                obj.NotchPlots(1).MarkerFaceColor = color;
                obj.NotchPlots(2).MarkerFaceColor = color;
            end
        end

        function color = get.MedianColor(obj)
            color = obj.MedianPlot.MarkerFaceColor;
        end

        
        function set.BoxWidth(obj,width)
            if ~isempty(obj.BoxPlot)
                pos=mean(obj.BoxPlot.XData);
                obj.BoxPlot.XData=pos+[-1,1,1,-1]*width/2;
            end
        end
        
        function width = get.BoxWidth(obj)
            width=max(obj.BoxPlot.XData)-min(obj.BoxPlot.XData);
        end


        function set.ShowOutliers(obj, yesno)
            if yesno
                obj.OutlierPoints.Visible = 'on';
            else
                obj.OutlierPoints.Visible = 'off';
            end
        end

        function yesno = get.ShowOutliers(obj)
            yesno = strcmp(obj.OutlierPoints.Visible, 'on');
        end

        function set.ShowNotches(obj, yesno)
            if yesno
                obj.NotchPlots(1).Visible = 'on';
                obj.NotchPlots(2).Visible = 'on';
            else
                obj.NotchPlots(1).Visible = 'off';
                obj.NotchPlots(2).Visible = 'off';
            end
        end

        function yesno = get.ShowNotches(obj)
            yesno = strcmp(obj.NotchPlots(1).Visible, 'on');
        end

    end

    methods (Access=private)
        function results = checkInputs(obj, data, pos, varargin)
            isscalarnumber = @(x) (isnumeric(x) & isscalar(x));
            p = inputParser();
            p.addRequired('Data', @isnumeric);
            p.addRequired('Pos', isscalarnumber);
            p.addParameter('Width', 0.0, isscalarnumber);
            iscolor = @(x) (isnumeric(x) & length(x) == 3);
            p.addParameter('BoxColor', [0.5 0.5 0.5], iscolor);
            p.addParameter('BoxWidth', 0.03, isscalarnumber);
            p.addParameter('EdgeColor', [0.5 0.5 0.5], iscolor);
            p.addParameter('MedianColor', [1 1 1], iscolor);
            isscalarlogical = @(x) (islogical(x) & isscalar(x));
            p.addParameter('ShowOutliers', true, isscalarlogical);
            p.addParameter('ShowNotches', false, isscalarlogical);

            p.parse(data, pos, varargin{:});
            results = p.Results;
        end
    end
end
