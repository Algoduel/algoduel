.PHONY: test vet build up down check-env judge-demo update status

# Тесты и проверки сразу по всем частям (go.work объединяет модули)
test:
	go test ./... ./api/... ./judge/... ./backend/...

vet:
	go vet ./... ./api/... ./judge/... ./backend/...

build:
	go build -o bin/ ./judge/cmd/... ./backend/cmd/...

# Подтянуть свежие main всех submodule'ов (после этого не забудьте закоммитить родителя)
update:
	git submodule update --remote --merge

# Показать, на каких коммитах стоят submodule'ы
status:
	git submodule status

# PostgreSQL и Redis для разработки
up:
	docker compose -f deploy/docker-compose.yml up -d

down:
	docker compose -f deploy/docker-compose.yml down

# Проверить, что ядро даёт всё нужное для песочницы
check-env:
	./scripts/check-env.sh

# Скомпилировать эталон задачи и прогнать его через judge на тесте 2^16
judge-demo:
	mkdir -p tmp
	g++ -O2 -std=c++17 -o tmp/ref problems/sort-numbers/solutions/ref.cpp
	go run ./problems/sort-numbers/gen -n 65536 -seed 1 -mode random > tmp/input.txt
	go run ./judge/cmd/judge -input tmp/input.txt -- tmp/ref
