#!/bin/bash
# scripts for advanced task on feature transformations and speaker-dependent utterance adaptation
# objective: train model with LDA + MLTT transforms train nnet model

# train triphone model on MFCC+delta+deltadelta features with 2500 leaves and 15000 gaussians
# does it matter what alignments this is trained on?
~/asworkdir/steps/train_deltas.sh 2500 15000 ~/asworkdir/data/train_words ~/asworkdir/data/lang_wsj ~/asworkdir/exp/mono9000_ali ~/asworkdir/exp/tri1

# make the graph
~/asworkdir/utils/mkgraph.sh ~/asworkdir/data/lang_wsj_test_bg ~/asworkdir/exp/tri1 ~/asworkdir/exp/tri1/graph

# decode the model
~/asworkdir/steps/decode.sh --nj 4 ~/asworkdir/exp/tri1/graph ~/asworkdir/data/test_words ~/asworkdir/exp/tri1/decode_test

# score the model
~/asworkdir/local/score_words.sh ~/asworkdir/data/test_words ~/asworkdir/exp/tri1/graph ~/asworkdir/exp/tri1/decode_test

# get score_words
more ~/asworkdir/exp/tri1/decode_test/scoring_kaldi/best_wer

# align this model
~/asworkdir/steps/align_si.sh --nj 4 ~/asworkdir/data/train_words data/lang_wsj ~/asworkdir/exp/tri1 ~/asworkdir/exp/tri1_ali

# train LDA + MLTT features
~/asworkdir/steps/train_lda_mllt.sh --splice-opts "--left-context=3 --right-context=3" 2500 15000 ~/asworkdir/data/train_words data/lang_wsj exp/tri1_ali exp/tri2

# align model AGAIN
~/asworkdir/steps/align_si.sh --nj 4 ~/asworkdir/data/train_words ~/asworkdir/data/lang_wsj ~/asworkdir/exp/tri2 ~/asworkdir/exp/tri2_ali

##
# nnets
dir=~/asworkdir/data/train_words
~/asworkdir/utils/subset_data_dir_tr_cv.sh $dir ${dir}_tr90 ${dir}_cv10

# train nnet
# small
~/asworkdir/steps/nnet/train.sh --hid-layers 2 --hid-dim 256 --splice 5 --learn-rate 0.008 --skip-cuda-check true ~/asworkdir/data/train_words_tr90 ~/asworkdir/data/train_words_cv10 ~/asworkdir/data/lang_wsj ~/asworkdir/exp/tri2_ali ~/asworkdir/exp/tri2_ali ~/asworkdir/exp/nnet
#big - not trained yet
~/asworkdir/steps/nnet/train.sh --hid-layers 4 --hid-dim 1056 --splice 5 --learn-rate 0.008 --skip-cuda-check true ~/asworkdir/data/train_words_tr90 ~/asworkdir/data/train_words_cv10 ~/asworkdir/data/lang_wsj ~/asworkdir/exp/tri2_ali ~/asworkdir/exp/tri2_ali ~/asworkdir/exp/nnet2

# make graphs
~/asworkdir/utils/mkgraph.sh --mono ~/asworkdir/data/lang_wsj_test_bg ~/asworkdir/exp/nnet ~/asworkdir/exp/nnet/graph

# decode nn
~/asworkdir/steps/nnet/decode.sh --nj 4 ~/asworkdir/exp/nnet/graph ~/asworkdir/data/test_words ~/asworkdir/exp/nnet/decode_test

# score the model
~/asworkdir/local/score_words.sh ~/asworkdir/data/test_words ~/asworkdir/exp/nnet/graph ~/asworkdir/exp/nnet/decode_test

# get score_words
more ~/asworkdir/exp/nnet/decode_test/scoring_kaldi/best_wer

##
# SAT
~/asworkdir/steps/train_sat.sh 2500 15000 ~/asworkdir/data/train_words ~/asworkdir/data/lang_wsj ~/asworkdir/exp/tri2_ali exp/tri4_SAT

# make graphs
~/asworkdir/utils/mkgraph.sh --mono ~/asworkdir/data/lang_wsj_test_bg ~/asworkdir/exp/tri4_SAT ~/asworkdir/exp/tri4_SAT/graph

# decode
~/asworkdir/steps/decode.sh --nj 4 ~/asworkdir/exp/tri4_SAT/graph ~/asworkdir/data/test_words ~/asworkdir/exp/tri4_SAT/decode_test

~/asworkdir/steps/decode_fmllr.sh ~/asworkdir/exp/tri4_SAT/graph ~/asworkdir/data/test_words ~/asworkdir/exp/tri4_SAT/decode_fmllr

# score the model
~/asworkdir/local/score_words.sh ~/asworkdir/data/test_words ~/asworkdir/exp/tri4_SAT/graph ~/asworkdir/exp/tri4_SAT/decode_fmllr

# get score_words
more ~/asworkdir/exp/tri4_SAT/decode_fmllr/scoring_kaldi/best_wer

##
# gender adaptation using MAP
~/asworkdir/steps/train_map.sh ~/asworkdir/data/train_words_female ~/asworkdir/data/lang_wsj ~/asworkdir/exp/tri2_ali exp/tri3_MAPfemale
