#!/bin/bash

# Since we are training a GMM-HMM system, we chose PLP features.

# Created 'dummy' plp.conf (./conf/plp.conf, 1-line: --sample-freq=16000)
# Coped training/testing data to separate directories for plp (train/test_words_plp)

# Make PLP features
#for dir in train_words_plp test_words_plp
#do
#  ./steps/make_plp.sh ./data/$dir ./exp/make_plp/$dir plp
#done

exp_dir=./exp/plp

# Compute CMVN stats and check feature dimensions
# for dir in train_words_plp test_words_plp
# do
#  ./steps/compute_cmvn_stats.sh data/${dir}
#  feat-to-dim scp:data/${dir}/feats.scp -
# done

# Train monophone model on PLP features
# ./steps/train_mono.sh --nj 4 --totgauss 9000 ./data/train_words_plp ./data/lang_wsj ${exp_dir}

# Decode
./utils/mkgraph.sh --mono ./data/lang_wsj_test_bg ${exp_dir} ${exp_dir}/graph
./steps/decode.sh --nj 4 ./exp/plp/graph ./data/test_words_plp ${exp_dir}/decode_test
./local/score_words.sh ./data/test_words_plp ${exp_dir}/graph ${exp_dir}/decode_test
more ${exp_dir}/decode_test/scoring_kaldi/best_wer
