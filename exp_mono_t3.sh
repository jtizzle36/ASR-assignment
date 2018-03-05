#!/bin/bash

# Removed all delta features
# Copied and edited train_mono's feats, decode.sh

my-local/train_mono_t3.sh --nj 4 data/train_words data/lang_wsj exp/rm_delta
my-local/decode_rmdelta.sh exp/rm_delta/graph data/test_words exp/rm_delta/decode_test
utils/mkgraph.sh --mono data/lang_wsj_test_bg exp/rm_delta exp/rm_delta/graph
local/score_words.sh data/test_words exp/rm_delta/graph exp/rm_delta/decode_test
more exp/rm_delta/decode_test/scoring_kaldi/best_wer

# with all delta/delta-delta features removed i.e., using raw MFCC features,
# WER=81.53
