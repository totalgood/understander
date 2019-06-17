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

export DISTRIB="conda"

if [[ "$DISTRIB" == "conda" ]]; then
    export ENVIRONMENT_YML="environment.yml"
    # export CONDA_PYTHON_VERSION=3.7
    echo "ENVIRONMENT_YML = $ENVIRONMENT_YML"
    echo "TRAVIS_PYTHON_VERSION = $TRAVIS_PYTHON_VERSION"
    echo "CONDA_PYTHON_VERSION = $CONDA_PYTHON_VERSION"
    env
    sudo apt-get update
    sudo apt-get remove -y python-boto
    sudo apt-get install -y libasound* build-essential gfortran libopenblas-dev liblapack-dev pandoc portaudio19-dev
    if [[ -z "$(which conda)" ]] ; then
        echo "Install miniconda (conda)..." ;
        if [[ ! -f "miniconda.sh" ]] ; then

            echo "Downloading miniconda.sh: https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh"
            wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh ;
        fi ;
        echo "Running miniconda.sh: bash miniconda.sh -b -f -p $HOME/miniconda" ;
        bash miniconda.sh -b -f -p "$HOME/miniconda" ;
        export PATH="$HOME/miniconda/bin:$PATH"
    fi ;
    # wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh;
    # bash miniconda.sh -b -f -p $HOME/miniconda
    cp -f .condarc ~/.condarc
    hash -r  # refresh hashtable of commands like conda and deactivate
    echo "PATH: $PATH"
    echo "which conda: $(which conda)"
    echo "Installing anaconda with conda quietly..."
    conda install -y anaconda
    # conda update -y -q -n base conda
    if [[ -z "$(which travis_wait)" ]] ; then
        echo "conda env create -n understander -f $ENVIRONMENT_YML"
        conda env create -n understander -f $ENVIRONMENT_YML
    else
        echo travis_wait 1 echo "waited 1 minute for this to echo"
        echo "running: travis_wait 30 conda env create -f $ENVIRONMENT_YML -n understander"
        travis_wait 30 conda env create -n understander -f $ENVIRONMENT_YML
    fi
    conda activate understander
    echo "Installing pip with conda quietly..."
    conda install -q -y  pip
    conda install -q -y python-annoy
    conda install -q -y swig
    echo "Installing spacy with conda quietly..."
    conda install -q -y spacy
    echo "Downloading spacy 'en' language model..."
    python -m spacy download en
    pip install -U PyScaffold ;
    pip install -r requirements.txt
    pip install --upgrade pip setuptools
    pip install -U -e .
    echo "Downloading nltk punkt, Penn Treebank, and wordnet corpora..."
    python -c "import nltk; nltk.download('punkt'); nltk.download('treebank'); nltk.download('wordnet');"
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
    echo "which python: $(which python)"
    echo "python --version: $(python --version)"

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
