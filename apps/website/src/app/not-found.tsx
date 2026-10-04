import Link from 'next/link';
export default function NotFound() {
  return (
    <main id="main" className="article">
      <p className="eyebrow">A WRONG TURN.</p>
      <h1>
        Nothing here.
        <br />A little Still elsewhere.
      </h1>
      <Link className="button-primary" href="/">
        Return to Still
      </Link>
    </main>
  );
}
