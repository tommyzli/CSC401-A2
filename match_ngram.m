function found_match = match_ngram(candidate_ngram, reference)
  % Helper function to determine if the cell array reference contains candidate_ngram
  % Used in calculating BLEU score of translations
  num_matches = 1;
  for i=1:length(reference)
    if strcmp(reference{i}, candidate_ngram{num_matches})
      if num_matches >= length(candidate_ngram)
        found_match = true;
        return
      end
      num_matches = num_matches + 1;
    else
      num_matches = 1;
      found_match = false;
    end
  end
  found_match = false;
end

