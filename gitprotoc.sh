#!/bin/bash

[[ -z "${NAME}" ]] && echo "set NAME env variable" && exit 1
[[ -z "${REPO}" ]] && echo "set REPO env variable" && exit 1
[[ -z "${MODULE}" ]] && echo "set MODULE env variable" && exit 1

IN="${IN:=""}"
OUT="${OUT:=api/external/${NAME}}"

tmp_dir=./tmp
repo_dir="$tmp_dir/$NAME"

in_dir="$repo_dir/$IN"

out_dir_module="$MODULE/$OUT"
abs_out_dir="$(pwd)/$OUT"

(mkdir -p $repo_dir || true) 2>/dev/null
(mkdir -p $abs_out_dir || true) 2>/dev/null

rm -rf $repo_dir
(git clone $REPO $repo_dir || true) 2>/dev/null

cd $in_dir

find_result=$(find . -iname '*.proto')

pattern="\
		protoc \
			--go_out=$abs_out_dir \
			--go_opt=module=$out_dir_module \
			--go-grpc_out=$abs_out_dir \
      --go-grpc_opt=module=$out_dir_module"

for file in $find_result; do
    dir=$(dirname $file)
    dir_without_dot=$(echo $dir | sed -e "s#./##")
    file_without_dot=$(echo $file | sed -e "s#./##")

    pattern="$pattern --go_opt=M$file_without_dot=$out_dir_module/$dir_without_dot"
    pattern="$pattern --go-grpc_opt=M$file_without_dot=$out_dir_module/$dir_without_dot"
done

pattern="$pattern $find_result && rm -rf $repo_dir"
echo $pattern | bash