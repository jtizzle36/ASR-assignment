#!/bin/bash

# Training by gender

# Using optimal parameters and alignment from previous question
num_leaves=2700
num_gauss=15000
lang_dir=data/lang_wsj
orig_model=exp/tri_t1_${num_leaves}_${num_gauss}

# =================  PREPARING DATA AND TRAINING MODELS   ========================
# Filter directory by speaker gender; assumes speaker list available in my-local
# Data from speakers have been randomly selected as follows:
# Training -> 120 male/120 female/60 male and 60 female
# Test -> 8 male/8 female/4 male 4 female

for gender in m f mix
do
  train_list=${gender}_train
  test_list=${gender}_test
  exp_dir=exp/gender_${gender}
  data_dir=data/train_${gender}
  algn_dir=${orig_model}_${gender}_ali
  #./utils/subset_data_dir.sh --spk-list my-local/${train_list} data/train_words data/train_${gender}
  #./utils/subset_data_dir.sh --spk-list my-local/${test_list} data/test_words data/test_${gender}
  ./steps/align_si.sh --nj 4 ${data_dir} ${lang_dir} ${orig_model} ${algn_dir}
  #./steps/train_deltas.sh ${num_leaves} ${num_gauss} ${data_dir} ${lang_dir} ${algn_dir} ${exp_dir}
done

# =============================== TESTING MODEL ==============================
# =============================== WORK IN PROGRESS ==============================
# Finished alignment, need to train and test models
for gender in m f mix
do
  train_list=${gender}_train
  test_list=${gender}_test
  exp_dir=exp/gender_${gender}
  data_dir=data/train_${gender}
  algn_dir=${orig_model}_${gender}_ali

# need second loop for test gender (data/test_f)
# need to align lang_wsj_test_bg??
#  ./utils/mkgraph.sh data/lang_wsj_test_bg ${exp_dir} ${exp_dir}/graph
#  ./steps/decode.sh --nj 4 ${exp_dir}/graph data/test_words ${exp_dir}/decode_test
#  ./local/score_words.sh data/test_words ${exp_dir}/graph ${exp_dir}/decode_test
#  more ${exp_dir}/decode_test/scoring_kaldi/best_wer >> my-local/gender_results
done
