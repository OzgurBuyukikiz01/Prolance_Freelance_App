import cors from 'cors';
import express from 'express';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();
const app = express();

app.use(cors());
app.use(express.json());

function jobToFlutter(j: {
  id: string;
  title: string;
  description: string;
  clientName: string;
  clientAvatar: string;
  budgetMin: number;
  budgetMax: number;
  budgetType: string;
  category: string;
  skills: unknown;
  experienceLevel: string;
  duration: string;
  proposalCount: number;
  isSaved: boolean;
  status: string;
  isUserPosted: boolean;
  postedDate: Date;
}) {
  return {
    id: j.id,
    title: j.title,
    description: j.description,
    clientName: j.clientName,
    clientAvatar: j.clientAvatar,
    budgetMin: j.budgetMin,
    budgetMax: j.budgetMax,
    budgetType: j.budgetType,
    category: j.category,
    skills: j.skills as string[],
    experienceLevel: j.experienceLevel,
    postedDate: j.postedDate.toISOString(),
    proposalCount: j.proposalCount,
    duration: j.duration,
    isSaved: j.isSaved,
    status: j.status,
    isUserPosted: j.isUserPosted,
  };
}

app.get('/health', (_, res) => {
  res.json({ ok: true });
});

app.get('/v1/jobs', async (_, res) => {
  const rows = await prisma.job.findMany({ orderBy: { postedDate: 'desc' } });
  res.json(rows.map(jobToFlutter));
});

app.post('/v1/jobs', async (req, res) => {
  const body = req.body as Record<string, unknown>;
  const j = await prisma.job.create({
    data: {
      title: body.title as string,
      description: body.description as string,
      clientName: body.clientName as string,
      clientAvatar: body.clientAvatar as string,
      budgetMin: Number(body.budgetMin),
      budgetMax: Number(body.budgetMax),
      budgetType: body.budgetType as string,
      category: body.category as string,
      skills: (body.skills as string[]) ?? [],
      experienceLevel: body.experienceLevel as string,
      duration: body.duration as string,
      proposalCount: 0,
      isSaved: false,
      status: 'open',
      isUserPosted: Boolean(body.isUserPosted),
    },
  });
  res.status(201).json(jobToFlutter(j));
});

app.post('/v1/jobs/:jobId/proposals', async (req, res) => {
  const jobId = req.params.jobId;
  const { bid, deliveryDays, coverLetter, attachments } = req.body as {
    bid: number;
    deliveryDays: number;
    coverLetter: string;
    attachments?: string[];
  };

  await prisma.$transaction([
    prisma.proposal.create({
      data: {
        jobId,
        bid,
        deliveryDays,
        coverLetter,
        attachments: attachments ?? [],
      },
    }),
    prisma.job.update({
      where: { id: jobId },
      data: { proposalCount: { increment: 1 } },
    }),
  ]);

  res.status(201).json({ ok: true });
});

app.get('/v1/conversations', async (_, res) => {
  const rows = await prisma.conversation.findMany({ take: 20 });
  res.json(rows);
});

app.get('/v1/users/me', (_, res) => {
  res.json({ id: 'demo', email: 'demo@prolance.app', name: 'Demo User' });
});

const port = Number(process.env.PORT ?? 3000);
app.listen(port, () => {
  console.log(`Prolance API listening on http://localhost:${port}`);
});
