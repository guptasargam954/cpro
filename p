// ==========================
// BASIC SETUP
// ==========================
const scene = new THREE.Scene();

const camera = new THREE.PerspectiveCamera(
  70,
  window.innerWidth / window.innerHeight,
  0.1,
  1000
);
camera.position.set(0, 25, 50);

const renderer = new THREE.WebGLRenderer({ antialias: true });
renderer.setSize(window.innerWidth, window.innerHeight);
document.body.appendChild(renderer.domElement);

const controls = new THREE.OrbitControls(camera, renderer.domElement);

// ==========================
// LIGHTING
// ==========================
const light = new THREE.PointLight(0xffffff, 2);
scene.add(light);

// ==========================
// EARTH
// ==========================
const earthRadius = 6;
const earth = new THREE.Mesh(
  new THREE.SphereGeometry(earthRadius, 32, 32),
  new THREE.MeshStandardMaterial({ color: 0x0044ff })
);
scene.add(earth);

// ==========================
// USER (ON EARTH)
// ==========================
const userAngle = Math.PI / 2;
const user = new THREE.Mesh(
  new THREE.SphereGeometry(0.4, 16, 16),
  new THREE.MeshStandardMaterial({ color: 0x00ff00 })
);
user.position.set(
  Math.cos(userAngle) * earthRadius,
  0,
  Math.sin(userAngle) * earthRadius
);
scene.add(user);

// ==========================
// SATELLITES
// ==========================
const ORBIT_RADIUS = 14;
const SAT_COUNT = 4;
const satellites = [];

for (let i = 0; i < SAT_COUNT; i++) {
  const sat = {
    angle: (i * Math.PI * 2) / SAT_COUNT,
    speed: 0.01,
    mesh: new THREE.Mesh(
      new THREE.SphereGeometry(0.6, 16, 16),
      new THREE.MeshStandardMaterial({ color: 0xff0000 })
    ),
    active: true
  };
  scene.add(sat.mesh);
  satellites.push(sat);
}

// ==========================
// ORBIT PATH
// ==========================
const orbitCurve = new THREE.EllipseCurve(0, 0, ORBIT_RADIUS, ORBIT_RADIUS, 0, 2 * Math.PI);
const orbitPoints = orbitCurve.getPoints(100).map(p => new THREE.Vector3(p.x, 0, p.y));
const orbitLine = new THREE.Line(
  new THREE.BufferGeometry().setFromPoints(orbitPoints),
  new THREE.LineBasicMaterial({ color: 0xffffff })
);
scene.add(orbitLine);

// ==========================
// ORBIT LATCH STATE
// ==========================
let connectedSat = -1;
let latchTimer = 0;
let beam;

// ==========================
// FIND BEST SATELLITE
// ==========================
function findBestSatellite() {
  let best = -1;
  let minDiff = 999;

  satellites.forEach((s, i) => {
    const diff = Math.abs(s.angle - userAngle);
    if (diff < minDiff && s.active) {
      minDiff = diff;
      best = i;
    }
  });
  return best;
}

// ==========================
// DRAW BEAM
// ==========================
function drawBeam(from, to, color) {
  if (beam) scene.remove(beam);
  const points = [from.clone(), to.clone()];
  beam = new THREE.Line(
    new THREE.BufferGeometry().setFromPoints(points),
    new THREE.LineBasicMaterial({ color })
  );
  scene.add(beam);
}

// ==========================
// ANIMATION LOOP
// ==========================
function animate() {
  requestAnimationFrame(animate);

  // Earth rotation
  earth.rotation.y += 0.002;

  // Move satellites
  satellites.forEach((s, i) => {
    s.angle += s.speed;
    s.mesh.position.set(
      Math.cos(s.angle) * ORBIT_RADIUS,
      0,
      Math.sin(s.angle) * ORBIT_RADIUS
    );
  });

  // ORBIT LATCH LOGIC
  const bestSat = findBestSatellite();
  if (bestSat !== connectedSat) {
    connectedSat = bestSat;
    latchTimer = 60; // buffering time
  }

  if (connectedSat !== -1) {
    const satPos = satellites[connectedSat].mesh.position;
    const beamColor = latchTimer > 0 ? 0xffff00 : 0x00ff00;
    drawBeam(user.position, satPos, beamColor);
  }

  if (latchTimer > 0) latchTimer--;

  renderer.render(scene, camera);
}

animate();

// ==========================
// RESIZE
// ==========================
window.addEventListener('resize', () => {
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
  renderer.setSize(window.innerWidth, window.innerHeight);
});

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Orbit Latch 3D Simulation</title>
  <style>
    body { margin: 0; overflow: hidden; background: black; }
  </style>
</head>
<body>

<script src="https://cdn.jsdelivr.net/npm/three@0.152.2/build/three.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/three@0.152.2/examples/js/controls/OrbitControls.js"></script>
<script src="main.js"></script>

</body>
</html>


