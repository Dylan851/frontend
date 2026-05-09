# Optimización de modelos 3D (.glb)

Los modelos actuales pesan **~213 MB en total** (`cat.glb` 85 MB, `turtle.glb` 27 MB,
`porcupine.glb` 20 MB…). Esto es lo que hace que el visor tarde tanto. La barra de
carga en `animal_3d_viewer.dart` ya muestra progreso real, pero para que la apertura
baje a < 1 minuto en móviles hay que comprimir los GLB.

## Recomendación: compresión Draco + KTX2

Reduce los meshes con Draco (suele bajar ~80–90 % del peso geométrico) y las
texturas con KTX2 (BasisU). Necesitas Node.js ≥ 18 instalado. Después:

```bash
# 1) Instalar la herramienta
npm install -g @gltf-transform/cli

# 2) Comprimir todos los GLB del proyecto (en tu PC, no dentro de la app)
cd frontend/assets/models
mkdir -p _original
for f in *.glb; do
  mv "$f" "_original/$f"
  gltf-transform optimize "_original/$f" "$f" \
    --compress draco \
    --texture-compress webp \
    --simplify 0.7
done
```

Tras ejecutar esto:

- `cat.glb` 85 MB → ~6–10 MB.
- `turtle.glb` 27 MB → ~3–4 MB.
- Carga típica del visor: 5–15 s en un móvil de gama media.

## Compresión rápida sin Draco

Si no puedes instalar `gltf-transform`, una opción simple es bajar la resolución
de las texturas (la mayoría del peso suele estar ahí):

```bash
npx @gltf-transform/cli textures resize input.glb output.glb --width 512 --height 512
```

## Verificación

`flutter_3d_controller` (basado en `model-viewer`) soporta nativamente Draco y KTX2,
así que **no hay que tocar el código del visor** una vez los GLB están comprimidos.

La caché en disco que añade `lib/services/model_cache_service.dart` reutiliza el
modelo descomprimido entre aperturas: la primera vez verás progreso real, las
siguientes serán casi instantáneas.
