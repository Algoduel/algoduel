// Генератор тестов для sort-numbers.
//
//	go run ./problems/sort-numbers/gen -n 65536 -seed 1 -mode random
package main

import (
	"bufio"
	"flag"
	"log"
	"math/rand"
	"os"
	"sort"
	"strconv"
)

func main() {
	n := flag.Int("n", 10, "количество чисел")
	seed := flag.Int64("seed", 1, "зерно генератора")
	mode := flag.String("mode", "random", "random | sorted | reversed | equal")
	flag.Parse()

	r := rand.New(rand.NewSource(*seed))
	a := make([]int64, *n)
	for i := range a {
		a[i] = r.Int63n(2_000_000_001) - 1_000_000_000
	}
	switch *mode {
	case "random":
	case "sorted":
		sort.Slice(a, func(i, j int) bool { return a[i] < a[j] })
	case "reversed":
		sort.Slice(a, func(i, j int) bool { return a[i] > a[j] })
	case "equal":
		for i := range a {
			a[i] = 42
		}
	default:
		log.Fatalf("unknown mode %q", *mode)
	}

	w := bufio.NewWriter(os.Stdout)
	defer w.Flush()
	w.WriteString(strconv.Itoa(*n) + "\n")
	for i, x := range a {
		if i > 0 {
			w.WriteByte(' ')
		}
		w.WriteString(strconv.FormatInt(x, 10))
	}
	w.WriteByte('\n')
}
