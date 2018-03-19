#!/bin/bash
# scripts for advanced task on feature transformations and speaker-dependent utterance adaptation
# objective: train model with LDA + MLTT transforms train nnet model

# train triphone model on MFCC+delta+deltadelta features with 2500 leaves and 15000 gaussians
# does it matter what alignments this is trained on?
steps/train_deltas.sh 2500 15000 data/train_words data/lang_wsj exp/mono_9000_ali exp/tri1

# make the graph
utils/mkgraph.sh data/lang_wsj_test_bg exp/tri1 exp/tri1/graph

# decode the model
steps/decode.sh --nj 4 exp/tri1/graph data/test_words exp/tri1/decode_test

# score the model
local/score_words.sh data/test_words exp/tri1/graph exp/tri1/decode_test

# get score_words
more exp/tri1/decode_test/scoring_kaldi/best_wer

# align this model
steps/align_si.sh --nj 4 data/train_words data/lang_wsj exp/tri1 exp/tri1_ali

# train LDA + MLTT features
steps/train_lda_mllt.sh --splice-opts "--left-context=3 --right-context=3" 2500 15000 data/train_words data/lang_wsj exp/tri1_ali exp/tri2

# align model AGAIN
steps/align_si.sh --nj 4 data/train_words data/lang_wsj exp/tri2 exp/tri2_ali

##
# nnets
dir=data/train_words
utils/subset_data_dir_tr_cv.sh $dir ${dir}_tr90 ${dir}_cv10

# train nnet
# small
steps/nnet/train.sh --hid-layers 2 --hid-dim 256 --splice 5 --learn-rate 0.008 --skip-cuda-check true data/train_words_tr90 data/train_words_cv10 data/lang_wsj exp/tri2_ali exp/tri2_ali exp/nnet
#big
steps/nnet/train.sh --hid-layers 4 --hid-dim 1056 --splice 5 --learn-rate 0.008 --skip-cuda-check true data/train_words_tr90 data/train_words_cv10 data/lang_wsj exp/tri2_ali exp/tri2_ali exp/nnet2

# make graphs
utils/mkgraph.sh --mono data/lang_wsj_test_bg exp/nnet exp/nnet/graph

# decode nn
steps/nnet/decode.sh --nj 4 exp/nnet/graph data/test_words exp/nnet/decode_test

# score the model
local/score_words.sh data/test_words exp/nnet/graph exp/nnet/decode_test

# get score_words
more exp/nnet/decode_test/scoring_kaldi/best_wer

##
# SAT
steps/train_sat.sh 2500 15000 data/train_words data/lang_wsj exp/tri2_ali exp/tri4_SAT

# make graphs
utils/mkgraph.sh --mono data/lang_wsj_test_bg exp/tri4_SAT exp/tri4_SAT/graph

# decode
steps/decode.sh --nj 4 exp/tri4_SAT/graph data/test_words exp/tri4_SAT/decode_test

steps/decode_fmllr.sh exp/tri4_SAT/graph data/test_words exp/tri4_SAT/decode_fmllr

# score the model
local/score_words.sh data/test_words exp/tri4_SAT/graph exp/tri4_SAT/decode_fmllr

# get score_words
more exp/tri4_SAT/decode_fmllr/scoring_kaldi/best_wer
