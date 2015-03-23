function Experiment(Filename, Weights)
  if nargin < 1
    Filename = '../data/iris.data.csv';
  end
  if nargin < 2
    Weights = [0:50] ./ 50;
  end
  result_50_50_50 = ExperimentTemplate(Filename, [ones(1, 50), ones(1, 50) * 2, ones(1, 50) * 3], Weights); 
  result_50_70_30 = ExperimentTemplate(Filename, [ones(1, 50), ones(1, 70) * 2, ones(1, 30) * 3], Weights); 
  result_50_30_70 = ExperimentTemplate(Filename, [ones(1, 50), ones(1, 30) * 2, ones(1, 70) * 3], Weights);
  figure
  plot(Weights, result_50_50_50, ...
       Weights, result_50_70_30, '--', ...
       Weights, result_50_30_70, ':')
  save('../results/experiment_out.mat')
end

% Experiments with all 3 clusters of irices.
%
function ErrorsSize = ExperimentTemplate(Filename, InitialClustering, Weights, ClusteringOrder)
  if nargin < 1
    Filename = '../data/iris.data.csv';
  end
  if nargin < 2
    InitialClustering = [ones(1, 50), ones(1, 50) * 2, ones(1, 50) * 3];
  end
  if nargin < 3
    Weights = [0:50] ./ 50;
  end
  if nargin < 4
    ClusteringOrder = [1 2 3];
  end
  ErrorsSize = [];
  for Weight = Weights
    errors = ExperimentIteration(Weight, Filename, InitialClustering, ClusteringOrder);
    ErrorsSize = [ErrorsSize size(errors, 2)];
  end
end

function errors = ExperimentIteration(Weight, Filename, ic, ClusteringOrder)
  if nargin < 1
    Weight = 0;
  end
  if nargin < 2
    Filename = '../data/iris.data.csv';
  end
  if nargin < 3
    ic = [ones(1, 50), ones(1, 50) * 2, ones(1, 50) * 3]; % initial clustering
  end
  if nargin < 4
    ClusteringOrder = [1 2 3];
  end

  dw = DataWrapper(Filename, Weight);
  SetSpace(dw, ic);
  ClusterizeSpace(dw);
  errors = find(dw.Space.Clustering ~= RightClustering(ClusteringOrder));
end

function result = RightClustering(order)
  if nargin < 1
    order = [1 2 3];
  end
  result = [];
  for k = order
    result = [result, ones(1, 50) * k];
  end
end
