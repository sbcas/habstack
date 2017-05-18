pkg_origin=habstack
pkg_name=keystone
pkg_version=11.0.0
pkg_maintainer="Samuel Cassiba <s@cassiba.com>"
pkg_license=('apachev2')
pkg_source=https://github.com/openstack/keystone/archive/${pkg_version}.tar.gz
pkg_shasum=3cc7e03446ff2426849181b9ffdb8ea85591da62a3043abfa9ba441a77ee4651
pkg_deps=(
  core/glibc
  core/iana-etc
  core/mysql-client
  core/pcre
  python/python2
  python/appdirs
  python/packaging
  python/setuptools
  python/six
  python/uwsgi
)
pkg_build_deps=(
  core/bzip2
  core/cacerts
  core/coreutils
  core/curl
  core/gcc
  core/git
  core/iana-etc
  core/libffi
  core/make
  core/openssl
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
  export PYTHONPATH="${pkg_prefix}/lib/python2.7/site-packages:$(pkg_path_for python/python2)/lib/python2.7/site-packages"
  export SKIP_GIT_SDIST=1
  export PBR_VERSION="${pkg_version}"
  # create symlinks for /etc/services and /etc/protocols
  if [[ ! -f /etc/services ]]; then
    cp -v $(pkg_path_for iana-etc)/etc/services /etc/services
  fi
  if [[ ! -f /etc/protocols ]]; then
    cp -v $(pkg_path_for iana-etc)/etc/protocols /etc/protocols
  fi
}

do_build() {
  sed -i'' 's:#.*$::g' $HAB_CACHE_SRC_PATH/${pkg_name}-${pkg_version}/requirements.txt
  wget -O $HAB_CACHE_SRC_PATH/get-pip.py https://bootstrap.pypa.io/get-pip.py
  python $HAB_CACHE_SRC_PATH/get-pip.py
  python -m ensurepip
  pip install --install-option="--prefix=${pkg_prefix}" -U pbr
  pip install --install-option="--prefix=${pkg_prefix}" -U vcversioner
}

do_install() {
  pushd $HAB_CACHE_SRC_PATH/${pkg_name}-${pkg_version} > /dev/null
  pip install --install-option="--prefix=${pkg_prefix}" -r requirements.txt
  $(pkg_path_for python/python2)/bin/python setup.py install --prefix="${pkg_prefix}"
  for egg in repoze paste
  do touch ${pkg_prefix}/lib/python2.7/site-packages/$egg/__init__.py
  done
  popd > /dev/null
}

