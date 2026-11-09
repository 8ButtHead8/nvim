package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

type Vertex struct {
	X, Y, Z float64
}

type Face struct {
	I, J, K int
	M       int
}

func loadOBJ(path string, materials map[string]int) ([]Vertex, []Face, error) {
	fh, err := os.Open(path)
	if err != nil {
		return nil, nil, fmt.Errorf("obj not found: %s", path)
	}
	defer fh.Close()

	var V []Vertex
	var F []Face
	group := "default"
	material := func() int {
		if materials == nil {
			return 1
		}
		if m, ok := materials[group]; ok {
			return m
		}
		if m, ok := materials["default"]; ok {
			return m
		}
		return 1
	}

	sc := bufio.NewScanner(fh)
	sc.Buffer(make([]byte, 0, 64*1024), 1024*1024)
	for sc.Scan() {
		line := strings.TrimSpace(sc.Text())
		if line == "" {
			continue
		}
		fields := strings.Fields(line)
		head := fields[0]
		switch head {
		case "v":
			if len(fields) < 4 {
				continue
			}
			x, err1 := strconv.ParseFloat(fields[1], 64)
			y, err2 := strconv.ParseFloat(fields[2], 64)
			z, err3 := strconv.ParseFloat(fields[3], 64)
			if err1 != nil || err2 != nil || err3 != nil {
				continue
			}
			V = append(V, Vertex{x, y, z})
		case "g", "usemtl":
			if len(fields) >= 2 {
				group = fields[1]
			}
		case "f":
			idx := make([]int, 0, len(fields)-1)
			for _, token := range fields[1:] {
				nStr := token
				if i := strings.IndexByte(token, '/'); i >= 0 {
					nStr = token[:i]
				}
				n, err := strconv.Atoi(nStr)
				if err != nil {
					continue
				}
				if n < 0 {
					n = len(V) + n + 1
				}
				idx = append(idx, n)
			}
			m := material()
			for i := 1; i < len(idx)-1; i++ {
				F = append(F, Face{idx[0], idx[i], idx[i+1], m})
			}
		}
	}
	if err := sc.Err(); err != nil {
		return nil, nil, err
	}
	if len(V) == 0 || len(F) == 0 {
		return nil, nil, fmt.Errorf("obj has no mesh: %s", path)
	}
	return V, F, nil
}
