# Author: DethByte64

stop() {
#  stty echo
  clear
  echo -en "\e[?25h"
  exit 0
}

trap stop SIGINT

del_char() {
  echo -en "\b "
}

banner() {
echo "hello"
}


# This function is a WIP, trying to refactor, ya know DRY
req_move() {
#  if [ "$lock1" = "false" ]; then
#    lock1=true
    curPos="$1"
    fromPos="$2"
    toPos="$3"
    a_code="$4" # echo before moving
    b_code="$5" # echo after moving to "from" coordinates
    c_code="$6" # echo after delay
    d_code="$7"
    delay="$8"
    cur_y="$(echo "$curPos" | cut -d' ' -f1)"
    cur_x="$(echo "$curPos" | cut -d' ' -f2)"
    fr_y="$(echo "$fromPos" | cut -d' ' -f1)"
    fr_x="$(echo "$fromPos" | cut -d' ' -f2)"
    to_y="$(echo "$toPos" | cut -d' ' -f1)"
    to_x="$(echo "$toPos" | cut -d' ' -f2)"
    echo -en "$a_code"
    bashlib.cursor.setPos "$fr_y" "$fr_x"
    echo -en "$b_code"
    sleep "$delay"
    echo -en "$c_code"
    bashlib.cursor.setPos "$to_y" "$to_x"
    echo -en "$d_code"
    bashlib.cursor.setPos "$cur_y" "$cur_x"
    curPos=""
    fromPos=""
    toPos=""
    a_code=""
    b_code=""
    c_code=""
    cur_y=""
    cur_x=""
    fr_y=""
    fr_x=""
    to_y=""
    to_x=""
 #   lock1="false"
 # fi
}

fire_north() {
  fire_y="$p1_y"
  fire_x="$p1_x"
  until [ "$fire_y" = 0 ]; do
    req_move "$p1_y $p1_x" "$fire_y $fire_x" "$((fire_y - 1)) $((fire_x - 1))" "" "*" "\b " "" ".05"
    # Works using the above function. not as pretty
    fire_y="$((fire_y - 1))"
    sleep .05
  done
}

fire_south() {
  fire_y="$p1_y"
  fire_x="$p1_x"
  until [ "$fire_y" = "$end_y" ]; do
    fire_y="$((fire_y + 1))"
    bashlib.cursor.setPos "$fire_y" "$fire_x"
    echo -n "*"
    sleep .1
    del_char
  done
bashlib.cursor.setPos "$p1_y" "$p1_x"
}

fire_east() {
  fire_y="$p1_y"
  fire_x="$p1_x"
  until [ "$fire_x" = "$((end_x - 1))" ]; do # fixes a bug
    fire_x="$((fire_x + 1))"
    bashlib.cursor.setPos "$fire_y" "$fire_x"
    echo -n "*"
    sleep .05
    del_char
  done
bashlib.cursor.setPos "$p1_y" "$p1_x"
}

fire_west() {
  fire_y="$p1_y"
  fire_x="$((p1_x - 1))"
  until [ "$fire_x" = 0 ]; do
    fire_x="$((fire_x - 1))"
    bashlib.cursor.setPos "$fire_y" "$fire_x"
    echo -n "*"
    sleep .05
    del_char
  done
bashlib.cursor.setPos "$p1_y" "$p1_x"
}

fire() {
  case "$1" in
    "N")
       fire_north
      ;;
    "S")
       fire_south
      ;;
    "E")
       fire_east
      ;;
    "W")
       fire_west
      ;;
  esac
}

# This function gets the input and checks it against a few chars. planning on making calls to the "req_move" function. DRY
handle_keys() {
  case "$1" in
    A|"w")
      del_char
      bashlib.cursor.up
      echo -en "\b^"
      p1_y=$((p1_y - 1))
      face="N"
      ;;
    B|"s")
      del_char
      bashlib.cursor.down
      echo -en "\bv"
      p1_y=$((p1_y + 1))
      face="S"
      ;;
    C|"d")
      del_char
      bashlib.cursor.right
      echo -en "\b>"
      p1_x=$((p1_x + 1))
      face="E"
      ;;
    D|"a")
      del_char
      bashlib.cursor.left
      echo -en "\b<"
      p1_x=$((p1_x - 1))
      face="W"
      ;;
    '')
      lock="true"
      fire "$face"
      lock="false"
      ;;
    "k")
      echo -n "$p1_y $p1_x"
      ;;
  esac
}

# these are bot functions, they are a work in progress and are not executed.

bot_move_y() {
  if [ "$bot_face_y" = "S" ]; then
    bot_y="$((bot_y + 1))"
  fi
  if [ "$bot_face_y" = "N" ]; then
    bot_y="$((bot_y - 1))"
  fi
}

bot_move_x() {
  if [ "$bot_face_x" = "E" ]; then
    bot_x="$((bot_x + 1))"
  fi
  if [ "$bot_face_x" = "W" ]; then
    bot_x="$((bot_x - 1))"
  fi
}

bot_ai() {
  if [ "$bot_y" < "$p1_y" ]; then
    diff_y="$((p1_y - bot_y))"
    bot_face_y="S"
  elif [ "$bot_y" > "$p1_y" ]; then
    diff_y="$((bot_y - p1_y))"
    bot_face_y="N"
  else
    diff_y="0"
  fi
  if [ "$bot_x" < "$p1_x" ]; then
    diff_x="$((p1_x - bot_x))"
    bot_face_x="E"
  elif [ "$bot_x" > "$p1_x" ]; then
    diff_x="$((bot_x - p1_x))"
    bot_face_x="W"
  else
    diff_x="0"
  fi
  if [ "$diff_y" < "$diff_x" ]; then
    bot_move_y
  elif [ "$diff_y" > "$diff_x" ]; then
    bot_move_x
  else
    flip="$(bashlib.rand.range 1 2)"
    if [ "$flip" = "1" ]; then
      bot_move_y
    else
      bot_move_x
    fi
  fi
}



# This is where the game starts it sets
#variables important to the game, does a
#terminal trick, and creates a loop that
#gets user input and then passes it along to the "handle_keys" function.
game_init() {
  clear
#  stty -echo
  p1_y=0  #line
  p1_x=0  #column
  end_y="$LINES"
  end_x="$COLUMNS"
  blue='\e[92;1m'
  echo -en "\e[?25l"
  if [ "$p" = "1" ]; then
    bot_y="$(bashlib.rand.range 1 "$end_y")"
    bot_x="$(bashlib.rand.range 1 "$end_x")"
  fi
  while read -s -n1 -r line; do
    if [ "$lock" = "false" ]; then
      lock="true"
      handle_keys "$line"
#      bot_ai
#WIP
      lock="false"
    fi
  done
}

#this is the menu it currently gets the
#amount of players as I am eventually
#making this a multiplayer game with the
#help of netcat and my wonderful BashLib.
#i intend on adding more.
main_menu() {
  echo -n "How Many Players?: "
  read -r -s -n1 players
  case "$players" in
    "1")
      p=1
      ;;
    "2")
      p=2
      ;;
    *)
      p=1
      ;;
  esac
  game_init
}

# start of execution
. bashlib.sh
lock="false"
main_menu
