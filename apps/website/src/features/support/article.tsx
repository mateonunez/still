import Link from 'next/link';
export type ArticleContent = {
  title: string;
  description: string;
  eyebrow: string;
  lead: string;
  sections: readonly { title: string; text: string }[];
};
export function Article({ content }: { content: ArticleContent }) {
  return (
    <main id="main" className="article">
      <p className="eyebrow">{content.eyebrow}</p>
      <h1>{content.title}</h1>
      <p className="article-lead">{content.lead}</p>
      {content.sections.map((section) => (
        <section key={section.title}>
          <h2>{section.title}</h2>
          <p>{section.text}</p>
        </section>
      ))}
      <Link className="button-primary" href="/">
        Back to Still <span aria-hidden="true">↗</span>
      </Link>
    </main>
  );
}
