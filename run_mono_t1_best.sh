#!/bin/bash
# Task 1.1
# Decode, score, and display WER of monophone with optimal number of gaussian components

best_totgauss=9000
./steps/decode.sh --nj 4 ./exp/mono${best_totgauss}/graph ./data/test_words ./exp/mono${best_totgauss}/decode_test
./local/score_words.sh ./data/test_words ./exp/${best_totgauss}/graph ./exp/mono${best_totgauss}/decode_test
more ./exp/mono${best_totgauss}/decode_test/scoring_kaldi/best_wer
