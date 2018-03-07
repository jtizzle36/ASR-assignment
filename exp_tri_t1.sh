#!/bin/bash

# Investigate optimal number of clusters & number of Gaussian
# for a tied-state triphone model

# Train triphone system using MFCC and delta & delta-delta features
# Default values
num_leaves=2500
num_gauss=15000
data_dir=data/train_words
lang_dir=data/lang_wsj

# Align model from task 1, then use aligned monophone model
orig_model=exp/mono1000
algn_dir=${orig_model}_ali
steps/align_si.sh --nj 4 ${data_dir} ${lang_dir} ${orig_model} ${algn_dir}

for num_leaves in {2000..3000..100}
do
  for num_gauss in {12500..17500..500}
  do
    exp_name=tri_t1_${num_leaves}_${num_gauss}
    exp_dir=exp/${exp_name}
    steps/train_deltas.sh ${num_leaves} ${num_gauss} ${data_dir} ${lang_dir} ${algn_dir} ${exp_dir}
    utils/mkgraph.sh data/lang_wsj_test_bg ${exp_dir} ${exp_dir}/graph
    steps/decode.sh --nj 4 ${exp_dir}/graph data/test_words ${exp_dir}/decode_test
    local/score_words.sh data/test_words ${exp_dir}/graph ${exp_dir}/decode_test
    more ${exp_dir}/decode_test/scoring_kaldi/best_wer >> my-local/exp_tri_results
  done
done
