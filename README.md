# SETTING UP A DATA SCIENCE ENVIRONMENT (Windows, Linux, & OSX)

# WINDOWS
## SETTING UP WINDOWS LINUX SUBSYSTEM
1. Open powershell in admin
	'wsl --install'
	'Set-ExecutionPolicy -ExecutionPolicy RemoteSigned'
	Reboot
2. Run powershell (admin) and run
	wsl --install Ubuntu 
3. Run powershell (admin) and run:
		.\DataScience_SetUp_v3_Windows.ps1			
4. Windows Terminal setup
	1. Open settings for terminal
	2. Set as default application and default profile to Ubutnu or Powershell
	3. In settings, select RobotoMono Nerd Font for powershell & Ubuntu
	4. To hide shells (like azure and the old powershell) change "hidden": true in their guids
5. Install stand alone software & add to system paths
	Run powershell (admin) and run:
	.\DataScience_SetUp_PhyloApps_Windows.ps1
6. Install Positron plugins
	Better Comments
	Code Spell Checker
	autoDocstring
	Remote WSL
7. Install VS Code with plugins in Windows
	Extensions:
		Better Comments
		Code Spell Checker
		Edit csv
		GitHub Repositories
		Markdownlint
		Python
		Flake8
		autoDocstring
		Jupyter
		Remote SSH, WSL, Development, Containers
		YAML
	Settings:
		Enter command palette (ctrl-shift-p)
			- type "python interpreter" and choose conda env
		In Settings (change user name accordingly):
			Check box: "Jupyter > interactive window > text editor: execute selection
			Search for "Editor: insert spaces". Unselect to use tabs
			To ignore tabs, search for "Flake8 Args", click Add Item and paste in "--ignore=W191"
	
# LINUX (WSL)
1. From home run:
	bash ./DataScience_SetUp_v3_Ubuntu.sh

# OSX (not tested)
1. Install MesloLGS NF fonts from this folder (or https://github.com/romkatv/dotfiles-public/tree/master/.local/share/fonts/NerdFonts)
2. Download & install Positron: https://positron.posit.co/download.html
3. In terminal, run:
	bash DataScience_SetUp_v2_OSX.sh
