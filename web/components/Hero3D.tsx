'use client';

import { Canvas } from '@react-three/fiber';
import { Float, MeshDistortMaterial, Sphere } from '@react-three/drei';

export default function Hero3D() {
  return (
    <Canvas
      camera={{ position: [0, 0, 4], fov: 45 }}
      gl={{ alpha: true }}
      style={{ background: 'transparent' }}
    >
      <ambientLight intensity={0.8} />
      <directionalLight position={[4, 4, 4]} intensity={1.4} />
      <pointLight position={[-4, -2, 2]} intensity={0.6} color="#7248FE" />
      <Float speed={1.8} rotationIntensity={1.0} floatIntensity={1.6}>
        <Sphere args={[1.15, 80, 80]}>
          <MeshDistortMaterial
            color="#7248FE"
            attach="material"
            distort={0.32}
            speed={2.0}
            roughness={0.08}
            metalness={0.6}
            transparent
            opacity={0.92}
          />
        </Sphere>
      </Float>
      {/* Decorative small spheres */}
      <Float speed={2.4} rotationIntensity={0.8} floatIntensity={2.0}>
        <Sphere args={[0.28, 32, 32]} position={[1.9, 1.0, -0.5]}>
          <MeshDistortMaterial
            color="#7248FE"
            attach="material"
            distort={0.5}
            speed={3}
            roughness={0.1}
            metalness={0.5}
            transparent
            opacity={0.75}
          />
        </Sphere>
      </Float>
      <Float speed={1.6} rotationIntensity={1.2} floatIntensity={1.2}>
        <Sphere args={[0.18, 32, 32]} position={[-2.0, -0.8, 0.3]}>
          <MeshDistortMaterial
            color="#a78bfa"
            attach="material"
            distort={0.4}
            speed={2}
            roughness={0.15}
            metalness={0.4}
            transparent
            opacity={0.65}
          />
        </Sphere>
      </Float>
    </Canvas>
  );
}
