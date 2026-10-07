import Image from 'next/image';

const scenes = [
  {
    name: 'Porcelain · Light',
    file: 'porcelain-light',
    description: 'Warm ivory, burgundy accents and a quiet serif clock.',
  },
  { name: 'Porcelain · Dark', file: 'porcelain-dark', description: 'A deeper palette for a softer evening screen.' },
  { name: 'Glass · Light', file: 'glass-light', description: 'Soft light and restrained native materials.' },
  { name: 'Glass · Dark', file: 'glass-dark', description: 'A dark canvas with space for the details you choose.' },
] as const;

export function NativeGallery() {
  return (
    <section className="native-gallery" aria-labelledby="native-gallery-title">
      <p className="eyebrow">FOUR WAYS TO FIND YOUR QUIET</p>
      <h2 id="native-gallery-title">See Still in its own light.</h2>
      <p className="gallery-intro">Two official themes. Light and dark. The same screen, made yours.</p>
      <div className="native-gallery-grid">
        {scenes.map((scene) => (
          <figure key={scene.file}>
            <a href={`/media/editor-${scene.file}.png`}>
              <Image
                src={`/media/editor-${scene.file}.png`}
                width={2560}
                height={1600}
                sizes="(max-width: 720px) 90vw, 45vw"
                alt={`Open full-size Still native editor in ${scene.name}, with a clock and local time widget`}
              />
            </a>
            <figcaption>
              <h3>{scene.name}</h3>
              <p>{scene.description}</p>
            </figcaption>
          </figure>
        ))}
      </div>
      <p className="gallery-provenance">
        Offscreen SwiftUI/AppKit view exports with a scratch configuration. These show native appearance, not recorded
        interaction, authentication or live integrations. Select an image to view it full-size.
      </p>
    </section>
  );
}
