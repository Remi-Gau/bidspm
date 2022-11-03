function status = test_notebooks()
  % run all the scripts derived from notebooks

  % (C) Copyright 2021 Remi Gau

  status = true;

  notebooks = dir(pwd);

  failed = [];

  for nb = 1:numel(notebooks)
    if regexp(notebooks(nb).name, '^BIDS_Matlab.*m$')
      fprintf(1, '\n');
      disp(notebooks(nb).name);
      fprintf(1, '\n');
      try
        run(notebooks(nb).name);
      catch
        status = false;
        failed(end + 1) = nb;
      end
    end
  end

  for f = 1:numel(failed)
    warning('\n\tRunning %s failed.\n', notebooks(failed(f)).name);
  end

end
