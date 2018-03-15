#!/bin/bash
ngauss=9000

# build features build features
for dir in train_words_cmvn test_words_cmvn; do
~/asworkdir/steps/make_mfcc.sh --nj 4 --mfcc-config ~/asworkdir/conf/mfcc.conf ~/asworkdir/data/$dir ~/asworkdir/exp/make_mfcc/$dir
done

# build false cmvn values
for dir in train_words_cmvn test_words_cmvn; do
~/asworkdir/my-local/compute_cmvn_stats_fake.sh --fake ~/asworkdir/data/$dir
done

# train model
~/asworkdir/my-local/train_mono_cmvn2.sh --nj 4 --totgauss ${ngauss} ~/asworkdir/data/train_words_cmvn ~/asworkdir/data/lang_wsj ~/asworkdir/exp/mono_word${ngauss}_fake_cvnm
# make graphs
~/asworkdir/utils/mkgraph.sh --mono ~/asworkdir/data/lang_wsj_test_bg ~/asworkdir/exp/mono_word${ngauss}_fake_cvnm ~/asworkdir/exp/mono_word${ngauss}_fake_cvnm/graph
# decode model
~/asworkdir/steps/decode.sh --nj 4 ~/asworkdir/exp/mono_word${ngauss}_fake_cvnm/graph ~/asworkdir/data/test_words ~/asworkdir/exp/mono_word${ngauss}_fake_cvnm/decode_test
# score model
~/asworkdir/local/score_words.sh ~/asworkdir/data/test_words_cmvn exp/mono_word${ngauss}_fake_cvnm/graph ~/asworkdir/exp/mono_word${ngauss}_fake_cvnm/decode_test
# output score to file
more ~/asworkdir/exp/mono_word${ngauss}_fake_cvnm/decode_test/scoring_kaldi/best_wer > ~/asworkdir/my-local/false_cvmn_${ngauss}_bestWER.txt
