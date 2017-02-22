function outSentence = preprocess( inSentence, language )
%
%  preprocess
%
%  This function preprocesses the input text according to language-specific rules.
%  Specifically, we separate contractions according to the source language, convert
%  all tokens to lower-case, and separate end-of-sentence punctuation
%
%  INPUTS:
%       inSentence     : (string) the original sentence to be processed
%                                 (e.g., a line from the Hansard)
%       language       : (string) either 'e' (English) or 'f' (French)
%                                 according to the language of inSentence
%
%  OUTPUT:
%       outSentence    : (string) the modified sentence
%
%  Template (c) 2011 Frank Rudzicz

  global CSC401_A2_DEFNS

  % first, convert the input sentence to lower-case and add sentence marks
  inSentence = [CSC401_A2_DEFNS.SENTSTART ' ' lower( inSentence ) ' ' CSC401_A2_DEFNS.SENTEND];

  % trim whitespaces down
  inSentence = regexprep( inSentence, '\s+', ' ' );

  % initialize outSentence
  outSentence = inSentence;

  % perform language-agnostic changes
  % separate mathematical operators and some punctuation
  outSentence = regexprep( outSentence, '(.*)([.*+-<>=,:;"])(.*)', '$1 $2 $3' );
  % separate dashes in between parens
  outSentence = regexprep( outSentence, '(.*\(.*)(-)(.*\).*)', '$1 $2 $3' );

  switch language
   case 'e'
    % Separate punctuation (other than single quotation marks)
    outSentence = regexprep( outSentence, '([^\w\s''+])', ' $1' );

    % Separate clitics
    outSentence = regexprep( outSentence, '((^|\s)\w*)(''\w*)', '$1 $2' );

   case 'f'
    outSentence = regexprep( outSentence, '(.*[cltmj]'')(.*)', '$1 $2');
    outSentence = regexprep( outSentence, '(.*qu'')(.*)', '$1 $2');
    outSentence = regexprep( outSentence, '(.*lorsqu'')(on|il)(.*)', '$1 $2$3');
    outSentence = regexprep( outSentence, '(.*puisqu'')(on|il)(.*)', '$1 $2$3');

  end

  outSentence = regexprep( outSentence, '\s+', ' ');

  % change unpleasant characters to codes that can be keys in dictionaries
  outSentence = convertSymbols( outSentence );
