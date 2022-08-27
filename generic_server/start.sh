#!/usr/bin/bash


#tmux new-session -s main -d
#tmux send-keys -t main '   cd ~/server/mine &&' C-m

java -Xshare:on -Xmx5021m -Xms5021m -XX:MaxGCPauseMillis=150 -jar server.jar nogui
