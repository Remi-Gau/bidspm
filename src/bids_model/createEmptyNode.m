function node = createEmptyNode(level)
  %
  % (C) Copyright 2020 CPP_SPM developers

  node =  struct( ...
                 'Level', [upper(level(1)) level(2:end)], ...
                 'Name', [level '_level'], ...
                 'Transformations', {createEmptyTransformation()}, ...
                 'Model', createEmptyModel(), ...
                 'Contrasts', struct('Name', '', ...
                                     'ConditionList', {{''}}, ...
                                     'Weights', {{''}}, ...
                                     'Test', ''), ...
                 'DummyContrasts',  struct('Test', 't', ...
                                           'Contrasts', {{''}}));

end