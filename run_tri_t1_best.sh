#!/bin/bash

# Assuming trained triphone model with optimal number of clusters and Gaussians
num_leaves=3000
num_gauss=19000
data_dir=./data/train_words
lang_dir=./data/lang_wsj
exp_dir=./exp/tri_t1_${num_leaves}_${num_gauss}

./utils/mkgraph.sh data/lang_wsj_test_bg ${exp_dir} ${exp_dir}/graph
./steps/decode.sh --nj 4 ${exp_dir}/graph data/test_words ${exp_dir}/decode_test
./local/score_words.sh data/test_words ${exp_dir}/graph ${exp_dir}/decode_test
more ${exp_dir}/decode_test/scoring_kaldi/best_wer
