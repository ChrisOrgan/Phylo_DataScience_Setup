#!/bin/zsh

# 1. Install Homebrew (The Mac "apt") if not present
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add brew to path for the current session
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 2. Compilers & Core Tools
# Xcode Command Line Tools are required for compilers
xcode-select --install || echo "Xcode tools already installed"

brew update
brew install git curl zip unzip cmake gcc make openssl readline

# 3. Java Setup
brew install openjdk@11
# macOS specific way to find Java Home
export JAVA_HOME=$(/usr/libexec/java_home -v 11)
echo "export JAVA_HOME=$(/usr/libexec/java_home -v 11)" >> ~/.zshrc

# 4. Zsh & Oh-My-Posh
# macOS uses Zsh by default, so we just install plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# NOTE: macOS sed requires -i '' (empty quotes)
sed -i '' '1i export PATH=$HOME/bin:/usr/local/bin:$PATH' ~/.zshrc
echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' >> ~/.zshrc
echo "alias ll='ls -l'" >> ~/.zshrc

# Oh-My-Posh installation via Brew
brew install jandedobbeleer/oh-my-posh/oh-my-posh
echo 'eval "$(oh-my-posh init zsh --config $(brew --prefix oh-my-posh)/themes/jandedobbeleer.omp.json)"' >> ~/.zshrc

# 5. Miniforge (Conda/Mamba)
# This installer automatically detects if you are on Intel or Apple Silicon
brew install --cask miniforge
conda init zsh
source ~/.zshrc

# 6. Create Environment
# We use mamba directly as Miniforge comes with it
mamba create -n DataScience -y
conda activate DataScience

# 7. Install Conda libraries
mamba install git pip flake8 -y
mamba install ipython jupyterlab ipykernel pytest pytest-xdist -y
mamba install ply pathlib line_profiler memory_profiler -y
mamba install numpy pandas scipy scikit-learn statsmodels -y
mamba install matplotlib seaborn bokeh dash -y
mamba install biopython -y
mamba install -c bioconda mafft muscle iqtree phylip raxml-ng -y
mamba install -c bioconda PhyML mrbayes beast2 revbayes -y
mamba update --all -y
mamba clean --all -y

# 8. Install R
brew install --cask r
# R development tools
brew install libxml2 openssl

# 9. Install R packages
Rscript -e "install.packages(c('box','testthat','tidyverse','MCMCglmm','ape', 'phytools','geiger','tidytree','deeptime','rogue','esquisse','BiocManager'), repos='https://cloud.r-project.org'); BiocManager::install(c('ggtree','treeio'), ask=F)"

# 10. Setup BayesTraits (macOS Version)
mkdir -p ~/bin 
cd ~/bin
# Note the URL change to OSX
curl -O https://www.evolution.reading.ac.uk/BayesTraitsV5.0.3/Files/BayesTraitsV5.0.3-OSX.tar.gz
tar zxvf BayesTraitsV5.0.3-OSX.tar.gz
rm BayesTraitsV5.0.3-OSX.tar.gz
cd ~
echo 'export PATH=~/bin/BayesTraitsV5.0.3-OSX:$PATH' >> ~/.zshrc

# 11. Final Step: Set DataScience as default
echo "conda activate DataScience" >> ~/.zshrc

source ~/.zshrc