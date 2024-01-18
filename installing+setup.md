# SETUP

## phoenix 

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

Also want to install locally for the labelling GUI

## local install

```conda update -n base conda```

```conda install -n base conda-libmamba-solver```

```conda config --set solver libmamba```


Installed `sleap` using this command: 

```conda create -y -n sleap -c conda-forge -c anaconda -c sleap sleap=1.3.3```

Checked it installed using this command

```conda activate sleap```

```sleap-label```

Output: 

```
Saving config: /Users/karissabarthelson/.sleap/1.3.3/preferences.yaml

Software versions:
SLEAP: 1.3.3
TensorFlow: 2.9.1
Numpy: 1.22.4
Python: 3.9.15
OS: macOS-10.15.7-x86_64-i386-64bit
```

This took a while. But eventually opened a GUI for me. 
