package main

import (
	"math"
)

var ramp = []byte{'.', ',', ':', ';', '+', '=', '*', '#', '%', '@'}

type Opts struct {
	Shader    bool
	Cavity    int
	Tooth     int
	Fill      byte
	FitX      float64
	FitY      float64
	Aspect    float64
	Focal     float64
	Cam       float64
	Light     [3]float64
	HasCavity bool
	HasTooth  bool
}

func defaultOpts() Opts {
	return Opts{
		Fill:   '#',
		FitX:   5.4,
		FitY:   3.15,
		Aspect: 2.05,
		Focal:  4.2,
		Cam:    5.4,
		Light:  [3]float64{-0.28, 0.84, 0.46},
	}
}

func draw(vertices []Vertex, faces []Face, cols, rows int, yaw, pitch float64, opts Opts) [][]byte {
	if opts.Fill == 0 {
		opts.Fill = '#'
	}
	if opts.FitX == 0 {
		opts.FitX = 5.4
	}
	if opts.FitY == 0 {
		opts.FitY = 3.15
	}
	if opts.Aspect == 0 {
		opts.Aspect = 2.05
	}
	if opts.Focal == 0 {
		opts.Focal = 4.2
	}
	if opts.Cam == 0 {
		opts.Cam = 5.4
	}

	cyaw, syaw := math.Cos(yaw), math.Sin(yaw)
	cp, sp := math.Cos(pitch), math.Sin(pitch)
	xform := func(x, y, z float64) (float64, float64, float64) {
		x1 := x*cyaw + z*syaw
		z1 := -x*syaw + z*cyaw
		y2 := y*cp + z1*sp
		z2 := -y*sp + z1*cp
		return x1, y2, z2
	}

	var lx, ly, lz float64
	if opts.Shader {
		LX, LY, LZ := opts.Light[0], opts.Light[1], opts.Light[2]
		ll := math.Sqrt(LX*LX + LY*LY + LZ*LZ)
		if ll > 0 {
			LX, LY, LZ = LX/ll, LY/ll, LZ/ll
		}
		lx, ly, lz = xform(LX, LY, LZ)
	}

	scale := math.Min(float64(cols)/opts.FitX, float64(rows)/opts.FitY)
	project := func(x, y, z float64) (float64, float64, float64) {
		f := opts.Focal / (opts.Cam - z)
		return float64(cols)*0.5 + x*f*scale*opts.Aspect, float64(rows)*0.50 - y*f*scale, z
	}

	n := rows * cols
	zbuf := make([]float64, n)
	lit := make([]float64, n)
	mat := make([]int, n)
	has := make([]bool, n)
	for i := range zbuf {
		zbuf[i] = -1e9
	}

	for fi := range faces {
		f := faces[fi]
		if f.I < 1 || f.J < 1 || f.K < 1 || f.I > len(vertices) || f.J > len(vertices) || f.K > len(vertices) {
			continue
		}
		a := vertices[f.I-1]
		b := vertices[f.J-1]
		c := vertices[f.K-1]
		ax, ay, az := xform(a.X, a.Y, a.Z)
		bx, by, bz := xform(b.X, b.Y, b.Z)
		cx, cy, cz := xform(c.X, c.Y, c.Z)
		ux, uy, uz := bx-ax, by-ay, bz-az
		vx, vy, vz := cx-ax, cy-ay, cz-az
		nx := uy*vz - uz*vy
		ny := uz*vx - ux*vz
		nz := ux*vy - uy*vx
		nl := math.Sqrt(nx*nx + ny*ny + nz*nz)
		if nl < 1e-8 {
			continue
		}
		nx, ny, nz = nx/nl, ny/nl, nz/nl
		if nz <= 0.05 {
			continue
		}
		sx1, sy1, _ := project(ax, ay, az)
		sx2, sy2, _ := project(bx, by, bz)
		sx3, sy3, _ := project(cx, cy, cz)
		minx := max(0, int(math.Floor(min3(sx1, sx2, sx3))))
		maxx := min(cols-1, int(math.Floor(max3(sx1, sx2, sx3))))
		miny := max(0, int(math.Floor(min3(sy1, sy2, sy3))))
		maxy := min(rows-1, int(math.Floor(max3(sy1, sy2, sy3))))
		if maxx < minx || maxy < miny {
			continue
		}
		area := (sx2-sx1)*(sy3-sy1) - (sy2-sy1)*(sx3-sx1)
		if math.Abs(area) < 1e-4 {
			continue
		}
		m := f.M
		shade := 1.0
		if opts.Shader {
			diff := math.Max(0, nx*lx+ny*ly+nz*lz)
			shade = math.Pow(math.Min(1, math.Max(0, (diff-0.08)/0.82)), 1.45)
			if opts.HasCavity && m == opts.Cavity {
				shade = 0
			} else if opts.HasTooth && m == opts.Tooth {
				shade = math.Min(1, shade+0.34)
			}
		} else if opts.HasCavity && m == opts.Cavity {
			shade = 0
		}
		inv := 1 / area
		for y := miny; y <= maxy; y++ {
			py := float64(y) + 0.5
			for x := minx; x <= maxx; x++ {
				px := float64(x) + 0.5
				w1 := ((sx2-px)*(sy3-py) - (sy2-py)*(sx3-px)) * inv
				w2 := ((sx3-px)*(sy1-py) - (sy3-py)*(sx1-px)) * inv
				w3 := 1 - w1 - w2
				if w1 >= -0.001 && w2 >= -0.001 && w3 >= -0.001 {
					zz := w1*az + w2*bz + w3*cz
					idx := y*cols + x
					if zz > zbuf[idx] {
						zbuf[idx] = zz
						lit[idx] = shade
						mat[idx] = m
						has[idx] = true
					}
				}
			}
		}
	}

	lines := make([][]byte, rows)
	rampN := len(ramp)
	for y := 0; y < rows; y++ {
		row := make([]byte, cols)
		for x := 0; x < cols; x++ {
			idx := y*cols + x
			ch := byte(' ')
			if has[idx] {
				if opts.HasCavity && mat[idx] == opts.Cavity {
					ch = ' '
				} else {
					edge := x == 0 || y == 0 || x == cols-1 || y == rows-1 ||
						(x > 0 && !has[idx-1]) ||
						(x < cols-1 && !has[idx+1]) ||
						(y > 0 && !has[idx-cols]) ||
						(y < rows-1 && !has[idx+cols])
					if edge {
						ch = '@'
					} else if opts.Shader {
						q := math.Min(1, math.Max(0, lit[idx]))
						ch = ramp[int(math.Floor(q*float64(rampN-1)))]
					} else {
						ch = opts.Fill
					}
				}
			}
			row[x] = ch
		}
		lines[y] = row
	}
	return lines
}

func min3(a, b, c float64) float64 {
	return math.Min(a, math.Min(b, c))
}

func max3(a, b, c float64) float64 {
	return math.Max(a, math.Max(b, c))
}
