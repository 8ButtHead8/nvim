package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Fprintln(os.Stderr, "usage: ascii-render <model.obj>")
		os.Exit(2)
	}
	vertices, faces, err := loadOBJ(os.Args[1], nil)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	opts := defaultOpts()
	opts.Shader = true

	in := bufio.NewScanner(os.Stdin)
	in.Buffer(make([]byte, 0, 4096), 64*1024)
	out := bufio.NewWriter(os.Stdout)
	for in.Scan() {
		fields := strings.Fields(in.Text())
		if len(fields) < 4 {
			continue
		}
		cols, err1 := strconv.Atoi(fields[0])
		rows, err2 := strconv.Atoi(fields[1])
		yaw, err3 := strconv.ParseFloat(fields[2], 64)
		pitch, err4 := strconv.ParseFloat(fields[3], 64)
		if err1 != nil || err2 != nil || err3 != nil || err4 != nil {
			continue
		}
		if cols < 1 || rows < 1 {
			continue
		}
		if len(fields) >= 5 {
			opts.Shader = fields[4] != "0"
		}
		frame := draw(vertices, faces, cols, rows, yaw, pitch, opts)
		for i := range frame {
			_, _ = out.Write(frame[i])
			_ = out.WriteByte('\n')
		}
		if err := out.Flush(); err != nil {
			return
		}
	}
}
