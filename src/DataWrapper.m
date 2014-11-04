classdef DataWrapper < handle
  properties (Hidden)
    Coordinates
    ClustersCount
    Distances
    Weight = 0;
    Space
  end

  methods
    function [Coordinates, ClustersCount] = ReadData(DW, filename)
      data = csvread(filename);
      Coordinates = data(:, 1:end - 1);
      ClustersCount = size(unique(data(:, end)), 1);
    end 

    function Distances = Coordinates2Distances(DW)
      Count = size(DW.Coordinates, 1);
      Distances = zeros(Count);
      for i = 1 : Count
        for j = (i + 1) : Count
          Distances(j,i) = Distance(DW, DW.Coordinates(i, :), DW.Coordinates(j, :));
          Distances(i,j) = Distances(j,i);
        end
      end
    end

    function result = Distance(DW, vec1, vec2)
      result = sqrt(sum((vec1 - vec2) .^ 2));
    end

    function DW = DataWrapper(filename, weight)
      [DW.Coordinates, DW.ClustersCount] = ReadData(DW, filename);
      DW.Distances = Coordinates2Distances(DW);
      DW.Weight = weight;
    end


    function SetSpace(DW, InitialClustering)
      DW.Space = Space(DW.Distances, DW.ClustersCount, DW.Weight, InitialClustering); 
    end

    function ClusterizeSpace(DW)
      OldDispersion = 0;
      ToEnd = 1;
      Steps = 0;
      while(~ isequal(OldDispersion, DW.Space.Dispersion))
        OldDispersion = DW.Space.Dispersion;
        ClusterizeIteration(DW.Space);
        if ~ ToEnd
          DrawResult(DW);
          ToEnd = isequal(input('Sort to end? y/n [n]: ', 's'), 'y');
        end
        DW.Space.Dispersion = CalculateDispersion(DW.Space);
      end
    end

    function DrawResult(DW)
      % TODO: implement it.
      DW.Space.Clustering
    end
  end
end
