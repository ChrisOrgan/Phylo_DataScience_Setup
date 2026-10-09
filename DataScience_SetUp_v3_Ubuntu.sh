#!/bin/bash

# Bash linux setup
sudo apt update # updates the package sources list to get the latest list of available packages in the repositories
sudo apt upgrade -y	# updates all the packages presently installed in our Linux system to their latest versions

# Install curl, git, zip
sudo apt-get install -y curl git zip unzip

# Compilers & Java
sudo apt-get install -y autoconf automake make gcc perl zlib1g-dev libbz2-dev liblzma-dev libcurl4-gnutls-dev libssl-dev # required packages for the htslib bio-informatics package
sudo apt-get install -y cmake g++ build-essential libtool libreadline-dev pkg-config openjdk-11-jdk
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

# Install zsh
# If installing on WSL, make sure to install Windows Terminal, set profile, and fonts beforehand
sudo apt install zsh -y
sudo chsh -s /bin/zsh
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# sed prepends text to file (as opposed to appending)
sed -i '1i export PATH=$HOME/bin:/usr/local/bin:$PATH' ~/.zshrc
echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' >> ~/.zshrc
echo 'ZSH_DISABLE_COMPFIX="true"' >> ~/.zshrc
echo "alias ll='ls -l'" >> ~/.zshrc
sed -i '1i if test -t 1; then exec zsh; fi' ~/.bashrc

# change "==" to "=" so that the script is compatible with zsh
sed -i 's/==/=/g' ~/miniconda3/etc/conda/activate.d/java_home.sh

# Install Oh-My-Posh
sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
sudo chmod +x /usr/local/bin/oh-my-posh

# Themes for Oh-My-Posh
mkdir ~/.poshthemes
wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O ~/.poshthemes/themes.zip
unzip ~/.poshthemes/themes.zip -d ~/.poshthemes
chmod u+rw ~/.poshthemes/*.omp.*
rm ~/.poshthemes/themes.zip

# Setup shell
# aliens & dracula are good themes
sed -i '1i eval "$(oh-my-posh init zsh --config ~/.poshthemes/jandedobbeleer.omp.json)"' ~/.zshrc
 
# Install Miniforge (a conda derivative)
wget -O Miniforge3.sh "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
bash Miniforge3.sh -b -p "${HOME}/conda"
rm -rf ~/Miniforge3.sh # Clean up
~/conda/condabin/conda init
~/conda/condabin/conda init zsh

# Initialize conda for current shell
source ~/conda/etc/profile.d/conda.sh

# Create and activate env
conda activate base
mamba create -n DataScience -y
conda activate DataScience

# Install Conda libraries
mamba install git pip flake8 -y
mamba install ipython jupyterlab ipykernel pytest pytest-xdist -y
mamba install ply pathlib line_profiler memory_profiler -y
mamba install numpy pandas scipy scikit-learn statsmodels -y
mamba install matplotlib seaborn bokeh dash -y
mamba install biopython -y
mamba install -c bioconda mafft muscle -y
mamba install -c bioconda iqtree phylip raxml-ng -y
mamba install -c bioconda PhyML mrbayes beast2 revbayes -y
mamba update --all -y
mamba clean --all -y

# Set DataScience as the default environment for Zsh & Bash
echo "conda activate DataScience" >> ~/.zshrc
echo "conda activate DataScience" >> ~/.bashrc

# Install R
sudo apt install  -y --no-install-recommends software-properties-common dirmngr wget
wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
sudo add-apt-repository -y "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"

sudo apt install -y r-base r-base-dev
sudo apt install -y libcurl4-openssl-dev libssl-dev libxml2-dev

# Install R packages
echo "Installing packages..."
sudo Rscript -e "install.packages(c('box','testthat','tidyverse','MCMCglmm','ape', 'phytools','geiger','tidytree','deeptime','rogue','esquisse','BiocManager'), repos='https://cloud.r-project.org'); install.packages(pkgs); BiocManager::install(c('ggtree','treeio'), ask=F)"

# Setup BayesTraits
# To Run: BayesTraitsV5 Marsupials.trees Marsupials.txt
mkdir ~/bin 
cd ~/bin
curl -O https://www.evolution.reading.ac.uk/BayesTraitsV5.0.3/Files/BayesTraitsV5.0.3-Linux.tar.gz
tar zxvf BayesTraitsV5.0.3-Linux.tar.gz
rm BayesTraitsV5.0.3-Linux.tar.gz
cd ~
sed -i '1i export PATH=~/bin/BayesTraitsV5.0.3-Linux:$PATH' ~/.bashrc
sed -i '1i export PATH=~/bin/BayesTraitsV5.0.3-Linux:$PATH' ~/.zshrc

# Restart shell
source .zshrc
