# Attach ble.sh after fzf. ~/.bashrc sources this last.
# config/bashrc already sourced ble.sh with --attach=none.
[[ $- == *i* ]] || return 0
[[ ${BLE_VERSION-} ]] && ble-attach
command -v waypoint >/dev/null && eval "$(waypoint completion --bash)"
