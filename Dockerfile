# Typically, constructing a Linux live image relies on files from the host system. This Dockerfile,
# a version-controlled mechanism to produce a host system for live image builds.

# Note: the host system Ubuntu version (below) is defined separately from the version of the
# generated Ubuntu image.
ARG CODENAME=bookworm
FROM debian:${CODENAME}
# Define the Ubuntu code name again because Docker clears the argument after the FROM command.
ARG CODENAME=bookworm

# Copy the apt repository mirror list into the Docker image.
# 
# For increased transfer rates, consider selecting a mirror geographically
# closer mirror.
# 
# Note: After the support window for a specific release ends, the packages are
# moved to the 'old-releases' URL, which makes substitution becomes mandatory
# in-order to build older releases from scratch.
#
RUN echo $CODENAME
COPY src/livecd/chroot/etc/apt/sources.list /etc/apt/sources.list
# Copy the apt-preferences file to ensure backports and proposed repositories are never automatically selected.

RUN sed --in-place "s*CODENAME_SUBSTITUTE*$CODENAME*g" "/etc/apt/sources.list"

# Ensure all Dockerfile package installation operations are non-interactive, DEBIAN_FRONTEND=noninteractive is insufficient [1]
# [1] https://github.com/phusion/baseimage-docker/issues/58
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Refresh the apt package metadata
RUN apt-get update

RUN apt-get install --yes \
        make rsync sudo debootstrap squashfs-tools xorriso git git-lfs gettext \
        dosfstools mtools checkinstall cmake time \
        shim-signed grub-efi-amd64-signed grub-efi-amd64-bin grub-efi-ia32-bin grub-pc-bin \
        devscripts debhelper ccache libtool-bin \
        gawk pkg-config comerr-dev docbook-xsl e2fslibs-dev fuse3 \
        libaal-dev libblkid-dev libbsd-dev libext2fs-dev libncurses5-dev \
        libncursesw5-dev libreadline-dev libreadline8 \
        libreiser4-dev libtinfo-dev libxslt1.1 nilfs-tools ntfs-3g ntfs-3g-dev \
        quilt sgml-base uuid-dev vmfs-tools xfslibs-dev xfsprogs xml-core \
        xsltproc libssl-dev zstd \
        libgtk-3-dev python3-whichcraft python3-babel \
        vim

# Restore interactivity of package installation within Docker
RUN echo 'debconf debconf/frontend select Dialog' | debconf-set-selections
