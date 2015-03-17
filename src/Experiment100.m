function errors_size = Experiment100(Filename)
  if nargin < 1
    Filename = '../data/iris_01.data.csv';
  end
  % Weights = [900:1000] ./ 1000;
  Weights = [0:50] ./ 50;
  errors_size = [];
  for Weight = Weights
    errors = ExperimentIteration(Weight, Filename);
    errors_size = [errors_size size(errors, 2)];
  end
  save('../results/experiment100_out.mat', 'Weights', 'errors_size')
  plot(Weights, errors_size);
end

function errors = ExperimentIteration(Weight, Filename)
  if nargin < 1
    Weight = 0;
  end
  if nargin < 2
    Filename = '../data/iris_01.data.csv';
  end

  dw = DataWrapper(Filename, Weight);
  ic = [ones(1, 50), ones(1, 50) * 2]; % initial clustering
  SetSpace(dw, ic);
  ClusterizeSpace(dw);
  errors = find(dw.Space.Clustering ~= RightClustering());
end

function result = RightClustering(order)
  if nargin < 1
    order = [1 2];
  end
  result = [];
  for k = order
    result = [result, ones(1, 50) * k];
  end
end

function result = Center(Coordinates, ClusterNumbers)
  result = mean(Coordinates(ClusterNumbers, ClusterNumbers));
end
