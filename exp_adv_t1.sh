#!/bin/bash

# Training by gender

# Using optimal parameters and alignment from previous question
num_leaves=3000
num_gauss=19000
lang_dir=./data/lang_wsj
orig_model=./exp/tri_t1_${num_leaves}_${num_gauss}

for gender_model in m f mix
do
  # =========================== PREPARING DATA ==============================
  # Filter directory by speaker gender; assumes speaker list available in my-local
  # Data from speakers have been randomly selected as follows:
  # Training -> 120 male/120 female/60 male and 60 female
  # Test -> 8 male/8 female/4 male 4 female
  train_list=${gender_model}_train
  test_list=${gender_model}_test
  data_dir=./data/train_${gender_model}
  algn_dir=${orig_model}_${gender_model}_ali
  ./utils/subset_data_dir.sh --spk-list my-local/${train_list} data/train_words data/train_${gender_model}
  ./utils/subset_data_dir.sh --spk-list my-local/${test_list} data/test_words data/test_${gender_model}
  ./steps/align_si.sh --nj 4 ${data_dir} ${lang_dir} ${orig_model} ${algn_dir}

  # =========================  TRAINING MODELS ================================
  for gender_test in m f mix
  do
    exp_dir=./exp/gender_${gender_model}_${gender_test}
    test_dir=./data/test_${gender_test}
    ./steps/train_deltas.sh ${num_leaves} ${num_gauss} ${data_dir} ${lang_dir} ${algn_dir} ${exp_dir}

  # =============================== TESTING MODEL ==============================
    ./utils/mkgraph.sh ./data/lang_wsj_test_bg ${exp_dir} ${exp_dir}/graph
    ./steps/decode.sh --nj 4 ${exp_dir}/graph ${test_dir} ${exp_dir}/decode_test
    ./local/score_words.sh ${test_dir} ${exp_dir}/graph ${exp_dir}/decode_test
    more ${exp_dir}/decode_test/scoring_kaldi/best_wer >> ./my-local/gender_results
  done
done
