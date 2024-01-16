# SETUP

logged into phoenix

started a `screen` session

Following the [sleap instructions](https://sleap.ai/) and used conda for installation 

`conda create -y -n sleap -c conda-forge -c nvidia -c sleap -c anaconda sleap`

This takes a while. 

This didnt seem to actually work. The solving environment step was stuck. Cancelled. 

Read a bit more on the sleap website and yep, need to to use mamba. 

Used this to install mamba: 

`conda update -n base conda`

`conda install -n base conda-libmamba-solver`

`conda config --set solver libmamba`

then ran this to prepare the conda virtual env: 

`conda activate sleap`

This has worked! 




