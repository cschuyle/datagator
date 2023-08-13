cmdExists() {
    cmdName=$1
    cmdLoc="$(type -p "$cmdName")" || [ -z $cmdLoc ]
    echo $cmdLoc
}
