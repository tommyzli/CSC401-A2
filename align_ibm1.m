function AM = align_ibm1(trainDir, numSentences, maxIter, fn_AM)
%
%  align_ibm1
%
%  This function implements the training of the IBM-1 word alignment algorithm.
%  We assume that we are implementing P(foreign|english)
%
%  INPUTS:
%
%       dataDir      : (directory name) The top-level directory containing
%                                       data from which to train or decode
%                                       e.g., '/u/cs401/A2_SMT/data/Toy/'
%       numSentences : (integer) The maximum number of training sentences to
%                                consider.
%       maxIter      : (integer) The maximum number of iterations of the EM
%                                algorithm.
%       fn_AM        : (filename) the location to save the alignment model,
%                                 once trained.
%
%  OUTPUT:
%       AM           : (variable) a specialized alignment model structure
%
%
%  The file fn_AM must contain the data structure called 'AM', which is a
%  structure of structures where AM.(english_word).(foreign_word) is the
%  computed expectation that foreign_word is produced by english_word
%
%       e.g., LM.house.maison = 0.5       % TODO
%
% Template (c) 2011 Jackie C.K. Cheung and Frank Rudzicz

  global CSC401_A2_DEFNS

  AM = struct();

  % Read in the training data
  [eng, fre] = read_hansard(trainDir, numSentences);

  % Initialize AM uniformly
  AM = initialize(eng, fre);

  % Iterate between E and M steps
  for iter=1:maxIter,
    AM = em_step(AM, eng, fre);
  end

  % Save the alignment model
  %save( fn_AM, 'AM', '-mat');

  end





% --------------------------------------------------------------------------------
%
%  Support functions
%
% --------------------------------------------------------------------------------

function [eng, fre] = read_hansard(mydir, numSentences)
%
% Read 'numSentences' parallel sentences from texts in the 'dir' directory.
%
% Important: Be sure to preprocess those texts!
%
% Remember that the i^th line in fubar.e corresponds to the i^th line in fubar.f
% You can decide what form variables 'eng' and 'fre' take, although it may be easiest
% if both 'eng' and 'fre' are cell-arrays of cell-arrays, where the i^th element of
% 'eng', for example, is a cell-array of words that you can produce with
%
%         eng{i} = strsplit(' ', preprocess(english_sentence, 'e'));
%
  eng = {};
  fre = {};

  % TODO: your code goes here.
  eng_dir = dir([ mydir, filesep, '*', 'e' ]);
  fre_dir = dir([ mydir, filesep, '*', 'f' ]);
  read_sentences = 0;
  for file_index=1:length(eng_dir)
    disp(eng_dir(file_index).name);
    eng_lines = textread([mydir, filesep, eng_dir(file_index).name], '%s', 'delimiter', '\n');
    fre_lines = textread([mydir, filesep, fre_dir(file_index).name], '%s', 'delimiter', '\n');

    for line_index=1:length(eng_lines)
      eng_sentence = char(eng_lines{line_index});
      fre_sentence = char(fre_lines{line_index});

      eng{line_index} = strsplit(' ', preprocess(eng_sentence, 'e'));
      fre{line_index} = strsplit(' ', preprocess(fre_sentence, 'f'));

      read_sentences = read_sentences + 1;
      if read_sentences >= numSentences
        return
      end

    end
  end
end


function AM = initialize(eng, fre)
%
% Initialize alignment model uniformly.
% Only set non-zero probabilities where word pairs appear in corresponding sentences.
%
    AM = {}; % AM.(english_word).(foreign_word)

    % TODO: your code goes here
    for i=1:length(eng)
      for eng_index=1:length(eng{i}) 
        if ~isfield(AM, eng{i}{eng_index})
          AM.(eng{i}{eng_index}) = {};
        end

        for fre_index=1:length(fre{i})
          % first go through and initialize all fields with non zero probabilities as 1
          AM.(eng{i}{eng_index}).(fre{i}{fre_index}) = 1;
        end
      end
    end

    % now actually calculate the probabilities
    eng_words = fieldnames(AM);
    for i=1:length(eng_words)
      fre_words = fieldnames(AM.(eng_words{i}));

      for j=1:length(fre_words)
        AM.(eng_words{i}).(fre_words{j}) = 1 / length(fre_words);
      end
    end
    

    AM.SENTEND.SENTEND = 1;
    AM.SENTSTART.SENTSTART = 1;

end

function t = em_step(t, eng, fre)
%
% One step in the EM algorithm.
%

  % TODO: your code goes here
  tcount = struct();
  total = struct();

  eng_words = fieldnames(t);
  for i=1:length(eng_words)
    % initialize total(e) as 0 for all e
    total.(eng_words{i}) = 0;

    fre_words = fieldnames(t.(eng_words{i}));
    for j=1:length(fre_words)
      % initialize tcount(f, e) as 0 for all f, e
      tcount.(eng_words{i}).(fre_words{j}) = 0;
    end
  end

  for i=1:length(eng)
    % counting occurrences of word at fre{i}, found at
    % https://www.mathworks.com/matlabcentral/answers/115838-count-occurrences-of-string-in-a-single-cell-array-how-many-times-a-string-appear#answer_124094
    [unique_f, ~, J] = unique(fre{i});
    count_f = histc(J, 1:numel(unique_f));
    [unique_e, ~, J] = unique(eng{i});
    count_e = histc(J, 1:numel(unique_e));

    for f=1:length(unique_f)
      denom_c = 0;

      for e=1:length(unique_e)
        denom_c = denom_c + (t.(unique_e{e}).(unique_f{f}) * count_f(f));
      end

      for e=1:length(unique_e)
        tcount_delta = (t.(unique_e{e}).(unique_f{f}) * count_f(f) * count_e(e)) / denom_c;
        tcount.(unique_e{e}).(unique_f{f}) = tcount.(unique_e{e}).(unique_f{f}) + tcount_delta;

        total_delta = (t.(unique_e{e}).(unique_f{f}) * count_f(f) * count_e(e)) / denom_c;
        total.(unique_e{e}) = total.(unique_e{e}) + total_delta;
      end
    end
  end

  for i=1:length(eng_words)
    fre_words = fieldnames(t.(eng_words{i})) ;
    for j=1:length(fre_words)
      t.(eng_words{i}).(fre_words{j}) = tcount.(eng_words{i}).(fre_words{j}) / total.(eng_words{i});
    end
  end
end

