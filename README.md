# Epicycles
Traces images defined by splines using the [Fourier series](https://en.wikipedia.org/wiki/Fourier_series).

<img src="demonstration.gif" alt="demonstration" width="400"/>

There are 3 versions in ServerScriptService:
1. `Real`: Uses real coefficients for the modes.
2. `Complex`: Uses complex coefficients for the modes.
3. `ComplexPhysics`: Uses complex coefficients and physically simulates the rotating rods.

[This video](https://www.youtube.com/watch?v=r6sGWTCMz2k) by 3Blue1Brown was immensely helpful in making this.

# How to use
## Rojo
Make sure you have [Rojo](https://github.com/rojo-rbx/rojo) installed.
```bash
git clone https://github.com/EthanCurtiss/Epicycles
cd Epicycles
rojo serve
```

## Non-Rojo
Download the repository and open `Epicycles.rbxl`.