# Shared by bin/omarchy-install-blackarch and dedsec/blackarch-essentials.sh.
# Sourced, so no shebang.

# Packages that clash with another BlackArch package inside the same
# transaction. --overwrite only helps against files already on disk; two
# packages owning one path in one transaction always fails. None of these are
# worth the whole group.
BLACKARCH_SKIP=(
  viproy-voipkit # discontinued Metasploit VoIP kit; owns /usr/share/doc/metasploit like metasploit does
)

# Install a BlackArch group. Whole group first; if pacman refuses the
# transaction, its packages go in batches, and a failing batch one by one, so a
# single conflict costs one package rather than the group.
blackarch_install_group() {
  local group=$1 ignore pkgs i p
  local -a flags=(--noconfirm --needed --overwrite '*' --ask 4)
  ignore=$(IFS=,; echo "${BLACKARCH_SKIP[*]}")

  if sudo pacman -S "${flags[@]}" --ignore "$ignore" "$group"; then
    return 0
  fi

  echo ">> $group did not install in one transaction; installing its packages in batches so one conflict does not block the rest."
  mapfile -t pkgs < <(pacman -Sgq "$group" | grep -vxF -f <(printf '%s\n' "${BLACKARCH_SKIP[@]}"))
  for ((i = 0; i < ${#pkgs[@]}; i += 25)); do
    sudo pacman -S "${flags[@]}" "${pkgs[@]:i:25}" && continue
    for p in "${pkgs[@]:i:25}"; do
      sudo pacman -S "${flags[@]}" "$p" || echo ">> skipped $p"
    done
  done
}
