from speechbrain.pretrained import EncoderASR
asr_model = EncoderASR.from_hparams(source="aioxlabs/dvoice-darija", savedir="pretrained_models/asr-wav2vec2-dvoice-dar")
asr_model.transcribe_file('ATLAS_APP\\audio1.wav')
