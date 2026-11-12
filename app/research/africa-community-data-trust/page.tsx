import Link from 'next/link';
import {
  ArrowUpRight,
  CheckCircle2,
  Database,
  FileCheck2,
  GitBranch,
  Globe,
  Lock,
  Scale,
  ShieldCheck,
  Sparkles,
  Users,
} from 'lucide-react';

export const metadata = {
  title: 'Africa Community Data Trust (ACDT) | DanYem Innotech AI Solutions Ltd',
  description:
    'An open-source, Nigeria-first community-governed data trust and consent infrastructure platform empowering African communities to control, protect, and benefit from their data.',
};

export default function ACDTResearchPage() {
  return (
    <main className="min-h-screen bg-slate-950 text-slate-100 selection:bg-emerald-500/30">
      <section className="relative overflow-hidden border-b border-slate-800/80 bg-gradient-to-b from-slate-900 via-slate-950 to-slate-950 px-6 py-24 sm:py-32 lg:px-8">
        <div className="mx-auto max-w-4xl text-center">
          <div className="mb-6 inline-flex items-center gap-2 rounded-full border border-emerald-500/30 bg-emerald-500/10 px-4 py-1.5 text-xs font-medium tracking-wide text-emerald-300">
            <Sparkles className="h-3.5 w-3.5" />
            <span>Open-Source Public-Interest Research Initiative</span>
          </div>
          <h1 className="text-4xl font-bold tracking-tight text-white sm:text-6xl">
            Africa Community Data Trust{' '}
            <span className="text-emerald-400">(ACDT)</span>
          </h1>
          <p className="mx-auto mt-6 max-w-2xl text-lg leading-8 text-slate-300">
            Empowering African communities to control, protect, and benefit from
            their data through verifiable digital consent, purpose-bound
            governance, and transparent reciprocity.
          </p>
          <div className="mt-10 flex flex-wrap items-center justify-center gap-4">
            <a
              href="https://github.com/danyemaisolutions-a11y/africa-community-data-trust"
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-2 rounded-lg bg-emerald-500 px-6 py-3 text-sm font-semibold text-slate-950 shadow-sm transition hover:bg-emerald-400"
            >
              <GitBranch className="h-4 w-4" />
              Explore Open-Source Repository
              <ArrowUpRight className="h-4 w-4" />
            </a>
            <Link
              href="/contact?topic=acdt-partnership"
              className="inline-flex items-center gap-2 rounded-lg border border-slate-700 bg-slate-900/80 px-6 py-3 text-sm font-semibold text-slate-200 transition hover:border-slate-500 hover:bg-slate-800"
            >
              Partner With Us on Research
            </Link>
          </div>
        </div>
      </section>

      <section className="mx-auto max-w-6xl px-6 py-20 lg:px-8">
        <div className="grid gap-12 lg:grid-cols-2 lg:items-center">
          <div>
            <h2 className="text-2xl font-bold tracking-tight text-white sm:text-3xl">
              Closing the Extractive Data Gap in Global Health &amp; AI
            </h2>
            <p className="mt-4 text-base leading-7 text-slate-300">
              Across Africa, vulnerable and underserved communities frequently
              contribute vital health, social, and linguistic data to external
              research initiatives—yet rarely retain visibility into how that
              data is used, who accesses it, or what benefits flow back locally.
            </p>
            <p className="mt-4 text-base leading-7 text-slate-300">
              Designed with a{' '}
              <strong className="text-white">
                Nigeria-first, Africa-ready
              </strong>{' '}
              architecture aligned with the{' '}
              <strong className="text-emerald-400">
                Nigeria Data Protection Act 2023 (NDPA)
              </strong>
              , ACDT provides grassroots organizations and civil society with
              open-source technical infrastructure to act as trusted data
              stewards.
            </p>
          </div>
          <div className="grid gap-4 sm:grid-cols-2">
            {[
              {
                icon: FileCheck2,
                title: 'Granular Consent',
                desc: 'Plain-language consent workflows with localized translations and instant withdrawal.',
              },
              {
                icon: Lock,
                title: 'Purpose-Bound Access',
                desc: 'PostgreSQL Row Level Security enforcing strict cohort and research boundaries.',
              },
              {
                icon: Database,
                title: 'Identity Separation',
                desc: 'Deterministic pseudonymization decoupling participant identities from research records.',
              },
              {
                icon: Scale,
                title: 'Equitable Reciprocity',
                desc: 'Publicly auditable ledger tracking non-monetary and capacity returns to communities.',
              },
            ].map((item) => (
              <div
                key={item.title}
                className="rounded-xl border border-slate-800 bg-slate-900/50 p-6"
              >
                <item.icon className="h-6 w-6 text-emerald-400" />
                <h3 className="mt-4 text-base font-semibold text-white">
                  {item.title}
                </h3>
                <p className="mt-2 text-sm leading-6 text-slate-400">
                  {item.desc}
                </p>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className="border-y border-slate-800/80 bg-slate-900/30 px-6 py-20 lg:px-8">
        <div className="mx-auto max-w-6xl">
          <div className="max-w-3xl">
            <h2 className="text-2xl font-bold tracking-tight text-white sm:text-3xl">
              Zero-Harm Engineering &amp; Ethical Safeguards
            </h2>
            <p className="mt-4 text-base text-slate-300">
              Building trust in sensitive domains such as community mental
              health requires strict technical discipline before a single live
              record is ever collected.
            </p>
          </div>

          <div className="mt-10 grid gap-6 md:grid-cols-3">
            <div className="rounded-xl border border-slate-800 bg-slate-950 p-6">
              <div className="flex items-center gap-2 text-sm font-semibold text-emerald-400">
                <ShieldCheck className="h-5 w-5" />
                <span>Synthetic Data Gate</span>
              </div>
              <p className="mt-3 text-sm leading-6 text-slate-300">
                All open-source prototyping, schema validation, and security
                testing run exclusively on synthetic datasets—ensuring zero
                risk to real community participants prior to formal ethics board
                clearance.
              </p>
            </div>

            <div className="rounded-xl border border-slate-800 bg-slate-950 p-6">
              <div className="flex items-center gap-2 text-sm font-semibold text-emerald-400">
                <Users className="h-5 w-5" />
                <span>Human-in-the-Loop AI</span>
              </div>
              <p className="mt-3 text-sm leading-6 text-slate-300">
                Advisory language tools assist with accessible consent
                summaries and Yoruba/Pidgin/Hausa translations, while strictly
                prohibiting autonomous data approvals or clinical profiling.
              </p>
            </div>

            <div className="rounded-xl border border-slate-800 bg-slate-950 p-6">
              <div className="flex items-center gap-2 text-sm font-semibold text-emerald-400">
                <Globe className="h-5 w-5" />
                <span>MIT Open-Source Commons</span>
              </div>
              <p className="mt-3 text-sm leading-6 text-slate-300">
                Released under the permissive MIT License so NGOs, clinics, and
                civic technologists across Africa can deploy, audit, and adapt
                the governance stack independently.
              </p>
            </div>
          </div>
        </div>
      </section>

      <section className="mx-auto max-w-4xl px-6 py-16 text-center lg:px-8">
        <div className="rounded-2xl border border-slate-800 bg-slate-900/60 p-8">
          <div className="mx-auto mb-4 flex h-10 w-10 items-center justify-center rounded-full bg-emerald-500/10 text-emerald-400">
            <CheckCircle2 className="h-5 w-5" />
          </div>
          <h3 className="text-lg font-semibold text-white">
            Stewarded by DanYem Innotech AI Solutions Ltd (RC 10003216)
          </h3>
          <p className="mx-auto mt-3 max-w-2xl text-sm leading-6 text-slate-400">
            While DanYem Innotech AI Solutions Ltd provides commercial AI
            engineering and digital transformation services, the Africa
            Community Data Trust codebase is maintained as an independent,
            open-source public-interest initiative.
          </p>
        </div>
      </section>
    </main>
  );
}
