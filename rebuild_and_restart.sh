#!/bin/bash

bash_src_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
join_src_path="$( cd $bash_src_path; cd beyondz-platform && pwd )"
canvas_src_path="$( cd $bash_src_path; cd canvas-lms && pwd )"
canvasjscss_src_path="$( cd $bash_src_path; cd canvas-lms-js-css && pwd )"
nginx_dev_src_path="$( cd $bash_src_path; cd nginx-dev && pwd )"
platform_src_path="$( cd $bash_src_path; cd platform && pwd )"

dirs=($canvas_src_path $canvasjscss_src_path $platform_src_path $join_src_path $nginx_dev_src_path )

for path_dir in ${dirs[@]}; do
  echo "=================== Setting up repository at: $path_dir ==================="
  (cd $path_dir && ./setup.sh )
done
