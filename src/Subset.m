% Subset is submatrix of global test data.
% We store only numbers and size in these objects.
%
classdef Subset < handle
  properties (Hidden)
    Numbers % numbers is matrix that belongs to subset.
    Size    % size of subset.
    Set     % global matrix of distances.
  end

  methods
    function S = Subset(Set, Numbers)
      S.Set = Set;
      S.Numbers = Numbers;
      S.Size = size(Numbers, 2);
    end

    function Result = Submatrix(S)
      Result = S.Set(S.Numbers, S.Numbers);
    end

    function [New, OtherNew] = Move(S, Other, Number)
      S.Numbers = S.Numbers(S.Numbers ~= Number);
      S.Size = S.Size - 1;
      Other.Numbers = [Other.Numbers, Number];
      Other.Size = Other.Size + 1;
    end

    function Result = Proximity(S, Other)
      InterClusterSubset = S.Set(S.Numbers, Other.Numbers);
      Result = sum(InterClusterSubset(:)) / (S.Size * Other.Size);
    end

    % Dispersy of cluster.
    % @return [Float] dispersy is a number.
    %
    function Result = Eta(S)
      x = Submatrix(S);
      Result = sum(x(:) .^ 2) / (2 * S.Size);
    end
  end
end
