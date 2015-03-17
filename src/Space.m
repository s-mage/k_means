classdef Space < handle
  properties (Hidden)
    Subsets     % the same as clusters.  [Array of Subset] (1 x N)
    Clustering  % Array of numbers, which line belongs to which cluster. (1 x n)
    ClustersCount
    ObjectsCount
    Distances   % Matrix of distances.   (n x n)
    Proximities % Matrix of proximities. (N x N)
    Dispersion  % In-cluster dispersies criterion J(K). [Number]
    Proximity   % External Dispersions criterion I(K).  [Number]
    Weight      % Weight of Proximity.   [Number]
  end

  methods
    % Class initializer.
    % @param Distances [Matrix] matrix of distances;
    % @param ClustersCount [Integer] count of clusters;
    % @param InitialClustering [Array] initial clustering. Default -- random.
    %
    function S = Space(Distances, ClustersCount, Weight, InitialClustering)
      S.Distances = Distances;
      S.Proximities = Distances2Proximities(S, Distances);
      S.ClustersCount = ClustersCount;
      S.ObjectsCount = size(Distances, 1);
      S.Subsets = [];
      if nargin < 3 % if Weight is absent
        Weight = 0;
      end
      S.Weight = Weight;
      if nargin < 4 % if InitialClustering is absent
        InitialClustering = randi([1 ClustersCount], 1, S.ObjectsCount);
      end
      SetSubsets(S, InitialClustering);
    end

    function Result = SetSubsets(S, Clustering)
      Result = [];
      for i = 1:max(Clustering)
        Numbers = find(Clustering == i);
        Result = [Result, Subset(S.Distances, S.Proximities, Numbers)];
      end
      S.Clustering = Clustering;
      S.Subsets = Result;
    end

    function p = Distances2Proximities(S, Distances)
      N = size(Distances, 1);
      p = zeros(N, N);
      eta = sum(Distances(:) .^ 2) / (2 * N ^ 2);
      Dist2Origin = @(x) (sum(Distances(:, x) .^ 2) / N) - eta;
      for i = 1:N
        for j = 1:N
          p(i, j) = (Dist2Origin(i) + Dist2Origin(j) - Distances(i, j) ^ 2) / 2;
        end
      end
    end

    % Clusterization iteration.
    % It seems to be sane to have only iteration here,
    % because in data wrapper we could to some debug things between iterations.
    %
    function ClusterizeIteration(S)
      for Number = 1:S.ObjectsCount
        S.Dispersion = CalculateDispersion(S);
        S.Proximity = CalculateProximity(S);
        OldSubset = SubsetOf(S, Number);
        OtherSubsets = S.Subsets(S.Subsets ~= OldSubset);
        for NewSubset = OtherSubsets
          Move(S, OldSubset, NewSubset, Number);
          NewDispersion = CalculateDispersion(S);
          NewProximity = CalculateProximity(S);
          DispersionDiff = NewDispersion - S.Dispersion;
          ProximityDiff = NewProximity - S.Proximity;
          Diff = (- (1 - S.Weight) * DispersionDiff + S.Weight * ProximityDiff);
          % Diff = (- DispersionDiff + S.Weight * ProximityDiff);
          Result = Diff > 0;
          if ~ Result
            Move(S, NewSubset, OldSubset, Number); % Move back
          else
            S.Dispersion = NewDispersion;
            S.Proximity = NewProximity;
          end
        end
      end
    end

    function Result = SubsetOf(S, Number)
      Result = S.Subsets(S.Clustering(Number));
    end

    function Move(S, OldSubset, NewSubset, Number)
      S.Clustering(Number) = find(S.Subsets == NewSubset);
      Move(OldSubset, NewSubset, Number);
    end

    % Average weighted dispersion of clusters.
    % J(K) = 1 / N * (sum_{k = 1}^{K} N_k * \eta_k^2)
    % 
    function result = CalculateDispersion(S)
      Ns = zeros(1, S.ClustersCount);
      etas = zeros(1, S.ClustersCount);
      for i = 1:S.ClustersCount
        Ns(i) = S.Subsets(i).Size;
        etas(i) = Eta(S.Subsets(i));
      end
      result = sum(Ns .* etas) / S.ObjectsCount;
    end

    % Compactness of set of clusters.
    % \delta(K) = 1 / K^2 * sum(sum(proximities))
    %
    function result = CalculateProximity(S)
      result = 0;
      for first = S.Subsets
        for second = S.Subsets
          result = result + Proximity(first, second);
        end
      end
      result = result / S.ClustersCount ^ 2;
    end
  end % methods
end
