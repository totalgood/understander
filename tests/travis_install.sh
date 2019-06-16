#!/bin/bash
# This script is meant to be called by the "install" step defined in
# .travis.yml. See http://docs.travis-ci.com/ for more details.
# The behavior of the script is controlled by environment variabled defined
# in the .travis.yml in the top level folder of the project.
#
# This script is taken from Scikit-Learn (http://scikit-learn.org/)
#
# THIS SCRIPT IS SUPPOSED TO BE AN EXAMPLE. MODIFY IT ACCORDING TO YOUR NEEDS!

set -e

if [[ "$DISTRIB" == "conda" ]]; then
    # Deactivate the travis-provided virtual environment and setup a
    # conda-based environment instead
    export ENVIRONMENT_YML="conda/environment.yml"
    export CONDA_PYTHON_VERSION=3.7
    echo "ENVIRONMENT_YML = $ENVIRONMENT_YML"
    echo "TRAVIS_PYTHON_VERSION = $TRAVIS_PYTHON_VERSION"
    echo "CONDA_PYTHON_VERSION = $CONDA_PYTHON_VERSION"
    env
    sudo apt-get update
    sudo apt-get remove -y python-boto
    sudo apt-get install -y libasound* build-essential gfortran libopenblas-dev liblapack-dev pandoc portaudio19-dev
    if [[ ! -d "$HOME/miniconda" ]] ; then
        if [[ ! -f "miniconda.sh" ]] ; then
            wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh ;
        fi
        bash miniconda.sh -b -f -p "$HOME/miniconda" ;
    fi
    # wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh;
    # bash miniconda.sh -b -f -p $HOME/miniconda
    export PATH="$HOME/miniconda/bin:$PATH"
    cp -f .condarc ~/.condarc
    conda update -n base conda
    hash -r  # refresh hashtable of commands like conda and deactivate
    echo "running: conda env create -f $ENVIRONMENT_YML -n understander python=$CONDA_PYTHON_VERSION"
    travis_wait 30 conda env create -q -f $ENVIRONMENT_YML -n understander python=$CONDA_PYTHON_VERSION
    source activate understander
    conda install pip
    conda install python-annoy
    pip install -U PyScaffold ;
    pip install -r requirements.txt
    pip install -U -e .
    python -c "import nltk; nltk.download('punkt')"
    conda info -a
    conda list
    pip install codecov

    if [[ ! -d "$HOME/miniconda" ]] ; then
        deactivate || echo "conda and deactivate commands not yet installed"

        # Use the anaconda3 installer
        DOWNLOAD_DIR=${DOWNLOAD_DIR:-$HOME/.tmp/anaconda3}
        mkdir -p $DOWNLOAD_DIR
        wget -q http://repo.continuum.io/archive/Anaconda3-2019.03-Linux-x86_64.sh -O $DOWNLOAD_DIR/anaconda3.sh
        chmod +x $DOWNLOAD_DIR/anaconda3.sh && bash $DOWNLOAD_DIR/anaconda3.sh -b -u -p $HOME/anaconda3
        # rm -r -d -f $DOWNLOAD_DIR
        # export PATH=$HOME/anaconda3/bin:$PATH
    fi
    conda update -q -y conda
    conda install -q -y pip
    conda install -q -y swig
    echo "creating conda environemnt -n understander -f $ENVIRONMENT_YML"
    # Configure the conda environment and put it in the path using the provided versions
    if [[ -f "$ENVIRONMENT_YML" ]]; then
        conda env create -n understander -f "$ENVIRONMENT_YML"
    else
        echo "WARNING: Unable to find an environment.yml file !!!!!!"
        conda create -q -n understander --yes python=$PYTHON_VERSION pip
    fi
    source activate understander
    echo "Installing pip with conda quietly"
    conda install -q -y pip

    # download spacy English language model
    echo "Installing pip with conda quietly"
    conda install spacy
    echo "Downloading spacy language model"
    python -m spacy download en

    # download NLTK punkt, Penn Treebank, and wordnet corpora
    python -c "import nltk; nltk.download('punkt'); nltk.download('treebank'); nltk.download('wordnet');"
    which python
    python --version

elif [[ "$DISTRIB" == "ubuntu" ]]; then
    # Use standard ubuntu packages in their default version
    echo $DISTRIB
    apt-get install -y build-essential swig gfortran
    apt-get install -y python-dev python3-dev python-pip python3-pip

    apt-get install -y python-igraph

    # SpeechRecognizer requires PyAudio
    apt-get install -y portaudio19-dev python-pyaudio python3-pyaudio

    # for scipy
    apt-get install -y libopenblas-dev liblapack-dev
    apt-get install -y python-scipy python3-scipy

    # for matplotlib:
    apt-get install -y libpng12-dev libfreetype6-dev
    apt-get install -y tcl-dev tk-dev python-tk python3-tk
fi

if [[ "$COVERAGE" == "true" ]]; then
    pip install coverage coveralls
fi
