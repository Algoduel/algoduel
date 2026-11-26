# AlgoDuel

Игровая платформа для соревновательного решения алгоритмических задач с оценкой
эффективности решений. Курсовой проект, ПИ ВШЭ, 2026/27.
Руководитель: Щагин Дмитрий Владимирович.

Это общий репозиторий. Код частей лежит в отдельных репозиториях и подключен
сюда как git submodule'ы:

| Папка | Репозиторий | Ответственный |
| --- | --- | --- |
| `judge/` | [algoduel-judge](https://github.com/algoduel/algoduel-judge) | Геннадий Тепляков |
| `backend/` | [algoduel-backend](https://github.com/algoduel/algoduel-backend) | Артём Штанько |
| `api/` | [algoduel-api](https://github.com/algoduel/algoduel-api) | оба (контракт бэкенд ↔ judge) |

Прямо здесь лежат общие вещи: `problems/` (задачи), `deploy/` (docker compose),
`frontend/`, `docs/`, `scripts/`.

## Начало работы

```bash
git clone --recurse-submodules git@github.com:algoduel/algoduel.git
cd algoduel
git config submodule.recurse true          # pull и switch будут обновлять submodule'ы
git config push.recurseSubmodules check    # не даст запушить ссылку на незапушенный коммит
git submodule foreach 'git switch main'    # выйти из detached HEAD во всех частях
make test
```

Нужны Linux, Go 1.22+, g++, Python 3, Docker. Проверка ядра для песочницы: `make check-env`.

## Как работать

**Пишем код в своей части** как в обычном репозитории:

```bash
cd judge                 # или backend
git switch main          # если вдруг detached HEAD
git switch -c sandbox/cgroups
# ...код...
git commit -am "sandbox: memory limit via cgroups"
git push -u origin sandbox/cgroups   # дальше pull request в algoduel-judge
```

**Фиксируем совместимые версии в общем репозитории.** Когда в частях смержили
что-то важное и всё вместе работает:

```bash
cd ~/algoduel
make update              # подтянуть свежие main всех частей
make test
git add judge backend api
git commit -m "Bump judge and backend"
git push
```

**Получаем изменения напарника:**

```bash
git pull                 # с submodule.recurse=true подтянет и части
```

## Подводные камни

- **Detached HEAD.** После клонирования или `git pull` submodule стоит на коммите,
  а не на ветке. Перед работой: `git switch main`.
- **Сначала push части, потом родителя.** Иначе родитель ссылается на коммит,
  которого нет на GitHub. Настройка `push.recurseSubmodules check` от этого защищает.
- **Родитель не обновляется сам.** Новый коммит в `judge` не попадёт в `algoduel`,
  пока кто-то не сделает `git add judge` и коммит здесь.
- **`go.work`** подставляет локальные папки `api/`, `judge/`, `backend/` друг другу,
  поэтому изменения в контракте сразу видны обеим частям без публикации версий.

## Команды

| Команда | Что делает |
| --- | --- |
| `make test` / `make vet` | тесты и проверки по всем частям |
| `make update` | подтянуть свежие `main` всех частей |
| `make status` | на каких коммитах стоят части |
| `make up` / `make down` | PostgreSQL и Redis |
| `make check-env` | проверка ядра: cgroups v2, namespaces, perf |
| `make judge-demo` | прогнать эталон задачи через песочницу |
