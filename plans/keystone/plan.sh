pkg_origin=habstack
pkg_name=keystone
pkg_version=10.0.0.0b1
pkg_maintainer="Samuel Cassiba <s@cassiba.com>"
pkg_license=('apachev2')
pkg_source=nosuchfile.tar.gz
pkg_deps=(core/glibc core/python2 core/httpd core/pcre)
pkg_build_deps=(core/coreutils core/curl core/git core/cacerts core/wget core/zlib core/openssl core/bzip2 core/sqlite core/make core/gcc core/libffi)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_expose=(5000 35357)

do_verify() {
  return 0
}

do_unpack() {
  return 0
}

do_download() {
  export GIT_SSL_CAINFO="$(pkg_path_for core/cacerts)/ssl/certs/cacert.pem"
  git clone https://github.com/openstack/keystone $HAB_CACHE_SRC_PATH/keystone
  pushd $HAB_CACHE_SRC_PATH/keystone
  git checkout $pkg_version
  popd
  tar -cjf $HAB_CACHE_SRC_PATH/${pkg_name}-${pkg_version}.tar.bz2 \
      --transform "s,^\./keystone,keystone${pkg_version}," $HAB_CACHE_SRC_PATH/keystone \
      --exclude keystone/.git
  pkg_shasum=$(trim $(sha256sum $HAB_CACHE_SRC_PATH/${pkg_filename} | cut -d " " -f 1))
}

do_prepare() {
  export LD_LIBRARY_PATH="$(pkg_path_for core/libffi)/lib:$(pkg_path_for core/pcre)/lib"
  export PIP_CERT="$(pkg_path_for core/cacerts)/ssl/certs/cacert.pem"
  export PYTHONPATH="${pkg_prefix}/lib/python2.7/site-packages:$(pkg_path_for core/python2)/lib/python2.7/site-packages"
}

do_build() {
  sed -i'' 's:#.*$::g' $HAB_CACHE_SRC_PATH/${pkg_name}/requirements.txt
  python -m ensurepip
  pip install --install-option="--prefix=${pkg_prefix}" pbr
  pip install --install-option="--prefix=${pkg_prefix}" vcversioner
  pip install --install-option="--prefix=${pkg_prefix}" uwsgi
  pushd $HAB_CACHE_SRC_PATH/${pkg_name} > /dev/null
  PBR_VERSION=${version}-%{milestone} pip install --install-option="--prefix=${pkg_prefix}" -r requirements.txt
  popd > /dev/null
}

do_install() {
  pushd $HAB_CACHE_SRC_PATH/${pkg_name} > /dev/null
  $(pkg_path_for core/python2)/bin/python setup.py install --prefix="${pkg_prefix}"
  popd > /dev/null
}
