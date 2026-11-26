#!/usr/bin/env bash
# Проверка, что машина подходит для разработки песочницы judge.
ok()   { printf '  \e[32m✓\e[0m %s\n' "$1"; }
bad()  { printf '  \e[31m✗\e[0m %s\n' "$1"; }

echo "Ядро: $(uname -r)"

if [ "$(stat -fc %T /sys/fs/cgroup)" = "cgroup2fs" ]; then
  ok "cgroups v2"
else
  bad "cgroups v2 не смонтированы"
fi

if [ "$(cat /proc/sys/kernel/unprivileged_userns_clone 2>/dev/null || echo 1)" = "1" ]; then
  ok "user namespaces без root разрешены"
else
  bad "user namespaces без root запрещены"
fi

p=$(cat /proc/sys/kernel/perf_event_paranoid)
if [ "$p" -le 2 ]; then ok "perf_event_paranoid = $p"; else bad "perf_event_paranoid = $p (нужно ≤ 2)"; fi

if command -v perf >/dev/null; then
  if perf stat -x, -e instructions:u true 2>&1 | grep -q '^[0-9]'; then
    ok "счётчик инструкций работает"
  else
    bad "счётчик инструкций недоступен"
  fi
else
  bad "perf не установлен (pacman -S perf)"
fi

if command -v go >/dev/null; then ok "$(go version)"; else bad "go не найден"; fi
for t in g++ python3; do
  if command -v "$t" >/dev/null; then ok "$($t --version 2>&1 | head -1)"; else bad "$t не найден"; fi
done
