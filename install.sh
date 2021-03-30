#!/bin/zsh
# install script for macOS BigSur
# IMPORTANT NOTE: make sure to enable Full Disk Access to Terminal.app before continuing (in Security & Privacy)

# install xcode command line tools
xcode-select --install

# set environment variables
export ROOT=/System/Volumes/Data
export HOME=${ROOT}/Users/$(whoami)
cd ~/

# install homebrew & update
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# install brew version of zsh & rerun shell
brew install zsh
# NOTE: at this point, open a new tab in the terminal to refresh the environment
# NOTE: also, grant FULL DISK ACCESS to Terminal.app before continuing

# tap 3rd party packages
brew tap homebrew/cask-fonts

# NOTE: if you start encountering this weird error when installing packages:
# Errno::EPERM: Operation not permitted @ rb_sysopen - /System/Volumes/Data/Users/asdingfs/Library/Logs/Homebrew/z/00.options.out
# good workaround is to temporarily disable this line. The way to do so is:
#   1. first run export HOMEBREW_DEVELOPER=1, this will disable stashing everytime you make changes to Homebrew ruby script
#   2. go to /usr/local/Homebrew/Library/Homebrew/build.rb, search for def install method
#   3. search for 00.options.out and comment out (formula.logs/"00.options.out").write \
#            "#{formula.full_name} #{formula.build.used_options.sort.join(" ")}".strip
#   4. rerun brew install, it should work now         

# packages to install using brew install
BREW_PACKAGES=(wget curl z ripgrep ag w3m pandoc git python postgres redis node kubernetes-cli kubectx imagemagick@6 svn openssl readline sqlite3 xz zlib)
# TODO: additional brew packages: texinfo
brew install "${BREW_PACKAGES[@]}"

# packages to install using brew install —cask
# TODO: additional cask packages: mactex
CASK_PACKAGES=(1password paragon-ntfs omnidisksweeper onyx appcleaner emacs iterm2 karabiner-elements shiftit scroll-reverser \
  font-inconsolata font-latin-modern-math fluid dropbox firefox franz telegram skype homebrew/cask/flume tunnelblick spotify homebrew/cask/dash postman homebrew/cask/docker \
  android-file-transfer android-studio figma sketch gimp inkscape handbrake mediahuman-audio-converter mediahuman-youtube-downloader \
  musicbrainz-picard pdf-expert musescore sequential send-to-kindle calibre flux vlc swinsian elmedia-player parsec steam transmission)
brew install "${CASK_PACKAGES[@]}"

# apps to install manually:
# 1. Use Fluid to build native app out of web pages:
# 2. Download from AppStore:
#     - Snap (shortcuts)
#     - Monity: https://monityapp.com/ (MacOSX Status Monitoring)
#     - Battery Monitor: Health, Info (Battery Health & Display)
#     - Clocker (timezone)
#     - Calendar 366 II (nice calendar view)
#     - Relax Melodies Premium
#     - Typesy/Typist
#.    - Spark
# 3. Manually download & install from websites:
#     - Affinity Photo
#     - Affinity Designer
#     - Capture One
#     - Google Drive
#     - Spark
#     - Hotspot Shield
#     - Palette Master Element (BENQ Monitor hardware calibration)
#     - TeamViewer
#     - Discord
# 4. Install later on brew/cask if needed:
#     - visit: https://formulae.brew.sh/cask/ for full list of casks
#     - brew install texinfo/brew cask install mactex

# force link some weird packages
brew link --force imagemagick@6

# setting up ssh keys for code repositories, and add them to keychain
mkdir -p $HOME/.ssh/keys
echo "Setting up ssh keys for GitHub access..."
ssh-keygen -t rsa -C "github:anthonysetiawan.ding@gmail.com" -b 4096 -f "/Users/asdingfs/.ssh/keys/github_rsa"
ssh-add -K ~/.ssh/keys/github_rsa
echo "Setting up ssh keys for Gitlab access..."
ssh-keygen -t rsa -C "gitlab:anthonysetiawan.ding@gmail.com" -b 4096 -f "/Users/asdingfs/.ssh/keys/gitlab_rsa"
ssh-add -K ~/.ssh/keys/gitlab_rsa
echo "Setting up ssh keys for Bitbucket access..."
ssh-keygen -t rsa -C "bitbucket:anthonysetiawan.ding@gmail.com" -b 4096 -f "/Users/asdingfs/.ssh/keys/bitbucket_rsa"
ssh-add -K ~/.ssh/keys/bitbucket_rsa

# install emacs file & system configuration files
git clone https://github.com/asdingfs/macosx-emacs-init.git .emacs.d/

# soft-link system config files
# all .zlogin, .zshenv, .zshrc are set to be load from $ZDOTDIR
# they can be found in $HOME/.emacs.d/.files.d/zsh directory
# https://scriptingosx.com/2019/06/moving-to-zsh-part-2-configuration-files/ for more info
cp $HOME/.emacs.d/.files.d/zsh/home.zshenv $HOME/.zshenv # sets ZDOTDIR in $HOME/.zshenv, according to: https://www.reddit.com/r/zsh/comments/3ubrdr/proper_way_to_set_zdotdir/
. $HOME/.zshenv # load the env variable

# initialize all modules inside the emacs folder
cd .emacs.d
git submodule update --init
compaudit | xargs chmod g-w # disable the annoying zsh compinit: insecure directory warning
cd $HOME

# setup emacs scripts
ln -s $HOME/.emacs.d/.files.d/emacs/es $ROOT/usr/local/bin
ln -s $HOME/.emacs.d/.files.d/emacs/ec $ROOT/usr/local/bin
ln -s $HOME/.emacs.d/.files.d/emacs/em $ROOT/usr/local/bin
chmod 755 $HOME/.emacs.d/.files.d/emacs/es
chmod 755 $HOME/.emacs.d/.files.d/emacs/ec
chmod 755 $HOME/.emacs.d/.files.d/emacs/em
chmod 755 $ROOT/usr/local/bin/es
chmod 755 $ROOT/usr/local/bin/ec
chmod 755 $ROOT/usr/local/bin/em

# add emacs daemon as launchagent
open $ROOT/Applications/Emacs.app
ln -s $HOME/.emacs.d/.files.d/emacs/gnu.emacs.daemon.LaunchAtLogin.agent.plist $HOME/Library/LaunchAgents/
echo "NOTE: don't forget to add the Emacs Client inside the emacs folder here to Snap!"

# fix emacs compatibility with MacOSX BigSur, https://spin.atomicobject.com/2019/12/12/fixing-emacs-macos-catalina/
# also on: https://medium.com/@holzman.simon/emacs-on-macos-catalina-10-15-in-2019-79ff713c1ccc
# remember to grant Full Disk Access to Emacs
# also NOTE: please open Emacs first before executing these lines
cd $ROOT/Applications/Emacs.app/Contents/MacOS
mv Emacs Emacs-launcher # for backup
ln -s Emacs-x86_64-10_14 Emacs
cd /Applications/Emacs.app/Contents/
rm -rf _CodeSignature
cd ~/



# setup karabiner & ssh config
ln -s $HOME/.emacs.d/.files.d/ssh_config $HOME/.ssh/config
ln -s $HOME/.emacs.d/.files.d/karabiner_config $HOME/.config/karabiner

# setup themes
echo "NOTE: there is already a synced configuration. Please set Preferences > General > Preferences to Load preferences froma. custom folder or URL and set the folder to /Users/asdingfs/.emacs.d/.files.d/iterm_config"
open $HOME/.emacs.d/.files.d/Tomorrow\ Night\ Eighties.itermcolors

# run at startup
brew services start postgresql
brew services start redis
brew services start

# install ruby
\curl -sSL https://get.rvm.io | bash -s stable

# install 1Password extensions
open https://1password.com/downloads/mac/
