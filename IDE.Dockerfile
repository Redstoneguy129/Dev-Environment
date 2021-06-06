FROM ubuntu:focal
RUN ln -snf /usr/share/zoneinfo/Europe/London /etc/localtime && echo Europe/London > /etc/timezone
RUN apt update && apt install -y sudo openssh-server curl wget git python3-pip nodejs npm ripgrep fzf ranger libjpeg8-dev zlib1g-dev python-dev python3-dev libxtst-dev gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip build-essential
RUN cd $(mktemp -d) && git clone https://github.com/neovim/neovim --depth 1 && cd neovim && make CMAKE_BUILD_TYPE=Release install && cd .. && rm -rf neovim && cd ~
RUN mkdir /var/run/sshd && useradd -ms /bin/bash cameron && usermod -aG sudo cameron
RUN sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
RUN sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
USER cameron
RUN mkdir /home/cameron/.ssh && mkdir /home/cameron/projects && curl https://cameronwhyte.me/public-key >> /home/cameron/.ssh/authorized_keys
RUN curl https://raw.githubusercontent.com/Redstoneguy129/lunarvim/master/utils/installer/install.sh >> /home/cameron/nvim-installer.sh
RUN bash < /home/cameron/nvim-installer.sh
RUN echo "nvim -u $HOME/.config/nvim/init.lua +PackerInstall -c \"sleep 15 | qa\" && nvim" >> /home/cameron/.bash_aliases
USER root
RUN echo 'cameron:root' | chpasswd
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
