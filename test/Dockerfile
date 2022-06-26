FROM registry.gitlab.com/minetest/minetest/server:5.5.0

USER root
RUN apk add git &&\
    mkdir -p /root/.minetest/worlds/world/worldmods/ &&\
    cd /root/.minetest/worlds/world/worldmods/ &&\
    git clone https://github.com/minetest-mods/moreblocks.git &&\
    git clone https://github.com/BuckarooBanzay/mtzip.git &&\
    git clone https://github.com/BuckarooBanzay/mapblock_lib.git