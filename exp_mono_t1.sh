#!/bin/bash

# Task 1.1
# Explore optimal number of Gaussian components

for totgauss in {100..2500..100}
do
  ./steps/train_mono.sh --totgauss $totgauss --nj 4 ./data/train_words ./data/lang_wsj ./exp/mono${totgauss}
  ./utils/mkgraph.sh --mono ./data/lang_wsj_test_bg ./exp/mono${totgauss} ./exp/mono${totgauss}/graph
  ./steps/decode.sh --nj 4 ./exp/mono${totgauss}/graph ./data/test_words ./exp/mono${totgauss}/decode_test
  ./local/score_words.sh ./data/test_words ./exp/mono${totgauss}/graph ./exp/mono${totgauss}/decode_test
  more ./exp/mono${totgauss}/decode_test/scoring_kaldi/best_wer >> ./my-local/exp_mono_results
done

# We re-ran this script with different values, and decided optimal was totgauss 9000.
# WER: 54.89%
