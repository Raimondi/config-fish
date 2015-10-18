# Source this file in your config-fish to setup a chpwd function that will
# maintain some helpful repo-related aliases for you.  These aliases
# change based on what kind of repo you've cd'ed into.
#
# The aliases default to the following 2-letter commands (though you
# can configure them down in the repo_fish_setup function):
#
# ad     Repo's "add" command.
#
# ci     Does a checkin, defaulting to the committing of all changed
#        files unless an arg beyond "-m msg" is specified (e.g. one or
#        more filenames).  For git, you can also specify a trailing -i
#        if you want to turn off the -a option without specifying any
#        files (and thus just commit things that have been explicitly
#        added).
#
# co     Does a checkout, for things like changing branches or updating
#        files to different versions.
#
# di     Repo's "diff" command.  Auto-pages.
#
# lo     Repo's "log" command.  Auto-pages.  The -v option can be used
#        to request that file names be included in the commit output,
#        even in git.  The -s option can be used in a git-svn repo to
#        ask for the "git svn log" output.
#
# st     Repo's "status" command.  For cvs, this uses a helper script
#        (cvs-status) to output status ala svn, with the default being
#        local-only output, and remote-status added in via -u (though
#        local cvs status does not include info on unknown files).
#
# pu     Push the currently-checked-in changes.  This has no effect in
#        svn or cvs.  For git, it will do the right thing in a git-svn
#        checkout, as well as a custom cvs-modifying git checkout (see
#        the helper-script git-cvs-push).
#
# up     Update from the saved remote repo location.  For git, this
#        defaults to doing a "git pull --rebase" for a normal repo, or
#        a "git svn rebase" for a git-svn repo.
#
# The commands that "auto-page" pipe their output through "less -F" so
# that you get a pager if the output is long, and normal output if it is
# not.  It helps to have a modern version of less to avoid jumping down
# to the bottom of the screen when that is not needed.  Note that git
# auto-pages by default, so we leave it alone (which ensures auto-color
# is unaffected).
#
# The aliases that use helper functions get a compdef setting that makes
# them share their repo's command-line completion.
#
# See: http://opencoder.net/repos/ for more info and the helper scripts.

# Ported to fish by Israel Chauca <israelchauca@gmail.com> from the zsh
# script written by Wayne Davison <wayne@opencoder.net>
# Freely redistributable.

if not status --is-interactive
  exit
end
function repos_fish_setup -d "Set fish_repos abbreviations up."
  # This section defines the alias names that will be created.  If  you
  # want to use a different set of alias than the default 2-letter ones
  # Wayne created, change the name after the equal (e.g. "set -l ad add").
  set -l ad ad
  set -l ci ci
  set -l co co
  #set -l di di
  set -l di pa
  set -l lo lo
  set -l st st
  set -l pu pu
  set -l up up
  set -l ss ss

  set -l prior_inode
  set -l check_dir .
  set -l inode (stat -c \%i $check_dir)

  for name in ad ci co di lo pu st up ss
    abbr -a $$name='repos_fish_not_in_a_VCS_directory'
  end
  set -g REPOS_FISH_TYPE none

  while test "$inode" != "$prior_inode"
    # You can also tweak the aliases below to have the options you like best.
    # Finally, you may wish to tweak things like my change to make "ci" default
    # to committing with --all.  To do that, either stop using git4commit (change
    # that reference to just "git") or tweak the git4commit function (above).

    if test -d $check_dir/.git
      abbr -a $ad='git add'
      abbr -a $ci='git commit'
      #abbr -a $ci='git4commit commit'
      abbr -a $co='git checkout'
      abbr -a $di='git diff --patience --word-diff=color --no-ext-diff -w'
      abbr -a $lo='git4log log --patience -cc'
      abbr -a $st='git status'
      if test -f $check_dir/.git/svn/.metadata
        abbr -a $pu='git svn dcommit --rmdir'
        abbr -a $up='git svn rebase'
        set -g REPOS_FISH_TYPE git-svn
      else if test -d $check_dir/.git/cvs
        abbr -a $pu="git-cvs-push '$check_dir'"
        abbr -a $up='git pull --rebase --stat'
        set -g REPOS_FISH_TYPE git-cvs
      else
        abbr -a $pu='git push'
        abbr -a $up='git pull --rebase --stat'
        set -g REPOS_FISH_TYPE git
      end
      abbr -a $ss='git stash'
      return
    end
    if test -d $check_dir/.hg
      abbr -a $ad='hg add'
      abbr -a $ci='hg ci'
      abbr -a $co='hg update'
      abbr -a $di='paged_hg diff'
      abbr -a $lo='paged_hg log'
      abbr -a $pu='hg push'
      abbr -a $st='hg st'
      abbr -a $up='hg pull -u'
      abbr -a $ss='echo "This is not a Git repository!"'
      set -g REPOS_FISH_TYPE hg
      return
    end
    if test -d $check_dir/.bzr
      abbr -a $ad='bzr add'
      abbr -a $ci='bzr commit'
      abbr -a $co='bzr checkout'
      abbr -a $di='paged_bzr diff'
      abbr -a $lo='paged_bzr log'
      abbr -a $pu='bzr push'
      abbr -a $st='bzr st'
      abbr -a $up='bzr pull'
      abbr -a $ss='echo "This is not a Git repository!"'
      set -g REPOS_FISH_TYPE bzr
      return
    end
    if test -z "$prior_inode"
      # Only check for SVN and CVS in current dir.
      if test -d $check_dir/.svn
        abbr -a $ad='svn add'
        abbr -a $ci='svn ci'
        abbr -a $co='svn update'
        abbr -a $di='paged_svn diff --no-diff-deleted'
        abbr -a $lo='paged_svn log'
        abbr -a $pu='echo "This is an svn repository!"'
        abbr -a $st='svn st'
        abbr -a $up='svn up'
        abbr -a $ss='echo "This is not a Git repository!"'
        set -g REPOS_FISH_TYPE svn
        return
      end
      if test -d $check_dir/CVS
        abbr -a $ad='cvs add'
        abbr -a $ci='cvs ci'
        abbr -a $co='cvs update'
        abbr -a $di='paged_cvs -q diff -up'
        abbr -a $lo='paged_cvs log'
        abbr -a $pu='echo "This is a cvs repository!"'
        abbr -a $st='cvs-status'
        abbr -a $up='cvs -q up -d -P'
        abbr -a $ss='echo "This is not a Git repository!"'
        set -g REPOS_FISH_TYPE cvs
        return
      end
    end
    set prior_inode $inode
    set check_dir ../$check_dir
    set inode (stat -c \%i $check_dir)
  end
  return 0
end

for cmd in cvs svn bzr hg
  eval "
  function paged_$cmd --wraps=$cmd -d 'Page the output of $cmd if it\'s more that one screen'
    $cmd \$argv | less -F -X
  end"
end

function -d "Not in a VCS directory" repos_fish_not_in_a_VCS_directory
  echo 'repos: not in a VCS directory' >&2
end

function git4commit --wraps=git -d 'Changes the default behavior of a git commit to assume the --all option unless it is overridden by explicit filenames or other options.  To override this (committing just queued changes), this supports a trailing -i option (-i normally takes an arg, but has the new meaning if last).'
  set -l arg
  set -l args commit
  set -e argv[1] # discard "commit" arg.
  set -l argc (count $argv)
  if test $argc -eq 0 -o \($argc -eq 2 -a "$argv[1]" = "-m"\)
    # This makes -a the default with no args or just a -m arg.
    set args $args -a
  end
  set args $args $argv
    # This removes a trailing -i option (used to override the default -a
    # behavior and just commit what has been manually added).
    if test "$args[-1]" = "-i"
      set -e args[-1]
    end
    git $args
end

function git4log --wraps=git -d 'Adds 2 new log options for git repos: -v -> --name-stats and -s -> run "git svn log" instead of "git log".'
  set -l args log
  set -e argv[1]
  for arg in $argv
    if test \("$arg" = "-s"\) -a \("$REPOS_FISH_GIT_TYPE" = "svn"\)
      set args svn $args
      continue
    end
    if test \("$arg" = "-v"\) -a \("$args[1]" = "log"\)
      set arg --name-status
    end
    set args $args $arg
  end
  git $args
end

function repos_fish_postexec -e fish_postexec -d 'Check if repo has been "init"ed.'
  if test $REPOS_FISH_TYPE = 'none'
    switch "$argv[1]"
      case '*git*' '*hg*' '*bzr*' '*svn*' '*cvs*'
        repos_fish_setup
    end
  end
end

function repos_fish_pwd -v PWD -d 'Change of directory, check if a VCS repo.'
  set -l inode (stat -c \%i .)
  if test "$REPOS_FISH_INODE" != "$inode"
    repos_fish_setup
    set -g REPOS_FISH_INODE $inode
  end
end

# Run it once.
repos_fish_setup

# vim: et sw=2
