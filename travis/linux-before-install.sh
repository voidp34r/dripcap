rm -rf ~/.nvm
wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.30.2/install.sh | bash
source ~/.nvm/nvm.sh
nvm install $NODE_VERSION
nvm use --delete-prefix $NODE_VERSION

export CC="gcc-5"
export CXX="g++-5"
wget https://dripcap.org/storage/libpcap-1.7.4.tar.gz
tar xzf libpcap-1.7.4.tar.gz
(cd libpcap-1.7.4 && ./configure -q --enable-shared=no && make -j2 && sudo make install)

sudo apt-get remove libicu-dev
wget `curl https://api.github.com/repos/dripcap/libv8/releases | jq -r '(.[0].assets[] | select(.name == "v8-linux-amd64.deb")).browser_download_url'`
sudo dpkg -i --force-overwrite v8-linux-amd64.deb

wget `curl https://api.github.com/repos/dripcap/librocksdb/releases | jq -r '(.[0].assets[] | select(.name == "rocksdb-linux-amd64.deb")).browser_download_url'`
sudo dpkg -i rocksdb-linux-amd64.deb

export ELECTRON_VERSION=`jq .devDependencies.electron package.json -r`
echo $ELECTRON_VERSION
npm install --depth 0 -g electron@${ELECTRON_VERSION}

export GOPATH=/home/travis/gopath
export GOBIN=/home/travis/gopath/bin
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
export DISPLAY=':99.0'
