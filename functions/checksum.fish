#
# Highlights diff output.
#
# Authors:
#   Israel Chauca <israelchauca@gmail.com>
#
function -d 'Calculate checksums for the given files.' checksum
  set -l algos $CHECKSUMALGOS
  if test -z "$algos"
    set algos md2 md4 md5 mdc2 ripemd160 sha sha1 sha224 sha256 sha384 sha512 whirlpool
  end

  for file in $argv
    if test ! -e "$file"
      echo "$file doesn't exists" 1>&2
    else
      echo "File: $file"
      for cs in $algos
        if echo a | openssl dgst -$cs 1>/dev/null 2>/dev/null
          openssl dgst -$cs "$file" \
            | sed "s/^.*= /$cs /;s/ripemd160/rmd160/"
        else
          echo "$cs is not available." | sed 's/ripemd160/rmd160(ripemd160)/' 1>&2
        end
      end
    end
  end
end

# vi: set et sw=2 ft=zsh:
