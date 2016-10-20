# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# Setting Golang environment
export GOROOT=/usr/lib/golang
export GOPATH=$HOME/go

# User specific environment and startup programs

PATH=$PATH:$HOME/.local/bin:$HOME/bin:$GOPATH/bin

export PATH
export EDITOR=nano

export MPD_HOST='192.168.1.3'
export MPD_PORT='6600'

if [ "$(pidof xflux)" ]
then
# process was found
  echo 'xflux is running!'
else
# process not found
  xflux -l 55 -g 37
fi

