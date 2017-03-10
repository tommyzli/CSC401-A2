%
% evalAlign
%
%  This is simply the script (not the function) that you use to perform your evaluations in
%  Task 5.

% some of your definitions
trainDir     = '/u/cs401/A2_SMT/data/Hansard/Training/';
testDir      = '/u/cs401/A2_SMT/data/Hansard/Testing/';
fn_LME       = 'fn_LME.mat';
fn_LMF       = 'fn_LMF.mat';
lm_type      = '';
delta        = 0;
vocabSize    = 0;
numSentences = {1000, 10000, 15000, 30000};

% Train your language models. This is task 2 which makes use of task 1
LME = lm_train( trainDir, 'e', fn_LME );
LMF = lm_train( trainDir, 'f', fn_LMF );

testing_french_lines = textread(strcat(testDir, 'Task5.f'), '%s', 'delimiter', '\n');

% reference 1
testing_english_lines = textread(strcat(testDir, 'Task5.e'), '%s', 'delimiter', '\n');

% reference 2
testing_google_english_lines = textread(strcat(testDir, 'Task5.google.e'), '%s', 'delimiter', '\n');

% pipe output into a file
diary('eval_align_output.txt');
diary on;

% Train your alignment model of French, given English for each numSentences
for i=1:length(numSentences)
  
  disp('=========================================================')
  disp(sprintf('TRAINING ON %s SENTENCES', num2str(numSentences{i})));
  disp('=========================================================')
  disp('sentence index    n value     BLEU score');
  aligned_model_file_name = strcat('fn_AM_', num2str(numSentences{i}), '.mat');
  AMFE = align_ibm1( trainDir, numSentences{i}, 10, aligned_model_file_name );

  for sentence_index=1:length(testing_french_lines)
    fre = preprocess(testing_french_lines{sentence_index}, 'f');
    % Decode the test sentence 'fre'
    eng = decode2( fre, LME, AMFE, lm_type, delta, vocabSize );

    % Calculate BLEU score with n values of {1, 2, 3}
    candidate_array = strsplit(' ', eng);
    reference_1_array = strsplit(' ', testing_english_lines{sentence_index});
    reference_2_array = strsplit(' ', testing_google_english_lines{sentence_index});

    % first, compute berevity, since it is independant of n value
    if abs(length(reference_1_array) - length(candidate_array)) > abs(length(reference_2_array) - length(candidate_array))
      % reference 2 is closer in length
      closer_reference_length = length(reference_2_array);
    else
      % reference 1 is closer in length
      closer_reference_length = length(reference_1_array);
    end

    berevity = closer_reference_length / length(candidate_array);
    berevity_penalty = 1;
    if berevity >= 1
      berevity_penalty = exp(1 - berevity);
    end

    for n=1:3
      p_values = {};
      % second, compute N-gram precisions for N = 1:n
      for ng=1:n
        total_ngrams = 0;
        matching_ngrams = 0;
        
        for j=1:length(candidate_array)-ng+1
          ngram = {};
          ngram_i = 1;

          % iterate through candidate_array by ngrams of length ng
          for k=j:j+ng-1
            ngram{ngram_i} = candidate_array{k};
            ngram_i = ngram_i + 1;
          end

          % check if one of the references contains the ngram
          matched_reference_1 = match_ngram(ngram, reference_1_array);
          if matched_reference_1
            matching_ngrams = matching_ngrams + 1;
          else
            % if not in reference 1, try reference 2
            matched_reference_2 = match_ngram(ngram, reference_2_array);
            if matched_reference_2
              matching_ngrams = matching_ngrams + 1;
            end
          end

          total_ngrams = total_ngrams + 1;
        end

        pval = matching_ngrams / total_ngrams;
        p_values{ng} = pval;
      end

      pval_product = 1;
      for p_index=1:length(p_values)
        pval_product = pval_product * p_values{p_index};
      end

      BLEU_score = berevity_penalty * (pval_product ^ (1 / n));
      disp(sprintf('%s                %s          %s',...
        num2str(sentence_index),...
        num2str(n),...
        num2str(BLEU_score)));

      % force diary to write to file
      diary off;
      diary on;
    end
  end
end

diary off;

[status, result] = unix('')

