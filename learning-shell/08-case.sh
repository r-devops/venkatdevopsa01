# Syntax
# case $var in
#  pattern1) commands ;;
#  pattern2) commands ;;
# esac


system=$1

case $system in
  Linux)
    echo Linux System
    ;;
  Unix)
    echo Unix System
    ;;
  *)
    echo Input Missing / Unknown System
esac
