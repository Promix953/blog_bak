#!/usr/bin/env bash
HOME=/root
export HOME

hexo="/usr/local/caddy/blog/node_modules/hexo/bin/hexo"
cwd="/usr/local/caddy/blog"

node ${hexo} --cwd ${cwd} clean
echo "----------"
node ${hexo} --cwd ${cwd} deploy -g
echo "----------"
node ${hexo} --cwd ${cwd} algolia
echo "----------"
echo "Finish!"