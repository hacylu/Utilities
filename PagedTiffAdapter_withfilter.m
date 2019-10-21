classdef PagedTiffAdapter_withfilter < ImageAdapter % not working yet
    properties
        Filename
        Info
        Page
    end
    methods
        function obj = PagedTiffAdapter(filename, page)
            obj.Filename = filename;
            obj.Info = imfinfo(filename);
            obj.Page = page;
            obj.ImageSize = [obj.Info(page).Height obj.Info(page).Width];
        end
        function result = readRegion(obj, start, count)            
            curim = imread(obj.Filename,'Index',obj.Page,...
                'Info',obj.Info,'PixelRegion', ...
                {[start(1), start(1) + count(1) - 1], ...
                [start(2), start(2) + count(2) - 1]});
            bw_white=curim(:,:,1)>220;
            bw_black=curim(:,:,1)<20;
            bw_bad=bw_white|bw_black;
            sum_bad_count=sum(bw_bad);
            if sum_bad_count<size(curim,1)*size(curim,2)*0.3
                result=curim;
            else
                result=[];
            end
        end
        function result = close(obj) %#ok
        end
    end
end