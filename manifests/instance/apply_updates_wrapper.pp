# == Define: adobe_em::instance::apply_updates_wrapper
#
#   The only reason this define type is needed is to ensure dependency.  (i.e. file are create before download)
#   Once we upgrade to 3.2+, we can use interation and remove both update define types.
#
# === Parameters:
#
# [*update_hash*]
#   The hash of packages name with an .zip extension that needs to be downloaded for installed
#
# === External Parameters
#
#
# === Examples:
#

define adobe_em6::instance::apply_updates_wrapper (
  $update_hash     = UNSET,
) {

  #notify{"in wrapper with hash value of ${update_hash} in ${title}": }
  create_resources('adobe_em6::instance::apply_updates', $update_hash)

}