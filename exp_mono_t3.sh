#!/bin/bash

# Task 1.3: Investigate effects of delta and delta-delta features

# Original optimal model trained in the previous task is the 'baseline'
# We now train models with delta-order=1 (MFCC+delta) and delta-order=2 (MFCC+delta+deltadelta)

# Preparation:
# Create separate versions of train_mono.sh and decode.sh
# i.e., train_mono_delta0, train_mono_delta1, decode_delta0, decode_delta1

for delta in 0 1; do
  train_script=./my-local/train_mono_delta${delta}.sh
  decode_script=./my-local/decode_delta${delta}.sh
  exp_dir=./exp/exp_mono_delta${delta}
  ${train_script} --nj 4 data/train_words data/lang_wsj ${exp_dir}
  ./utils/mkgraph.sh --mono data/lang_wsj_test_bg ${exp_dir} ${exp_dir}/graph
  ${decode_script} ${exp_dir}/graph data/test_words ${exp_dir}/decode_test
  ./local/score_words.sh data/test_words ${exp_dir}/graph ${exp_dir}/decode_test
  more ${exp_dir}/decode_test/scoring_kaldi/best_wer
done
