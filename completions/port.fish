# MacPorts' port completion

function __fish_port_needs_action
  set cmd (commandline -opc)
  set skip_next 0
  test (count $cmd) -eq 1
  and return 0
  for item in $cmd[2..-1]
    test $skip_next -eq 1
    and set skip_next 0
    and continue
    switch $item
      case '-D' '-F'
        # These take an argument
        set skip_next 1
      case '-*' '*:*'
        # Do nothing
      case '*'
        # Action found
        echo $item
        return 1
    end
  end
  return 0
end

function __fish_port_action_is
  set cmd (__fish_port_needs_action)
  test -z "$cmd"
  and return 1
  contains -- $cmd $argv
  and return 0
  return 1
end

function __fish_complete_port_target
  for target in \
     'activate\tActivate installed\n' \
     'build\tBuild portname\n' \
     'cat\tConcats and prints Portfiles\n' \
     'cd\tChanges CWD to portdir\n' \
     'checksum\tVerify distfiles\n' \
     'clean\tRemove build files\n' \
     'configure\tRuns configure process\n' \
     'contents\tLists installed files\n' \
     'deactivate\tDeactivate port\n' \
     'dependents\tLists dependents\n' \
     'deps\tLists dependencies\n' \
     'destroot\tInstalls to temp directory\n' \
     'dir\tDisplays path to portdir\n' \
     'distcheck\tCheck distfiles\n' \
     'distfiles\tDisplay distfile info\n' \
     'dmg\tCreates DMG with package\n' \
     'echo\tList result of evaluating args\n' \
     'edit\tEdit Portfile\n' \
     'extract\tExtracts distribution files\n' \
     'fetch\tFetches distribution files\n' \
     'file\tDisplays path to Portfile\n' \
     'gohome\tLaunches the home page\n' \
     'help\tDisplays documentation\n' \
     'info\tDisplays meta-information\n' \
     'install\tInstall and activate\n' \
     'installed\tShow installed\n' \
     'lint\tVerifies Portfile\n' \
     'list\tDisplay version info\n' \
     'livecheck\tCheck for updated software\n' \
     'load\tLoad a port'"'"'s daemon\n' \
     'location\tPrint install path of port\n' \
     'log\tShows log files\n' \
     'logfile\tDisplays path of log file\n' \
     'mdmg\tCreates DMG with metapackage\n' \
     'mirror\tCreate/update a local mirror\n' \
     'mpkg\tCreates installer metapackage\n' \
     'notes\tDisplays notes\n' \
     'outdated\tLists outdated ports\n' \
     'patch\tPatches extracted distfiles\n' \
     'pkg\tCreates installer package\n' \
     'provides\tPort that provides file\n' \
     'rdependents\tRecursive dependents\n' \
     'rdeps\tRecursive dependencies\n' \
     'reload\tReload a port'"'"'s daemon\n' \
     'rev-upgrade\tLook for broken binaries\n' \
     'search\tSearch ports\n' \
     'select\tSelect default for group\n' \
     'selfupdate\tUpdates MacPorts files\n' \
     'setrequested\tMark as requested\n' \
     'setunrequested\tMark as unrequested\n' \
     'sync\tPerforms a sync operation\n' \
     'test\tTests portname\n' \
     'uninstall\tDeactivate and uninstall\n' \
     'unload\tUnload a port'"'"'s daemon\n' \
     'unsetrequested\tMark as unrequested\n' \
     'upgrade\tUpgrade ports\n' \
     'url\tDisplays URL for path of portdir\n' \
     'usage\tDisplays usage summary\n' \
     'variants\tLists variants\n' \
     'version\tDisplay MacPorts version\n' \
     'work\tDisplays path to work directory\n'
    printf $target
  end
end

function __fish_complete_port_expr
  set -l tail (commandline -tc)
  string match -q -r -- '^-' "$tail"
  and return 0
  string match -q -r -- '[()!]' "$tail"
  # Complete "port echo \(foo"
  and set -l head (string match -r -- '.*[()!]' "$tail"; true)
  and set head (string replace -r -a -- '[\\\]' '\\' "$head"; true)
  and set tail (string match -r -- '[^()!]*$' "$tail"; true)
  and set -l items (complete -C"port echo $tail")
  and for item in $items
    printf '%s%s\n' "$head" "$item"
  end
  and return 0
  # Expression words
  printf '(\tStart enclosed expression\n'
  printf ')\tEnd enclosed expression\n'
  printf '!\tLogical negation\n'
  printf 'and\tLogical conjunction\n'
  printf 'or\tLogical disjunction\n'
  printf 'not\tLogical negation\n'
  # Pseudo-portnames
  set -l pseudo "all" "current" "active" "inactive" "installed" "uninstalled" \
     "outdated" "obsolete" "requested" "unrequested" "leaves"
  for item in $pseudo
    printf '%s\tPseudo-portname\n' $item
  end
  # Pseudo-portname selectors
  set -l selectors "depof:" "rdepof:" "depends:" "rdepends:" "dependentof:" \
     "rdependentof:" "name:" "version:" "revision:" "epoch:" "variant:" \
     "variants:" "category:" "categories:" "maintainer:" "maintainers:" \
     "platform:" "platforms:" "description:" "long_description:" "homepage:" \
     "license:" "portdir:"
  for item in $selectors
    printf '%s\tSelector\n' $item
  end
  test -z "$tail"
  # Listing all ports is too slow, just stop here if empty
  and return 0
  # Globbing characters
  printf '%s*\tGlob pattern\n' "$tail"
  printf '%s?\tGlob pattern\n' "$tail"
  # Portnames
  test "$argv[1]" = "all"
  # This might take long, try to limit the output
  and set -l portexpr "*$tail*"
  or set -l portexpr $argv[1]
  set portnames (port -q echo $portexpr | string replace -r -- ' *@.*' '' \
     | string replace -a -- ' ' '')
  for item in $portnames
    printf '%s\tPortname\n' $item
  end
  return 0
end

function __fish_complete_port_help
  complete -C"port "
  printf '%s\t%s\n' macports.conf "Configuration file of the MacPorts system"
  printf '%s\t%s\n' portfile "MacPorts description file reference"
  printf '%s\t%s\n' portgroup "MacPorts PortGroup command reference"
  printf '%s\t%s\n' portstyle "Style guide for Portfiles"
  printf '%s\t%s\n' porthier "Layout of the ports-filesystems"
end

function __fish_complete_port_select
  set cmd (commandline -opc)
  set count 0
  for item in $cmd
    switch $item
      case '-*'
        test $item = "--set"
        and set is_set 1
        or set is_set = 0
        set count 0
      case '*'
        set count (math $count + 1)
        set group $item
    end
  end
  test $count -eq 0
  and for name in (port select --summary | awk 'NR>2{print $1}')
    printf '%s\tGroup name\n' $name
  end
  and return 0
  test $count -eq 1
  and test "$is_set" -eq 1
  and for name in (port -q select --list $group)
    string match -q -r -- '(active)' "$name"
    and printf '%s\tActive\n' (string match -r -- '^\s*[^ \t]+' "$name")
    or printf '%s\tInactive\n' "$name"
  end
end

complete -e -c port
complete -f -c port

# GLOBAL OPTIONS

# Output control
complete -f -c port -s v -n '__fish_port_needs_action' -d 'Verbose mode'
complete -f -c port -s d -n '__fish_port_needs_action' -d 'Debug mode, implies -v'
complete -f -c port -s q -n '__fish_port_needs_action' -d 'Quiet mode, implies -N'
complete -f -c port -s N -n '__fish_port_needs_action' -d 'Non-interactive mode'

# Installation and upgrade
complete -f -c port -s n -n '__fish_port_needs_action' -d 'Do not upgrade dependencies'
complete -f -c port -s R -n '__fish_port_needs_action' -d 'Also upgrade dependents'
complete -f -c port -s u -n '__fish_port_needs_action' -d 'Uninstall inactive ports'
complete -f -c port -s y -n '__fish_port_needs_action' -d 'Dry run'

# Sources
complete -f -c port -s s -n '__fish_port_needs_action' -d 'Build from source'
complete -f -c port -s b -n '__fish_port_needs_action' -d 'Build from binary archives'

# Cleaning
complete -f -c port -s c -n '__fish_port_needs_action' -d 'Execute clean after install'
complete -f -c port -s k -n '__fish_port_needs_action' -d 'Do not autoclean after install'

# Exit status
complete -f -c port -s p -n '__fish_port_needs_action' -d 'Do not abort on error'

# Development
complete -f -c port -s o -n '__fish_port_needs_action' -d 'Ignore that Porfile was modified'
complete -f -c port -s t -n '__fish_port_needs_action' -d 'Enable trace mode'

# Misc
complete -f -c port -s f -n '__fish_port_needs_action' -d 'Force mode, ignore state file'
complete -f -c port -s D -a '(__fish_complete_directories)' -n '__fish_port_needs_action' -d 'Specifiy portdir'
complete -f -c port -s F -a '(__fish_complete_path)' -n '__fish_port_needs_action' -d 'Process the given file'

# USER TARGETS
# Targets most commonly used by regular MacPorts users are:

complete -f -c port -n '__fish_port_needs_action' -a '(__fish_complete_port_target)' -d 'Creates DMG with metapackage'

# USER TARGET OPTIONS
# SEARCH
complete -f -c port -n "__fish_port_action_is search" -a "(__fish_complete_port_expr all)"
# Options
# Search behavior
complete -f -c port -l case-sensitive -n '__fish_port_action_is search' -d 'Do not ignore case'
complete -f -c port -l exact -n '__fish_port_action_is search' -d 'Exact match'
complete -f -c port -l glob -n '__fish_port_action_is search' -d 'Use globbing matching'
complete -f -c port -l regex -n '__fish_port_action_is search' -d 'Use Tcl regexp'
# Output behavior
complete -f -c port -l line -n '__fish_port_action_is search' -d 'Print one match per line'
# Field selection
complete -f -c port -l category -l categories -n '__fish_port_action_is search' -d 'Category'
complete -f -c port -l depends -n '__fish_port_action_is search' -d 'Dependencies'
complete -f -c port -l depends_build -n '__fish_port_action_is search' -d 'Build dependencies'
complete -f -c port -l depends_extract -n '__fish_port_action_is search' -d 'Extract dependencies'
complete -f -c port -l depends_fetch -n '__fish_port_action_is search' -d 'Fetch dependencies'
complete -f -c port -l depends_lib -n '__fish_port_action_is search' -d 'Library dependencies'
complete -f -c port -l depends_run -n '__fish_port_action_is search' -d 'Runtime dependencies'
complete -f -c port -l description -n '__fish_port_action_is search' -d 'Descriptions'
complete -f -c port -l long_description -n '__fish_port_action_is search' -d 'Long descriptions'
complete -f -c port -l homepage -n '__fish_port_action_is search' -d 'Homepage property'
complete -f -c port -l maintainer -l maintainers -n '__fish_port_action_is search' -d 'Maintainers'
complete -f -c port -l name -n '__fish_port_action_is search' -d 'Names'
complete -f -c port -l portdir -n '__fish_port_action_is search' -d 'Match path of portfile'
complete -f -c port -l variant -l variants -n '__fish_port_action_is search' -d 'Variants'

# INFO
complete -f -c port -n "__fish_port_action_is info" -a "(__fish_complete_port_expr all)"
# Options
# The following options do not select fields for the output but change how
# the information is obtained or formatted:
complete -f -c port -l index -n '__fish_port_action_is info' -d 'Use port index only'
complete -f -c port -l line -n '__fish_port_action_is info' -d 'Single line for port'
complete -f -c port -l pretty -n '__fish_port_action_is info' -d 'Human-readable output'
complete -f -c port -l categories -l category -n '__fish_port_action_is info' -d 'Categories'
complete -f -c port -l conflicts -n '__fish_port_action_is info' -d 'Conflicting ports'
complete -f -c port -l depends -n '__fish_port_action_is info' -d 'Dependencies'
complete -f -c port -l depends_fetch -n '__fish_port_action_is info' -d 'Fetch dependencies'
complete -f -c port -l depends_extract -n '__fish_port_action_is info' -d 'Extract dependencies'
complete -f -c port -l depends_build -n '__fish_port_action_is info' -d 'Build dependencies'
complete -f -c port -l depends_lib -n '__fish_port_action_is info' -d 'Library dependencies'
complete -f -c port -l depends_run -n '__fish_port_action_is info' -d 'Runtime dependencies'
complete -f -c port -l description -n '__fish_port_action_is info' -d 'Short description'
complete -f -c port -l long_description -n '__fish_port_action_is info' -d 'Long description'
complete -f -c port -l epoch -n '__fish_port_action_is info' -d 'Epoch'
complete -f -c port -l version -n '__fish_port_action_is info' -d 'Version'
complete -f -c port -l revision -n '__fish_port_action_is info' -d 'Revision'
complete -f -c port -l fullname -n '__fish_port_action_is info' -d 'Name and version'
complete -f -c port -l heading -n '__fish_port_action_is info' -d 'Name, version and categories'
complete -f -c port -l homepage -n '__fish_port_action_is info' -d 'Homepage'
complete -f -c port -l license -n '__fish_port_action_is info' -d 'License'
complete -f -c port -l maintainer -l maintainers -n '__fish_port_action_is info' -d "Maintainer(s)"
complete -f -c port -l name -n '__fish_port_action_is info' -d 'Name'
complete -f -c port -l patchfiles -n '__fish_port_action_is info' -d 'Patches'
complete -f -c port -l platform -l platforms -n '__fish_port_action_is info' -d 'Platforms'
complete -f -c port -l portdir -n '__fish_port_action_is info' -d 'Portdir'
complete -f -c port -l replaced_by -n '__fish_port_action_is info' -d 'Replacements'
complete -f -c port -l subports -n '__fish_port_action_is info' -d 'Subports'
complete -f -c port -l variants -l variant -n '__fish_port_action_is info' -d 'Variants'

# NOTES
complete -f -c port -n "__fish_port_action_is notes" -a "(__fish_complete_port_expr all)"

# VARIANTS
complete -f -c port -l index -n '__fish_port_action_is variants' -d 'Do not read the Portfile, but rely solely on the port index information'
complete -f -c port -n "__fish_port_action_is variants" -a "(__fish_complete_port_expr all)"

# DEPS
complete -f -c port -n "__fish_port_action_is deps" -a "(__fish_complete_port_expr all)"

# RDEPS
complete -f -c port -n "__fish_port_action_is rdeps" -a "(__fish_complete_port_expr all)"
# Options
complete -f -c port -l full -n '__fish_port_action_is deps rdeps' -d 'When using rdeps, display all branches'
complete -f -c port -l index -n '__fish_port_action_is deps rdeps' -d 'Use portindex info only'
complete -f -c port -l no-build -n '__fish_port_action_is deps rdeps' -d 'Exclude dependencies only required at build time'

# DEPENDENTS
complete -f -c port -n "__fish_port_action_is dependents" -a "(__fish_complete_port_expr all)"

# RDEPENDENTS
complete -f -c port -n "__fish_port_action_is rdependents" -a "(__fish_complete_port_expr all)"

# INSTALL
complete -f -c port -n "__fish_port_action_is install" -a "(__fish_complete_port_expr all)"
# Options
complete -f -c port -l no-rev-upgrade -n '__fish_port_action_is install' -d 'Do not run rev-upgrade'
complete -f -c port -l unrequested -n '__fish_port_action_is uninstall' -d 'Do not mark as requested'

# UNINSTALL
complete -f -c port -n '__fish_port_action_is uninstall' -a '(__fish_complete_port_expr installed)'
# Options
complete -f -c port -l follow-dependents -n '__fish_port_action_is uninstall' -d 'Also uninstall recursively dependents'
complete -f -c port -l follow-dependencies -n '__fish_port_action_is uninstall' -d 'Also recursively uninstall dependencies'
complete -f -c port -l no-exec -n '__fish_port_action_is uninstall' -d 'Do not execute pre- or post-uninstall'

# SELECT
# Options
complete -f -c port -l summary -n '__fish_port_action_is select' -d 'Display summary of groups'
complete -x -c port -l show -n '__fish_port_action_is select' -a "(__fish_complete_port_select)" -d 'Print current default for group'
complete -x -c port -l list -n '__fish_port_action_is select' -a "(__fish_complete_port_select)" -d 'List available choices for group'
complete -x -c port -l set -n '__fish_port_action_is select' -a '(__fish_complete_port_select)' -d 'Set default for group'
# auxiliar completion for select --set group
complete -x -c port -n '__fish_port_action_is select' -a '(__fish_complete_port_select)'
# ACTIVATE
complete -f -c port -n '__fish_port_action_is activate' -a '(__fish_complete_port_expr inactive)'
# Options
complete -f -c port -l no-exec -n '__fish_port_action_is activate' -d 'Do not execute pre- or post-uninstall'

# DEACTIVATE
complete -f -c port -n '__fish_port_action_is deactivate' -a '(__fish_complete_port_expr active)'
#Options
complete -f -c port -l no-exec -n '__fish_port_action_is deactivate' -d 'Do not execute pre- or post-uninstall'

# SETREQUESTED
complete -f -c port -n '__fish_port_action_is setrequested' -a '(__fish_complete_port_expr unrequested)'

# UNSETREQUESTED
# SETUNREQUESTED
complete -f -c port -n '__fish_port_action_is unsetrequested' -a '(__fish_complete_port_expr requested)'

# INSTALLED
complete -f -c port -n '__fish_port_action_is installed' -a '(__fish_complete_port_expr installed)'

# LOCATION
complete -f -c port -n "__fish_port_action_is location" -a "(__fish_complete_port_expr installed)"

# CONTENTS
complete -f -c port -n "__fish_port_action_is contents" -a "(__fish_complete_port_expr installed)"

# PROVIDES
complete -f -c port -n "__fish_port_action_is provides" -a '(__fish_complete_path)'

# SYNC

# OUTDATED
complete -f -c port -n '__fish_port_action_is outdated' -a '(__fish_complete_port_expr installed)'

# UPGRADE
complete -f -c port -n "__fish_port_action_is upgrade" -a "(__fish_complete_port_expr all)"

# REV-UPGRADE

# CLEAN
complete -f -c port -n "__fish_port_action_is clean" -a "(__fish_complete_port_expr all)"

# LOG
complete -f -c port -n "__fish_port_action_is log" -a "(__fish_complete_port_expr all)"

# LOGFILE
complete -f -c port -n "__fish_port_action_is logfile" -a "(__fish_complete_port_expr all)"

# ECHO
complete -f -c port -n "__fish_port_action_is echo" -a "(__fish_complete_port_expr all)"

# LIST
complete -f -c port -n "__fish_port_action_is list" -a "(__fish_complete_port_expr all)"

# MIRROR
complete -f -c port -n "__fish_port_action_is mirror" -a "(__fish_complete_port_expr all)"
# Options
complete -x -c port -l new -n '__fish_port_action_is mirror' -d 'Re-create the existing database of mirrored files'

# VERSION

# SELFUPDATE
complete -f -c port -l nosync -n '__fish_port_action_is selfupdate' -d 'Do not update the ports tree'

# LOAD
complete -f -c port -n "__fish_port_action_is load" -a "(__fish_complete_port_expr installed)"

# UNLOAD
complete -f -c port -n "__fish_port_action_is unload" -a "(__fish_complete_port_expr all)"

# RELOAD
complete -f -c port -n "__fish_port_action_is reload" -a "(__fish_complete_port_expr installed)"

# GOHOME
complete -f -c port -n "__fish_port_action_is gohome" -a "(__fish_complete_port_expr all)"

# USAGE

# HELP
complete -f -c port -n '__fish_port_action_is help' -a "(__fish_complete_port_help)"

# DEVELOPER TARGETS
# The targets that are often used by Port developers are intended to provide
# access to the different phases of a Port's build process:

# DIR
complete -f -c port -n "__fish_port_action_is dir" -a "(__fish_complete_port_expr all)"

# WORK
complete -f -c port -n "__fish_port_action_is work" -a "(__fish_complete_port_expr all)"

# CD
complete -f -c port -n "__fish_port_action_is cd" -a "(__fish_complete_port_expr all)"

# FILE
complete -f -c port -n "__fish_port_action_is file" -a "(__fish_complete_port_expr all)"

# URL
complete -f -c port -n "__fish_port_action_is url" -a "(__fish_complete_port_expr all)"

# CAT
complete -f -c port -n "__fish_port_action_is cat" -a "(__fish_complete_port_expr all)"

# EDIT
complete -f -c port -n "__fish_port_action_is edit" -a "(__fish_complete_port_expr all)"
# Options
complete -r -c port -l editor -n '__fish_port_action_is edit' -a '(__fish_complete_command)' -d 'Use specified editor'

# FETCH
complete -f -c port -n "__fish_port_action_is fetch" -a "(__fish_complete_port_expr all)"

# CHECKSUM
complete -f -c port -n "__fish_port_action_is checksum" -a "(__fish_complete_port_expr all)"

# EXTRACT
complete -f -c port -n "__fish_port_action_is extract" -a "(__fish_complete_port_expr all)"

# PATCH
complete -f -c port -n "__fish_port_action_is patch" -a "(__fish_complete_port_expr all)"

# CONFIGURE
complete -f -c port -n "__fish_port_action_is configure" -a "(__fish_complete_port_expr all)"

# BUILD
complete -f -c port -n "__fish_port_action_is build" -a "(__fish_complete_port_expr all)"

# DESTROOT
complete -f -c port -n "__fish_port_action_is destroot" -a "(__fish_complete_port_expr all)"

# TEST
complete -f -c port -n "__fish_port_action_is test" -a "(__fish_complete_port_expr all)"

# LINT
complete -f -c port -n "__fish_port_action_is lint" -a "(__fish_complete_port_expr all)"
# Options
complete -f -c port -l nitpick -n '__fish_port_action_is lint' -d 'Enables additional checks'

# DISTCHECK
complete -f -c port -n "__fish_port_action_is distcheck" -a "(__fish_complete_port_expr all)"

# DISTFILES
complete -f -c port -n "__fish_port_action_is distfiles" -a "(__fish_complete_port_expr all)"

# LIVECHECK
complete -f -c port -n "__fish_port_action_is livecheck" -a "(__fish_complete_port_expr all)"

# PACKAGING TARGETS
# There are also targets for producing installable packages of ports:

# PKG
complete -f -c port -n "__fish_port_action_is pkg" -a "(__fish_complete_port_expr all)"

# MPKG
complete -f -c port -n "__fish_port_action_is mpkg" -a "(__fish_complete_port_expr all)"

# DMG
complete -f -c port -n "__fish_port_action_is dmg" -a "(__fish_complete_port_expr all)"

# MDMG
complete -f -c port -n "__fish_port_action_is mdmg" -a "(__fish_complete_port_expr all)"
