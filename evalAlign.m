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
if exist(fn_LME, 'file') == 2
  load(fn_LME, '-mat');
else
  LME = lm_train( trainDir, 'e', fn_LME );
end

if exist(fn_LMF, 'file') == 2
  load(fn_LMF, '-mat');
else
  LMF = lm_train( trainDir, 'f', fn_LMF );
end

testing_french_lines = textread(strcat(testDir, 'Task5.f'), '%s', 'delimiter', '\n');
testing_english_lines = textread(strcat(testDir, 'Task5.e'), '%s', 'delimiter', '\n');
testing_google_english_lines = textread(strcat(testDir, 'Task5.google.e'), '%s', 'delimiter', '\n');

% Train your alignment model of French, given English for each numSentences
for i=1:length(numSentences)
  disp('=========================================================')
  disp(strcat('TRAINING ON  ', num2str(numSentences{i}), ' SENTENCES'))
  disp('=========================================================')
  aligned_model_file_name = strcat('fn_AM_', num2str(numSentences{i}), '.mat');
  AMFE = align_ibm1( trainDir, numSentences{i}, 10, aligned_model_file_name );

  for sentence_index=1:length(testing_french_lines)
    fre = preprocess(testing_french_lines{sentence_index}, 'f');
    % Decode the test sentence 'fre'
    eng = decode2( fre, LME, AMFE, lm_type, delta, vocabSize );
    disp('original line:')
    testing_french_lines{sentence_index}
    disp('my translation:')
    eng
    disp('googles translation:')
    testing_google_english_lines{sentence_index}
    disp('actual translation:')
    testing_english_lines{sentence_index}

    % TODO: perform some analysis
    % add BlueMix code here
  end
end

[status, result] = unix('')
