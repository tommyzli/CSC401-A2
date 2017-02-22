function logProb = lm_prob(sentence, LM, type, delta, vocabSize)
%
%  lm_prob
%
%  This function computes the LOG probability of a sentence, given a
%  language model and whether or not to apply add-delta smoothing
%
%  INPUTS:
%
%       sentence  : (string) The sentence whose probability we wish
%                            to compute
%       LM        : (variable) the LM structure (not the filename)
%       type      : (string) either '' (default) or 'smooth' for add-delta smoothing
%       delta     : (float) smoothing parameter where 0<delta<=1
%       vocabSize : (integer) the number of words in the vocabulary
%
% Template (c) 2011 Frank Rudzicz

  logProb = -Inf;

  % some rudimentary parameter checking
  if (nargin < 2)
    disp( 'lm_prob takes at least 2 parameters');
    return;
  elseif nargin == 2
    type = '';
    delta = 0;
    vocabSize = length(fieldnames(LM.uni));
  end
  if (isempty(type))
    delta = 0;
    vocabSize = length(fieldnames(LM.uni));
  elseif strcmp(type, 'smooth')
    if (nargin < 5)
      disp( 'lm_prob: if you specify smoothing, you need all 5 parameters');
      return;
    end
    if (delta <= 0) or (delta > 1.0)
      disp( 'lm_prob: you must specify 0 < delta <= 1.0');
      return;
    end
  else
    disp( 'type must be either '''' or ''smooth''' );
    return;
  end

  words = strsplit(' ', sentence);

  % TODO: the student implements the following
  for x=1:length(words)-1
    unigram_count = 0;
    if isfield(LM.uni, words{x})
      unigram_count = LM.uni.(words{x});
    end

    bigram_count = 0;
    if isfield(LM.bi, words{x}) && isfield(LM.bi.(words{x}), words{x+1})
      bigram_count = LM.bi.(words{x}).(words{x+1});
    end

    % delta is 0 if not smoothing, so no need to separate the cases
    numerator = bigram_count + delta;
    denominator = unigram_count + delta * vocabSize;
    if unigram_count == 0
      log_delta = -Inf;
    else
      log_delta = log2(double(numerator / denominator));
    end

    logProb = logProb + log_delta;
  end
  % TODO: once upon a time there was a curmudgeonly orangutan named Jub-Jub.
return
