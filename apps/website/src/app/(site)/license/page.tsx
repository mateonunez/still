import { readFile } from 'node:fs/promises';
import { join } from 'node:path';
import Link from 'next/link';
import { pageMetadata } from '@/content/site';

export const metadata = pageMetadata(
  'MIT license and font notices',
  'Still uses the MIT license for original code and documentation. Instrument Serif and Inter retain their SIL Open Font Licenses. Source is public on GitHub.',
  '/license',
);

export default async function LicensePage() {
  const license = await readFile(join(process.cwd(), 'public/license.txt'), 'utf8');
  return (
    <main id="main" className="article license-page">
      <p className="eyebrow">LICENSE & ATTRIBUTION</p>
      <h1>A small app. A permissive license.</h1>
      <p className="article-lead">Still’s original code and documentation are licensed under MIT.</p>
      <p>
        The source repository is public on GitHub. Experimental previews are available; the MIT license does not certify
        compatibility, notarization or package publication.
      </p>
      <section>
        <h2>MIT License</h2>
        <pre className="license-text">{license}</pre>
        <a className="text-link" href="/license.txt" download>
          Download the license text ↗
        </a>
      </section>
      <section>
        <h2>The typefaces keep their own licenses.</h2>
        <p>
          Instrument Serif and Inter are served locally and retain their original SIL Open Font License notices. The MIT
          license does not replace those terms or the terms of external services.
        </p>
        <ul>
          <li>
            <a href="/fonts/InstrumentSerif-OFL.txt">Instrument Serif license</a>
          </li>
          <li>
            <a href="/fonts/Inter-LICENSE.txt">Inter license</a>
          </li>
        </ul>
      </section>
      <Link className="button-primary" href="/developers">
        Explore the developer SDK ↗
      </Link>
    </main>
  );
}
