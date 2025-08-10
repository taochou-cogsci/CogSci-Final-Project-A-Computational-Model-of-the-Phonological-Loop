# CogSci-Final-Project-A-Computational-Model-of-the-Phonological-Loop
Welcome! This is the repository for our group’s final project in Intro to Cognitive Science. We explore and extend a classic computational model of the phonological loop by modifying its decay and rehearsal mechanisms, and incorporating semantic similarity using word embeddings. All code is written in MATLAB and available here. 

You may have to download the GloVe file on your own: https://nlp.stanford.edu/projects/glove/

To run the code, you just need to run 'main.m'. Several options of the model are available, which you can choose to turn on or not. Parameters will be estimated automatically. Note that if you turn on all the functions, the estimation might be very slow (because there will be too many combinations of parameters). 

Another way is that you can directly run 'run_model.m' in the command line, if the parameters have been defined. For example, you can type the following lines in the command line:

>run_model('exponential', 'head to tail', 'off', 'off', 0.46, 0.6, 0, 0, 1)

>run_model('exponential', 'random', 'on', 'off', 0.46, 0.6, 0.08, 0, 1)  

>run_model('exponential', 'head to tail', 'on', 'on', 0.46, 0.6, 0.08, 0.12, 0)  # the last parameter determines if it's a test/evaluation


Group Members: Dao Zhou, Yuze Song, Wen-Shuo Chao
