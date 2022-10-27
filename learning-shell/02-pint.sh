echo "Hello World "

echo -e "\e[31mMESSAGE\e[0m"


## Color print syntax
# echo -e "\e[COLmMESSAGE\e[0m"
# Ex: echo -e "\e[31mHELLO\e[0m"
# \e[31m -> TO enable color code 31
# \e[0m  -> To disabled the enabled color we use 0
# -e     -> Enable esc seq, \e is one esc seq
# ""     -> Quotes are mandatory if we use esc s

### Colors
# RED         31
# GREEN       32
# YELLOW      33
# BLUE        34
# MAGENTA     35
# CYAN        36