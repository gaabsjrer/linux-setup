#!/usr/bin/env bash
# mediaplayer_animated_glyphs.sh
# Mostra artist - title + tempo da música, com ícones animados:
# - Quando tocando: anima "palitinhos" rotacionando.
# - Quando pausado: mostra pontos, simulando ausência de sinal.
#
# Usa $BLOCK_INSTANCE para playerctl (ex: instance=spotify)
# Clique esquerdo alterna play/pause.
#
# Torne executável: chmod +x ~/.config/i3/blocks/mediaplayer.sh

PLAYER=${BLOCK_INSTANCE:-spotify}
COLOR="#1DB954"

# Glyphs fornecidos (5 caracteres)
chars=( "|" "၊" "၊" "|" "|" "၊" )
N=${#chars[@]}

# Ícone quando pausado → pontos (um por cada char)
DOT_CHAR="·"
dots_icon=""
for ((i=0;i<N;i++)); do dots_icon="${dots_icon}${DOT_CHAR}"; done

# multiplicador de velocidade (quanto maior, mais rápido anima)
ANIM_SPEED=2

# clique esquerdo → play/pause
if [ -n "$BLOCK_BUTTON" ]; then
  if [ "$BLOCK_BUTTON" = "1" ]; then
    playerctl -p "$PLAYER" play-pause >/dev/null 2>&1 || true
    # para atualização imediata: descomente e adicione signal=10 no i3blocks.conf
    # pkill -RTMIN+10 i3blocks
  fi
fi

# converte segundos → MM:SS
seconds_to_mmss() {
  local s="$1"
  s=$(awk -v v="$s" 'BEGIN{printf "%.0f", v}')
  local m=$((s/60))
  local sec=$((s%60))
  printf "%02d:%02d" "$m" "$sec"
}

# pega status e tempos
status=$(playerctl -p "$PLAYER" status 2>/dev/null || true)
pos=$(playerctl -p "$PLAYER" position 2>/dev/null || true)
dur=$(playerctl -p "$PLAYER" metadata --format '{{duration}}' 2>/dev/null || true)
if [ -z "$dur" ]; then
  dur=$(playerctl -p "$PLAYER" metadata mpris:length 2>/dev/null || true)
fi

# converte duração em microssegundos, se necessário
if [ -n "$dur" ] && [[ "$dur" =~ ^[0-9]+$ ]] && [ "${#dur}" -gt 6 ]; then
  dur=$(awk -v d="$dur" 'BEGIN{printf "%.2f", d/1000000}')
fi

# fallback posição
if [ -z "$pos" ]; then
  pos=$(playerctl -p "$PLAYER" metadata --format '{{position}}' 2>/dev/null || true)
fi

# se nada rodando
if [ -z "$status" ] && [ -z "$pos" ] && [ -z "$dur" ]; then
  echo ""
  echo "—"
  echo "#888888"
  exit 0
fi

# decide ícone
if [ "$status" = "Playing" ]; then
  epoch=$(date +%s)
  offset=$(( (epoch * ANIM_SPEED) % N ))
  anim_icon=""
  for ((i=0;i<N;i++)); do
    idx=$(( (offset + i) % N ))
    anim_icon="${anim_icon}${chars[$idx]}"
  done
  icon="$anim_icon"
else
  icon="$dots_icon"
fi

# artista/título
artist=$(playerctl -p "$PLAYER" metadata artist 2>/dev/null || true)
title=$(playerctl -p "$PLAYER" metadata title 2>/dev/null || true)
if [ -z "$title" ]; then
  title=$(playerctl -p "$PLAYER" metadata xesam:title 2>/dev/null || true)
fi

if [ -n "$artist" ] && [ -n "$title" ]; then
  song="$artist - $title"
elif [ -n "$title" ]; then
  song="$title"
else
  song="Unknown"
fi


# saída para i3blocks
echo "·$icon·  $song"
echo "$pos_str"
echo "$COLOR"
exit 0
