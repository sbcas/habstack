pkg_origin=habstack
pkg_name=keystone
pkg_version=10.0.0.0b1
pkg_maintainer="Samuel Cassiba <s@cassiba.com>"
pkg_license=('apachev2')
pkg_source=https://github.com/openstack/${pkg_name}/archive/${pkg_version}.tar.gz
pkg_shasum=2b5beed7cd511d15346455dac2e7d3c0462955e0fa1671bc481ba44450ae72f8
pkg_deps=(core/glibc core/python2 core/httpd)
pkg_build_deps=(core/coreutils core/curl core/git core/cacerts core/wget core/zlib core/openssl core/bzip2 core/sqlite core/make core/gcc core/libffi)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_expose=(5000 35357)
pkg_svc_user="keystone"

do_prepare() {
  export LD_LIBRARY_PATH="$(pkg_path_for core/libffi)/lib"
  export PIP_CERT="$(pkg_path_for core/cacerts)/ssl/certs/cacert.pem"
}

do_build() {
  $(pkg_path_for core/python2)/bin/pip install -U pip
  PBR_VERSION=%{version}-%{milestone} $(pkg_path_for core/python2)/bin/pip install --install-option="--prefix=${pkg_prefix}" -U -r requirements.txt
}

do_install() {
  return 0
}
