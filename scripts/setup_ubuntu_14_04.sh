#!/usr/bin/env bash
echo "       Installing all build prerequisites         "
echo "detecting if any previous install isn't complete..."
/usr/share/debconf/fix_db.pl
# tell system that I want to support 32-bit packages
dpkg --add-architecture i386
apt-get update
apt-get install python-software-properties -y
# add firefox nightly repo
#add-apt-repository ppa:ubuntu-mozilla-daily/ppa -y
#apt-get update

echo "             Install git and repo                 "
apt-get install -y git-core
# force update repo
curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > /bin/repo
chmod a+x /bin/repo

echo "        Install prerequisite libraries            "
add-apt-repository -y ppa:nilarimogard/webupd8
#add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu/ raring main restricted universe multiverse"
apt-get update
apt-get install -y --no-install-recommends autoconf2.13 bison bzip2 ccache curl flex gawk gcc g++ g++-multilib gcc-4.7 g++-4.7 g++-4.7-multilib git lib32ncurses5-dev lib32z1-dev libgconf2-dev zlib1g:amd64 zlib1g-dev:amd64 zlib1g:i386 zlib1g-dev:i386 libgl1-mesa-dev libx11-dev make zip libxml2-utils lzop libfontconfig libgtk2.0-dev libasound2 android-tools-adb
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.7 1
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 2
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.7 1
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.8 2
update-alternatives --set gcc "/usr/bin/gcc-4.7"
update-alternatives --set g++ "/usr/bin/g++-4.7"

#echo "Install libraries to overcome emulator build issues"
#apt-get install -y libgl1-mesa-dev libglapi-mesa:i386 libgl1-mesa-glx:i386
#sudo ln -s /usr/lib/i386-linux-gnu/libX11.so.6 /usr/lib/i386-linux-gnu/libX11.so
#sudo ln -s /usr/lib/i386-linux-gnu/mesa/libGL.so.1 /usr/lib/i386-linux-gnu/libGL.so
#sudo apt-get install -y binutils-gold

# Set ccache max size to 3GB
ccache --max-size 3GB

echo "  Set the permission filters to the right devices "

# Source http://developer.android.com/tools/device.html
if [ -f /etc/udev/rules.d/51-android.rules ]
then
    rm /etc/udev/rules.d/51-android.rules
fi

cat <<EOF >> /etc/udev/rules.d/51-android.rules
#Acer
SUBSYSTEM=="usb", ATTR{idVendor}=="0502", MODE="0666", GROUP="vagrant"
#ASUS
SUBSYSTEM=="usb", ATTR{idVendor}=="0b05", MODE="0666", GROUP="vagrant"
#Dell
SUBSYSTEM=="usb", ATTR{idVendor}=="413c", MODE="0666", GROUP="vagrant"
#Foxconn
SUBSYSTEM=="usb", ATTR{idVendor}=="0489", MODE="0666", GROUP="vagrant"
#Garmin-Asus
SUBSYSTEM=="usb", ATTR{idVendor}=="091e", MODE="0666", GROUP="vagrant"
#Google
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", MODE="0666", GROUP="vagrant"
#HTC
SUBSYSTEM=="usb", ATTR{idVendor}=="0bb4", MODE="0666", GROUP="vagrant"
#Huawei
SUBSYSTEM=="usb", ATTR{idVendor}=="12d1", MODE="0666", GROUP="vagrant"
#K-Touch
SUBSYSTEM=="usb", ATTR{idVendor}=="24e3", MODE="0666", GROUP="vagrant"
#KT Tech
SUBSYSTEM=="usb", ATTR{idVendor}=="2116", MODE="0666", GROUP="vagrant"
#Kyocera
SUBSYSTEM=="usb", ATTR{idVendor}=="0482", MODE="0666", GROUP="vagrant"
#Lenevo
SUBSYSTEM=="usb", ATTR{idVendor}=="17EF", MODE="0666", GROUP="vagrant"
#LG
SUBSYSTEM=="usb", ATTR{idVendor}=="1004", MODE="0666", GROUP="vagrant"
#Motorola
SUBSYSTEM=="usb", ATTR{idVendor}=="22b8", MODE="0666", GROUP="vagrant"
#NEC
SUBSYSTEM=="usb", ATTR{idVendor}=="0409", MODE="0666", GROUP="vagrant"
#Nvidia
SUBSYSTEM=="usb", ATTR{idVendor}=="0955", MODE="0666", GROUP="vagrant"
#OTGV
SUBSYSTEM=="usb", ATTR{idVendor}=="2257", MODE="0666", GROUP="vagrant"
#Pantech
SUBSYSTEM=="usb", ATTR{idVendor}=="10A9", MODE="0666", GROUP="vagrant"
#Philips
SUBSYSTEM=="usb", ATTR{idVendor}=="10A9", MODE="0666", GROUP="vagrant"
#PMC-Sierra
SUBSYSTEM=="usb", ATTR{idVendor}=="04da", MODE="0666", GROUP="vagrant"
#Qualcomm
SUBSYSTEM=="usb", ATTR{idVendor}=="05c6", MODE="0666", GROUP="vagrant"
#SK Telesys
SUBSYSTEM=="usb", ATTR{idVendor}=="1f53", MODE="0666", GROUP="vagrant"
#Samsung
SUBSYSTEM=="usb", ATTR{idVendor}=="04e8", MODE="0666", GROUP="vagrant"
#Sharp
SUBSYSTEM=="usb", ATTR{idVendor}=="04dd", MODE="0666", GROUP="vagrant"
#Sony Ericsson
SUBSYSTEM=="usb", ATTR{idVendor}=="0fce", MODE="0666", GROUP="vagrant"
#Toshiba
SUBSYSTEM=="usb", ATTR{idVendor}=="0930", MODE="0666", GROUP="vagrant"
#ZTE
SUBSYSTEM=="usb", ATTR{idVendor}=="19d2", MODE="0666", GROUP="vagrant"
EOF
chmod a+r /etc/udev/rules.d/51-android.rules
# add spectrum rule
if [ ! -d .android ]
then
    mkdir .android
echo 0x1782 > .android/adb_usb.ini
fi
service udev restart

echo "             Install Java for adb                 "
# Not sure if it's necessary but the build complaints about the Java version.
apt-get purge -y openjdk*
add-apt-repository -y ppa:webupd8team/java
apt-get update
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
apt-get install -y oracle-java7-installer

echo "             Install web console                  "
apt-get install -y python-pip python-dev
pip --default-timeout=100 install butterfly

#echo "                Enable GUI                        "
#/usr/share/debconf/fix_db.pl
#apt-get update
#apt-get install -y lxde-core lightdm-gtk-greeter xinit
# Remove Ubuntu start manager
#update-rc.d -f lightdm remove
# get firefox nightly
#apt-get install -y firefox-trunk

# clean all unrequired packages
#apt-get autoremove -y

echo "              Create helper scripts               "

echo "   Configure git                                  "
if [ -f .gitconfig ]
then
    echo "[user]"
    echo "     name = My name"
    echo "    email = me@mail.com"
    echo "[color]"
    echo "    ui = auto"
fi > .gitconfig

#echo "   Create 'gui.sh' to start GUI                   "
#echo "sudo startx" > gui.sh
#chmod a+x gui.sh

echo "   Create 'home.sh' to go back to correct home    "
echo "cd /home/vagrant" > /root/home.sh
chmod a+x /root/home.sh

#echo "   Create 'init_B2G.sh' to fetch B2G repository    "
#echo "#!/bin/bash
#if [ -d B2G/.git ]
#then
#    echo "The git directory exists."
#    echo "update B2G repository"
#    cd B2G
#    git pull
#    cd ..
#else
#    rm B2G/README.md
#    # purge mac temp
#    rm B2G/.DS_Store
#    echo "clone B2G repository"
#    git clone https://github.com/mozilla-b2g/B2G.git B2G
#fi" > B2G_init.sh
#chmod a+x B2G_init.sh

#echo "   Create 'init_gecko.sh' to fetch gecko source    "
#echo "#!/bin/bash
#if [ -d gecko/.hg ]
#then
#    echo "The directory exists."
#    echo "update gecko repository"
#    cd gecko
#    hg pull -u
##    git pull
#    cd ..
#else
#    rm gecko/README.md
#    # purge mac temp
#    rm gecko/.DS_Store
#    echo "setup gecko build environment"
    # https://developer.mozilla.org/en-US/docs/Developer_Guide/Build_Instructions/Linux_Prerequisites
#    wget https://hg.mozilla.org/mozilla-central/raw-file/default/python/mozboot/bin/bootstrap.py && python bootstrap.py
#    echo "clone gecko repository"
#    hg clone http://hg.mozilla.org/mozilla-central gecko
    #git clone https://github.com/mozilla/gecko-dev gecko
#    echo "create .mozconfig file in gecko"
#    rm gecko/.mozconfig
#    echo \"mk_add_options MOZ_OBJDIR=../build\"      > gecko/.mozconfig
#    echo \"mk_add_options MOZ_MAKE_FLAGS=\\\"-j9 -s\\\"\"  >> gecko/.mozconfig
#    echo \"\"                                        >> gecko/.mozconfig
#    echo \"ac_add_options --enable-application=b2g\" >> gecko/.mozconfig
#    echo \"ac_add_options --disable-libjpeg-turbo\"  >> gecko/.mozconfig
#    echo \"\"                                        >> gecko/.mozconfig
#    echo \"# This option is required if you want to be able to run Gaia tests\" >> gecko/.mozconfig
#    echo \"ac_add_options --enable-tests\"           >> gecko/.mozconfig
#    echo \"\"                                        >> gecko/.mozconfig
#    echo \"# turn on mozTelephony/mozSms interfaces\" >> gecko/.mozconfig
#    echo \"# Only turn this line on if you actually have a dev phone\" >> gecko/.mozconfig
#    echo \"# you want to forward to. If you get crashes at startup,\" >> gecko/.mozconfig
#    echo \"# make sure this line is commented.\"     >> gecko/.mozconfig
#    echo \"#ac_add_options --enable-b2g-ril\"        >> gecko/.mozconfig
#    echo "done. You can start build gecko with command: \'./mach build\'."
#fi" > gecko_init.sh
#chmod a+x gecko_init.sh

echo "   Create 'init_gaia.sh' to fetch gaia source    "
echo "#!/bin/bash
if [ -d gaia/.git ]
then
    echo "The git directory exists."
    echo "update gaia repository"
    cd gaia
    gaia pull
    #repo sync
    cd ..
else
    rm gaia/README.md
    # purge mac temp
    rm gaia/.DS_Store
    echo "shallow clone gaia repository"
    git clone --depth=1 https://github.com/mozilla-b2g/gaia.git gaia
    # use git-repo instead of clone gaia directly
    #cd gaia
    #repo init -u https://github.com/gasolin/gaia-repo.git
    #repo sync
    cd ..
fi" > gaia_init.sh
chmod a+x gaia_init.sh

# helper tool
#if [ ! -d tool ]
#then
#    mkdir tool
#fi
#curl https://raw.github.com/mozilla/moz-git-tools/master/git-patch-to-hg-patch > tool/git-patch-to-hg-patch
#chmod a+x tool/git-patch-to-hg-patch
