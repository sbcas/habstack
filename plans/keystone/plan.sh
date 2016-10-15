pkg_origin=habstack
pkg_name=keystone
pkg_version=10.0.0
pkg_maintainer="Samuel Cassiba <s@cassiba.com>"
pkg_license=('apachev2')
pkg_source=https://github.com/openstack/keystone/archive/${pkg_version}.tar.gz
pkg_shasum=9bd550d550053ba4821f8099d64097a5d374dc4c6f9d20b9c8c38ad0d9b3fb81
pkg_deps=(core/glibc core/python2 core/pcre)
pkg_build_deps=(
  core/bzip2
  core/cacerts
  core/coreutils
  core/curl
  core/gcc
  core/git
  core/libffi
  core/make
  core/mysql
  core/openssl
  core/pcre
  core/rabbitmq
  core/sqlite
  core/wget
  core/zlib
)
pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)
pkg_expose=(5001 35358)

do_prepare() {
  export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$(pkg_path_for core/libffi)/lib:$(pkg_path_for core/pcre)/lib"
  export LD_RUN_PATH="$LD_RUN_PATH:$(pkg_path_for core/pcre)/lib"
  export PIP_CERT=`python -m pip._vendor.requests.certs`
  export PYTHONPATH="${pkg_prefix}/lib/python2.7/site-packages:$(pkg_path_for core/python2)/lib/python2.7/site-packages"
  export SKIP_GIT_SDIST=1
  export PBR_VERSION="${pkg_version}"
}

do_build() {
  sed -i'' 's:#.*$::g' $HAB_CACHE_SRC_PATH/${pkg_name}-${pkg_version}/requirements.txt
  python -m ensurepip
  pip install --install-option="--prefix=${pkg_prefix}" pbr
  pip install --install-option="--prefix=${pkg_prefix}" -U setuptools
  pip install --install-option="--prefix=${pkg_prefix}" -U vcversioner
  pip install --install-option="--prefix=${pkg_prefix}" -U uwsgi
}

do_install() {
  pushd $HAB_CACHE_SRC_PATH/${pkg_name}-${pkg_version} > /dev/null
  pip install --install-option="--prefix=${pkg_prefix}" -r requirements.txt
  $(pkg_path_for core/python2)/bin/python setup.py install --prefix="${pkg_prefix}"
  for egg in repoze paste
  do touch ${pkg_prefix}/lib/python2.7/site-packages/$egg/__init__.py
  done
  popd > /dev/null
}

