# 2015-11-02 - 1.4.0
### Summary
Added initial support for flush agent support

## 2015-10-27 - 1.3.9
### Summary
Added ability to change conf/sling.properties so that monitoring application can be used. File is currently a flat file and will need to be converted to another method.

## 2015-10-07 - 1.3.8
### Summary
Added ability to use user/pass with bundle status script used by osgi, replication, and packages.

## 2015-10-06 - 1.3.7
### Summary
Expand replication queue support
- Add additional parameters needed for replication queues
- Add support for flush agent type
- Make reverseReplication param optional
- Add uuid to package name in metadata for unique value
- Ignore additional IntelliJ types

## 2015-10-02 - 1.3.6
### Summary
- Added resources to install Required ruby and required gem

## 2015-10-01 - 1.3.5
### Summary
- Fix instance_type var name in apply_packages_defaults
- Add HTTP transport method for reverse replication polling agent
- Package installation Exec subscribe to updated .content.xml
- Copy packages to tmp file and mv to install dir to prevent timing issues w/ AEM picking up files before writing is complete
- Removed ensure_osgi as not needed
- Simplify if statement and regex on package filename check
- Add cq:template and sling:resourceType

## 2015-09-15 - 1.3.4
### Summary
- Change to ensure replication queue updates are applied successfully
- Package/hotfix applies, and replication queue configuration changes now wait for server start-up before application

## 2015-09-15 - 1.3.3
### Summary
Change to ensure OSGi resource runs after the service starts.

## 2015-09-15 - 1.3.2
### Summary
This release introduces better server start-up detection when installing OSGi configs

## 2015-09-15 - 1.3.1
### Summary
This release fixes an issue with OSGi config package updates/installs

## 2015-09-14 - 1.3.0
### Summary
This release includes a couple of new features, bug fixes and documentation updates.

#### Features
- Add ruby script `aem_bundle_status.rb` to test if insatnce is in a running state which is pushed out to `${adobe_em6::params::dir_base}/tools/aem`
- Moved download jar `${adobe_em6::params::pkg_aem_jar_name}` to `${adobe_em6::params::dir_aem_install}/${title}`
- Added Changelog

#### Bugfixes
- Fixed issue of how jar got unpack during puppet runs on packer (Part of features)

## 2015-09-09 - 1.2.2
### Summary
This release includes a resolving an issue where changing OSGi value didn't correctly update in.

#### Features

#### Bugfixes
- OSGi value never updated in zip file after initial creation.

## 2015-08-20 - 1.2.1
### Summary
This release includes an update to handle full URL in package list.

#### Features
- Updated resouses that use `adobe_em6::instance::package_list` to handle both full URL and relative file names.

#### Bugfixes

## 2015-08-20 - 1.2.0
### Summary
This release includes a resolving an issue where changing OSGi value didn't correctly update in.

#### Features
- Split out Services to own define type
- Added logic to package list to allow full URL to work  (i.e. start w/ http://)
- Changed naming of update define type to be more generic name of package
- Added ability to manage OSGi configurations for items under: `/apps/system/config`

#### Bugfixes
- Cleaned up templates used for package creations (i.e config.xml, vault.xml, etc)
- Added setting.xml to packages so warnings in logs go away
- Added Additional requires for package creation on osgi and replication queues

## 2015-08-20 - 1.1.1
### Summary
This release includes adding abililyt to push out key and trust stores.

#### Features
- Added ability to push out a trust and keystore to `${adobe_em6::params::dir_base_apps}/certs`

#### Bugfixes

## 2015-08-04 - 1.1.0
### Summary
This release includes adding abililyt to push out key and trust stores.

#### Features
- Added ability to set up replication queues via a define type
- Added a resource when set will push out a JKS
- Added checks for base directory creations
- Updating defaults, replication variables as well as adding structure to rep queues
- Added Checks using requires and befores for replicaiton queues andhotfixes to ensure get push post first initialization
- Added a delay so that the unpack has a few extra seconds to complete directory creation

#### Bugfixes

- Removed hotfix wrapper define type
- Changed how CQ mode got set
- Clean up of unused code, comments, etc
- Lint cleaning

## 2015-04-15 - 1.0.0
### Summary
This is the Initial release.

#### Features
- Creation of all directories used for logs, instances, tools, etc
- Unpacked jar to be used for an author or publish
- set up services on RHEL(Centos) systerms
- set up start, stop, services scripts

#### Bugfixes
