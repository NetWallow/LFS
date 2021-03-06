export LFS = /mnt/lfs
cd $LFS/sources

mkdir -v build
cd build
../configure --prefix=/tools            \
             --with-sysroot=$LFS        \
             --with-lib-path=/tools/lib \
             --target=$LFS_TGT          \
             --disable-nls              \
             --disable-werror
make
case $(uname -m) in
  x86_64) mkdir -v /tools/lib && ln -sv lib /tools/lib64;;
esac
make install

cd $LFS/sources
tar -xf mpfr-4.0.1.tar.xz
mv -v mpfr-4.0.1.tar.xz mpfr
tar -xf gmp-6.1.2.tar.xz
mv -v gmp-6.1.2.tar.xz gmp
tar -xf mpc-1.1.0.tar.gz
mv -v mpc-1.1.0.tar.gz mpc

for file in gcc/config{linux,i386/linux{,64}}.h
do
  cp -uv $file{,.orig}
sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
-e 's@/usr@/tools@g' $file.orig > $file
echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
touch $file.orig
done
case $(uname -m) in
x86_64)
sed -e '/m64=/s/lib64/lib/' \
-i.orig gcc/config/i386/t-linux64
;;
esac
