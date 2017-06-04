# TigerVNC
How-to build tigervnc 1.7.1 by hand
More information here: http://www.linuxfromscratch.org/blfs/view/cvs/xsoft/tigervnc.html


```
mkdir -vp build &&
cd        build &&

# Build viewer
cmake -G "Unix Makefiles"         \
      -DCMAKE_INSTALL_PREFIX=/usr \
      -DCMAKE_BUILD_TYPE=Release  \
      -Wno-dev .. &&
make &&

# Build server
cp -vR ../unix/xserver unix/ &&
tar -xf /usr/src/xorg-server.tar.xz -C unix/xserver --strip-components=1 &&

pushd unix/xserver &&
  patch -Np1 -i ../../../unix/xserver117.patch &&
  autoreconf -fi   &&

  ./configure $XORG_CONFIG \
      --disable-xwayland    --disable-dri        --disable-dmx         \
      --disable-xorg        --disable-xnest      --disable-xvfb        \
      --disable-xwin        --disable-xephyr     --disable-kdrive      \
      --disable-devel-docs  --disable-config-hal --disable-config-udev \
      --disable-unit-tests  --disable-selective-werror                 \
      --disable-static      --enable-dri3                              \
      --without-dtrace      --enable-dri2        --enable-glx          \
      --with-pic &&
  make TIGERVNC_SRCDIR=`pwd`/../../../ &&
popd
```