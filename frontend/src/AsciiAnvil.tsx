import { useEffect, useRef } from "react";

// Outline of the anvil, copied from studyforge-mark-black.svg (viewBox 0 0 512 512).
const SVG_POINTS: [number, number][] = [
  [48, 168], [456, 168], [456, 256], [338, 256], [320, 288],
  [384, 344], [128, 344], [192, 288], [192, 256],
];
// The SVG applies skewX(-8) to the path, so the 3D shape leans the same way.
const SKEW = Math.tan((-8 * Math.PI) / 180);
const DEPTH = 120; // extrusion depth in SVG units

const COLS = 100;
const ROWS = 40;
const UNITS_PER_COL = 460 / COLS;
const TILT = 0.3; // tilt towards the viewer (radians) so the top face is visible
const SPEED = 0.6; // rotation speed (radians per second)
const SUPERSAMPLE = 2; // samples per cell edge, smooths the silhouette

// Characters from sparse to dense.
const RAMP = ".,:;-=+*#%@";

type Vec3 = [number, number, number];

// Skew, center and flip the outline to y-up coordinates around the origin.
const polygon = (() => {
  const skewed = SVG_POINTS.map(([x, y]) => [x + SKEW * y, y] as [number, number]);
  const xs = skewed.map((p) => p[0]);
  const ys = skewed.map((p) => p[1]);
  const cx = (Math.min(...xs) + Math.max(...xs)) / 2;
  const cy = (Math.min(...ys) + Math.max(...ys)) / 2;
  return skewed.map(([x, y]) => [x - cx, cy - y] as [number, number]);
})();

// Side walls: one per polygon edge, with a unit normal in the xy plane.
const walls = polygon.map((a, i) => {
  const b = polygon[(i + 1) % polygon.length];
  const ex = b[0] - a[0];
  const ey = b[1] - a[1];
  const len = Math.hypot(ex, ey);
  return { ax: a[0], ay: a[1], ex, ey, lenSq: len * len, nx: ey / len, ny: -ex / len };
});

const HALF_DEPTH = DEPTH / 2;

// Dense characters print in the text color, so their meaning flips with the theme.
// Light theme (dark text): light from above, dense = shadow, so the front face
// stays dark like the black icon and the top face is highlighted.
// Dark theme (light text): light from the front, dense = lit, so the front face
// stays bright like the inverted icon.
const THEMES = {
  light: { light: normalize([-0.3, 0.9, 0.3]), denseIsLit: false },
  dark: { light: normalize([-0.45, 0.35, 0.82]), denseIsLit: true },
};
type Theme = (typeof THEMES)[keyof typeof THEMES];

function normalize([x, y, z]: Vec3): Vec3 {
  const len = Math.hypot(x, y, z);
  return [x / len, y / len, z / len];
}

function rotateX([x, y, z]: Vec3, a: number): Vec3 {
  const c = Math.cos(a);
  const s = Math.sin(a);
  return [x, y * c - z * s, y * s + z * c];
}

function rotateY([x, y, z]: Vec3, a: number): Vec3 {
  const c = Math.cos(a);
  const s = Math.sin(a);
  return [x * c + z * s, y, -x * s + z * c];
}

// World -> object space: undo the tilt, then undo the spin.
function toObject(v: Vec3, angle: number): Vec3 {
  return rotateY(rotateX(v, -TILT), -angle);
}

function insidePolygon(x: number, y: number): boolean {
  let inside = false;
  for (let i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
    const [xi, yi] = polygon[i];
    const [xj, yj] = polygon[j];
    if (yi > y !== yj > y && x < ((xj - xi) * (y - yi)) / (yj - yi) + xi) inside = !inside;
  }
  return inside;
}

// Casts a ray against the extruded anvil and returns the character density
// (0..1) of the closest surface hit, or 0 when the ray misses.
function shade(o: Vec3, d: Vec3, light: Vec3, denseIsLit: boolean): number {
  let bestT = Infinity;
  let n: Vec3 | null = null;

  // Front and back caps.
  if (Math.abs(d[2]) > 1e-9) {
    for (const z of [HALF_DEPTH, -HALF_DEPTH]) {
      const t = (z - o[2]) / d[2];
      if (t < bestT && insidePolygon(o[0] + t * d[0], o[1] + t * d[1])) {
        bestT = t;
        n = [0, 0, Math.sign(z)];
      }
    }
  }

  // Side walls.
  for (const w of walls) {
    const denom = d[0] * w.nx + d[1] * w.ny;
    if (Math.abs(denom) < 1e-9) continue;
    const t = ((w.ax - o[0]) * w.nx + (w.ay - o[1]) * w.ny) / denom;
    if (t >= bestT) continue;
    const px = o[0] + t * d[0];
    const py = o[1] + t * d[1];
    const pz = o[2] + t * d[2];
    if (Math.abs(pz) > HALF_DEPTH) continue;
    const s = ((px - w.ax) * w.ex + (py - w.ay) * w.ey) / w.lenSq;
    if (s < 0 || s > 1) continue;
    bestT = t;
    n = [w.nx, w.ny, 0];
  }

  if (!n) return 0;
  // The first surface a ray hits always faces the viewer.
  const facing = n[0] * d[0] + n[1] * d[1] + n[2] * d[2] > 0 ? -1 : 1;
  const diffuse = Math.max(0, facing * (n[0] * light[0] + n[1] * light[1] + n[2] * light[2]));
  const lit = 0.2 + 0.8 * diffuse;
  // Keep a minimum density so no face disappears into the background.
  return 0.12 + 0.88 * (denseIsLit ? lit : 1 - lit);
}

function renderFrame(angle: number, charAspect: number, theme: Theme): string {
  const unitX = UNITS_PER_COL;
  const unitY = unitX / charAspect;
  const dir = toObject([0, 0, -1], angle);
  const axisX = toObject([1, 0, 0], angle);
  const axisY = toObject([0, 1, 0], angle);
  const eye = toObject([0, 0, 2000], angle);
  const light = toObject(theme.light, angle);

  const lines: string[] = [];
  for (let row = 0; row < ROWS; row++) {
    let line = "";
    for (let col = 0; col < COLS; col++) {
      let ink = 0;
      for (let sy = 0; sy < SUPERSAMPLE; sy++) {
        for (let sx = 0; sx < SUPERSAMPLE; sx++) {
          const x = (col + (sx + 0.5) / SUPERSAMPLE - COLS / 2) * unitX;
          const y = (ROWS / 2 - row - (sy + 0.5) / SUPERSAMPLE) * unitY;
          const origin: Vec3 = [
            eye[0] + x * axisX[0] + y * axisY[0],
            eye[1] + x * axisX[1] + y * axisY[1],
            eye[2] + x * axisX[2] + y * axisY[2],
          ];
          ink += shade(origin, dir, light, theme.denseIsLit);
        }
      }
      ink /= SUPERSAMPLE * SUPERSAMPLE;
      line += ink < 0.04 ? " " : RAMP[Math.min(RAMP.length - 1, Math.floor(ink * RAMP.length))];
    }
    lines.push(line.trimEnd());
  }
  return lines.join("\n");
}

// Width / height of one character cell, so the anvil isn't stretched.
function measureCharAspect(pre: HTMLPreElement): number {
  const probe = document.createElement("span");
  probe.textContent = "M".repeat(50);
  probe.style.visibility = "hidden";
  pre.appendChild(probe);
  const width = probe.getBoundingClientRect().width / 50;
  pre.removeChild(probe);
  const lineHeight = parseFloat(getComputedStyle(pre).lineHeight);
  return width > 0 && lineHeight > 0 ? width / lineHeight : 0.6;
}

export default function AsciiAnvil() {
  const preRef = useRef<HTMLPreElement>(null);

  useEffect(() => {
    const pre = preRef.current;
    if (!pre) return;

    const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    const darkQuery = window.matchMedia("(prefers-color-scheme: dark)");
    let theme = darkQuery.matches ? THEMES.dark : THEMES.light;
    const drawStill = () => {
      pre.textContent = renderFrame(-0.6, aspect, theme);
    };
    const onThemeChange = () => {
      theme = darkQuery.matches ? THEMES.dark : THEMES.light;
      if (reduceMotion) drawStill();
    };
    darkQuery.addEventListener("change", onThemeChange);

    let aspect = measureCharAspect(pre);
    document.fonts?.ready.then(() => {
      aspect = measureCharAspect(pre);
      if (reduceMotion) drawStill();
    });

    if (reduceMotion) {
      drawStill();
      return () => darkQuery.removeEventListener("change", onThemeChange);
    }

    let frame = 0;
    const start = performance.now();
    const tick = (now: number) => {
      pre.textContent = renderFrame(((now - start) / 1000) * SPEED, aspect, theme);
      frame = requestAnimationFrame(tick);
    };
    frame = requestAnimationFrame(tick);
    return () => {
      cancelAnimationFrame(frame);
      darkQuery.removeEventListener("change", onThemeChange);
    };
  }, []);

  return <pre ref={preRef} className="ascii-anvil" role="img" aria-label="Rotierender StudyForge-Amboss" />;
}
