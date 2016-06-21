pkg_origin=habstack
pkg_name=PACKAGE
pkg_version=0.1.0
pkg_maintainer="Samuel Cassiba <s@cassiba.com>"
pkg_license=(apachev2)
pkg_source=https://github.com/openstack/${pkg_name}/archive/${pkg_version}.tar.gz
pkg_shasum=sha256sum
pkg_deps=(core/glibc core/python2 core/git)
pkg_build_deps=(core/coreutils)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
