pkg_origin=habstack
pkg_name=cinder
pkg_version=9.0.0.0b2
pkg_maintainer="Samuel Cassiba <s@cassiba.com>"
pkg_license=('apachev2')
pkg_source=nosuchfile.tar.gz
pkg_deps=(core/glibc core/python2 core/pcre)
pkg_build_deps=(
  core/bzip2
  core/cacerts
  core/coreutils
  core/curl
  core/gcc
  core/git
  core/libffi
  core/libxml2
  core/libxslt
  core/make
  core/openssl
  core/pcre
  core/sqlite
  core/wget
  core/zlib
)
pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)
pkg_expose=(8776)

do_verify() {
  return 0
}

do_unpack() {
  return 0
}

do_download() {
  export GIT_SSL_CAINFO="$(pkg_path_for core/cacerts)/ssl/certs/cacert.pem"
  git clone https://github.com/openstack/cinder $HAB_CACHE_SRC_PATH/cinder
  pushd $HAB_CACHE_SRC_PATH/cinder
  git checkout $pkg_version
  popd
  tar -cjf $HAB_CACHE_SRC_PATH/${pkg_name}-${pkg_version}.tar.bz2 \
      --transform "s,^\./cinder,cinder${pkg_version}," $HAB_CACHE_SRC_PATH/cinder \
      --exclude cinder/.git
  pkg_shasum=$(trim $(sha256sum $HAB_CACHE_SRC_PATH/${pkg_filename} | cut -d " " -f 1))
}

do_prepare() {
  export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$(pkg_path_for core/libffi)/lib:$(pkg_path_for core/pcre)/lib"
  export CFLAGS="$CFLAGS:-I$(pkg_path_for core/libxml2)/include"
  export LD_RUN_PATH="$LD_RUN_PATH:$(pkg_path_for core/pcre)/lib"
  export PIP_CERT="$(pkg_path_for core/cacerts)/ssl/certs/cacert.pem"
  export PYTHONPATH="${pkg_prefix}/lib/python2.7/site-packages:$(pkg_path_for core/python2)/lib/python2.7/site-packages"
}

do_build() {
  sed -i'' 's:#.*$::g' $HAB_CACHE_SRC_PATH/${pkg_name}/requirements.txt
  python -m ensurepip
  pip install --install-option="--prefix=${pkg_prefix}" pbr
  pip install --install-option="--prefix=${pkg_prefix}" vcversioner
  pushd $HAB_CACHE_SRC_PATH/${pkg_name} > /dev/null
  PBR_VERSION=${version}-%{milestone} pip install --install-option="--prefix=${pkg_prefix}" -r requirements.txt
  popd > /dev/null
}

do_install() {
  pushd $HAB_CACHE_SRC_PATH/${pkg_name} > /dev/null
  $(pkg_path_for core/python2)/bin/python setup.py install --prefix="${pkg_prefix}"
  popd > /dev/null
}
