#!/bin/bash

# Since we are training a GMM-HMM system, we chose PLP features.

# Created 'dummy' plp.conf (1-line: --sample-freq=16000)
# Coped training/testing data to separate directories for plp (train/test_words_plp)

# Make PLP features
for dir in train_words_plp test_words_plp
do
  ./steps/make_plp.sh ./data/$dir ./exp/make_plp/$dir plp
done

# Train monophone model on PLP features
./steps/train_mono.sh --nj 4 ./data/train_words_plp ./data/lang_wsj ./exp/plp

# Decode
./utils/mkgraph.sh --mono ./data/lang_wsj_test_bg ./exp/plp ./exp/plp/graph
./steps/decode.sh --nj 4 ./exp/plp/graph ./data/test_words_plp ./exp/plp/decode_test
./local/score_words.sh ./data/test_words_plp ./exp/plp/graph ./exp/plp/decode_test
more ./exp/plp/decode_test/scoring_kaldi/best_wer

# this produced a WER of 86.65.
