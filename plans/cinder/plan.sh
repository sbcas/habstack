pkg_origin=habstack
pkg_name=cinder
pkg_version=10.0.0
pkg_maintainer="Samuel Cassiba <s@cassiba.com>"
pkg_license=('apachev2')
pkg_source=https://github.com/openstack/${pkg_name}/archive/${pkg_version}.tar.gz
pkg_shasum=8778ade11bef0dc3344959d1615fdc0f5a488316feb217516124ac23716f9a7c
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

do_prepare() {
  export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$(pkg_path_for core/libffi)/lib:$(pkg_path_for core/pcre)/lib"
  export CFLAGS="$CFLAGS:-I$(pkg_path_for core/libxml2)/include"
  export LD_RUN_PATH="$LD_RUN_PATH:$(pkg_path_for core/pcre)/lib"
  export PIP_CERT="$(pkg_path_for core/cacerts)/ssl/certs/cacert.pem"
  export PYTHONPATH="${pkg_prefix}/lib/python2.7/site-packages:$(pkg_path_for core/python2)/lib/python2.7/site-packages"
}

do_build() {
  sed -i'' 's:#.*$::g' $HAB_CACHE_SRC_PATH/${pkg_name}-${pkg_version}/requirements.txt
  wget -O $HAB_CACHE_SRC_PATH/get-pip.py https://bootstrap.pypa.io/get-pip.py
  python $HAB_CACHE_SRC_PATH/get-pip.py
  python -m ensurepip
  pip install --install-option="--prefix=${pkg_prefix}" -U six packaging appdirs
  pip install --install-option="--prefix=${pkg_prefix}" -U pbr
  pip install --install-option="--prefix=${pkg_prefix}" -U vcversioner
  pushd $HAB_CACHE_SRC_PATH/${pkg_name}-${pkg_version} > /dev/null
  PBR_VERSION=%{version}-%{milestone} pip install --install-option="--prefix=${pkg_prefix}" -U -r requirements.txt
  popd > /dev/null
}

do_install() {
  pushd $HAB_CACHE_SRC_PATH/${pkg_name}-${pkg_version} > /dev/null
  $(pkg_path_for core/python2)/bin/python setup.py install --prefix="${pkg_prefix}"
  popd > /dev/null
}
