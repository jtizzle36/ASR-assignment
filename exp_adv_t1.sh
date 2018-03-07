#!/bin/bash

# Training by gender

# Preparing data:
# Filter directory by speaker gender; assumes speaker list available
# Data from 120 male and 120 female speakers have been randomly selected
#for gender in m f
#do
#  ./utils/subset_data_dir.sh --spk-list my-local/${gender} data/train_words data/train_${gender}
#done

# =================================== WORK IN PROGRESS ===================================
# Using optimal parameters found in previous question
num_leaves=2500 #<- REPLACE WITH PARAMETERS!
num_gauss=15000 #<- REPLACE WITH PARAMETERS!

orig_model=exp_name=tri_t1_${num_leaves}_${num_gauss}
algn_dir=${orig_model}_ali
steps/align_si.sh --nj 4 ${data_dir} ${lang_dir} ${orig_model} ${algn_dir}

# Start loop for gender
for gender in m f
do
  data_dir=data/train_${gender}
  lang_dir=data/lang_wsj
  exp_dir=exp/gender_${exp_name}
  ./steps/train_deltas.sh ${num_leaves} ${num_gauss} ${data_dir} ${lang_dir} ${algn_dir} ${exp_dir}
  ./utils/mkgraph.sh data/lang_wsj_test_bg ${exp_dir} ${exp_dir}/graph
  ./steps/decode.sh --nj 4 ${exp_dir}/graph data/test_words ${exp_dir}/decode_test
  ./local/score_words.sh data/test_words ${exp_dir}/graph ${exp_dir}/decode_test
  more ${exp_dir}/decode_test/scoring_kaldi/best_wer >> my-local/gender_results
done
