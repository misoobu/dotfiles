if [ -d ${HOME}/.rbenv  ] ; then
  PATH=${HOME}/.rbenv/bin:${PATH}
  export PATH
  eval "$(rbenv init --no-rehash - zsh)"
fi
