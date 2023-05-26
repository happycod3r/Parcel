
encrypt-file "$target"
local _base="$(get-base-file-name $target)"
target="${_base}.enc"

gpg-encrypt-file "$target"
