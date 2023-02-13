FROM openjdk:17-buster

WORKDIR /app

RUN apt-get update

RUN apt-get install -y tmux

CMD tmux new-session -s main -d 'sh start.sh; exec bash' && cat
